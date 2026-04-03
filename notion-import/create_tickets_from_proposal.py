#!/usr/bin/env python3

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional


NOTION_VERSION = "2022-06-28"
DATABASE_PROPERTY_CANDIDATES = {
    "status": ["Status", "Estado"],
    "priority": ["Priority", "Prioridad"],
    "role": ["Role", "Roles"],
    "estimate": ["Estimate", "Estimacion de Horas", "Estimacion", "Estimate Hours"],
    "user_story": ["User Story", "Historia de Usuario"],
    "acceptance": ["Acceptance Criteria", "Criterios de Aceptacion"],
}

ESTIMATE_LABEL_CANDIDATES = [
    "Estimacion de Horas",
    "Estimación de Horas",
    "Estimacion",
    "Estimate Hours",
]


@dataclass
class Ticket:
    section_number: str
    section_title: str
    name: str
    status: str
    priority: str
    roles: List[str]
    estimate: str
    user_story: str
    acceptance_criteria: List[str]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create Notion tickets from a markdown proposal file."
    )
    parser.add_argument("proposal_path", help="Path to the proposal markdown file.")
    parser.add_argument(
        "database_id",
        nargs="?",
        help="Target Notion database ID. Falls back to NOTION_DATABASE_ID.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Parse the proposal and print the ticket plan without calling Notion.",
    )
    return parser.parse_args()


def extract_basic_value(line: str, label: str) -> Optional[str]:
    prefix = f"- **{label}:**"
    if line.startswith(prefix):
        return line[len(prefix) :].strip()
    return None


def collect_section_text(lines: List[str], start_index: int) -> (str, int):
    collected: List[str] = []
    index = start_index
    while index < len(lines):
        line = lines[index].strip()
        if line.startswith("### ") or line.startswith("## "):
            break
        if line == "---":
            index += 1
            break
        if line:
            collected.append(line)
        index += 1
    text = " ".join(collected).strip().strip('"')
    return text, index


def collect_bullets(lines: List[str], start_index: int) -> (List[str], int):
    bullets: List[str] = []
    index = start_index
    while index < len(lines):
        line = lines[index].strip()
        if line.startswith("### ") or line.startswith("## "):
            break
        if line == "---":
            index += 1
            break
        if line.startswith("- "):
            bullets.append(line[2:].strip())
        index += 1
    return bullets, index


def parse_ticket(section_heading: str, section_lines: List[str]) -> Ticket:
    match = re.match(r"##\s+([0-9]+)\.\s+(.*)", section_heading)
    if not match:
        raise ValueError(f"Unsupported ticket heading: {section_heading}")

    section_number = match.group(1).strip()
    section_title = match.group(2).strip()
    name = section_title
    status = "To Do"
    priority = "Media"
    roles: List[str] = []
    estimate = ""
    user_story = ""
    acceptance_criteria: List[str] = []

    index = 0
    while index < len(section_lines):
        line = section_lines[index].strip()
        if not line:
            index += 1
            continue

        extracted = extract_basic_value(line, "Name")
        if extracted is not None:
            name = extracted
            index += 1
            continue

        extracted = extract_basic_value(line, "Status")
        if extracted is not None:
            status = extracted
            index += 1
            continue

        extracted = extract_basic_value(line, "Priority")
        if extracted is not None:
            priority = extracted
            index += 1
            continue

        extracted = extract_basic_value(line, "Role")
        if extracted is not None:
            roles = [item.strip() for item in extracted.split(",") if item.strip()]
            index += 1
            continue

        for estimate_label in ESTIMATE_LABEL_CANDIDATES:
            extracted = extract_basic_value(line, estimate_label)
            if extracted is not None:
                estimate = extracted
                index += 1
                break
        if extracted is not None:
            continue

        if line == "### User Story":
            user_story, index = collect_section_text(section_lines, index + 1)
            continue

        if line == "### Criterios de Aceptacion":
            acceptance_criteria, index = collect_bullets(section_lines, index + 1)
            continue

        index += 1

    if not user_story:
        raise ValueError(f"Ticket {section_number} is missing a user story")

    return Ticket(
        section_number=section_number,
        section_title=section_title,
        name=name,
        status=status,
        priority=priority,
        roles=roles,
        estimate=estimate,
        user_story=user_story,
        acceptance_criteria=acceptance_criteria,
    )


def parse_proposal(text: str) -> List[Ticket]:
    tickets: List[Ticket] = []
    current_heading: Optional[str] = None
    current_lines: List[str] = []

    for raw_line in text.splitlines():
        line = raw_line.rstrip()
        if line.startswith("## "):
            if current_heading is not None:
                tickets.append(parse_ticket(current_heading, current_lines))
            current_heading = line
            current_lines = []
            continue
        if current_heading is not None:
            current_lines.append(line)

    if current_heading is not None:
        tickets.append(parse_ticket(current_heading, current_lines))

    if not tickets:
        raise ValueError("No tickets found in proposal markdown")

    return tickets


def notion_request(token: str, method: str, url: str, payload: Optional[dict] = None) -> dict:
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Notion-Version": NOTION_VERSION,
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as error:
        body = error.read().decode("utf-8", errors="ignore")
        raise RuntimeError(f"Notion API error {error.code}: {body[:300]}") from error


def get_database_schema(token: str, database_id: str) -> dict:
    return notion_request(token, "GET", f"https://api.notion.com/v1/databases/{database_id}")


def build_rich_text(value: str) -> List[dict]:
    return [{"type": "text", "text": {"content": value[:2000]}}] if value else []


def find_property_name(properties: Dict[str, dict], candidates: List[str]) -> Optional[str]:
    lowered = {name.casefold(): name for name in properties}
    for candidate in candidates:
        match = lowered.get(candidate.casefold())
        if match:
            return match
    return None


def build_properties(ticket: Ticket, schema: dict) -> dict:
    properties = schema.get("properties", {})
    payload: Dict[str, dict] = {}

    title_name = None
    for property_name, property_config in properties.items():
        if property_config.get("type") == "title":
            title_name = property_name
            break
    if title_name is None:
        raise RuntimeError("Target database has no title property")
    payload[title_name] = {"title": build_rich_text(ticket.name)}

    mapping = {
        "status": ticket.status,
        "priority": ticket.priority,
        "estimate": ticket.estimate,
        "user_story": ticket.user_story,
        "acceptance": " | ".join(ticket.acceptance_criteria),
    }

    for field_name, value in mapping.items():
        property_name = find_property_name(properties, DATABASE_PROPERTY_CANDIDATES[field_name])
        if not property_name or not value:
            continue

        property_type = properties[property_name].get("type")
        if property_type == "select":
            payload[property_name] = {"select": {"name": value}}
        elif property_type == "rich_text":
            payload[property_name] = {"rich_text": build_rich_text(value)}
        elif property_type == "status":
            payload[property_name] = {"status": {"name": value}}

    role_property_name = find_property_name(properties, DATABASE_PROPERTY_CANDIDATES["role"])
    if role_property_name and ticket.roles:
        property_type = properties[role_property_name].get("type")
        if property_type == "multi_select":
            payload[role_property_name] = {
                "multi_select": [{"name": role} for role in ticket.roles]
            }
        elif property_type == "rich_text":
            payload[role_property_name] = {
                "rich_text": build_rich_text(", ".join(ticket.roles))
            }

    return payload


def build_children(ticket: Ticket) -> List[dict]:
    children = [
        {
            "object": "block",
            "type": "paragraph",
            "paragraph": {
                "rich_text": build_rich_text(
                    f"Propuesta {ticket.section_number}: {ticket.section_title}"
                )
            },
        },
        {
            "object": "block",
            "type": "paragraph",
            "paragraph": {"rich_text": build_rich_text(ticket.user_story)},
        },
    ]

    for item in ticket.acceptance_criteria:
        children.append(
            {
                "object": "block",
                "type": "bulleted_list_item",
                "bulleted_list_item": {"rich_text": build_rich_text(item)},
            }
        )

    return children


def create_page(token: str, database_id: str, schema: dict, ticket: Ticket) -> dict:
    payload = {
        "parent": {"database_id": database_id},
        "properties": build_properties(ticket, schema),
        "children": build_children(ticket),
    }
    return notion_request(token, "POST", "https://api.notion.com/v1/pages", payload)


def main() -> int:
    args = parse_args()
    proposal_path = Path(args.proposal_path).expanduser().resolve()
    if not proposal_path.exists():
        print(f"Proposal file not found: {proposal_path}", file=sys.stderr)
        return 1

    try:
        tickets = parse_proposal(proposal_path.read_text(encoding="utf-8"))
    except Exception as error:
        print(f"Failed to parse proposal: {error}", file=sys.stderr)
        return 1

    database_id = args.database_id or os.getenv("NOTION_DATABASE_ID")
    if not database_id:
        print("Missing Notion database ID. Pass it as an argument or set NOTION_DATABASE_ID.", file=sys.stderr)
        return 1

    if args.dry_run:
        print(f"Dry run: {len(tickets)} tickets parsed from {proposal_path}")
        for ticket in tickets:
            print(f"- {ticket.section_number}: {ticket.name} [{ticket.priority}]")
        return 0

    token = os.getenv("NOTION_API_TOKEN")
    if not token:
        print("Missing NOTION_API_TOKEN in the environment.", file=sys.stderr)
        return 1

    try:
        schema = get_database_schema(token, database_id)
        created = []
        for ticket in tickets:
            page = create_page(token, database_id, schema, ticket)
            created.append(
                {
                    "number": ticket.section_number,
                    "name": ticket.name,
                    "id": page.get("id", "unknown"),
                    "url": page.get("url", ""),
                }
            )
    except Exception as error:
        print(f"Failed to create tickets: {error}", file=sys.stderr)
        return 1

    print(f"Created {len(created)} ticket(s) in Notion:")
    for item in created:
        suffix = f" | {item['url']}" if item["url"] else ""
        print(f"- {item['number']}: {item['name']} | {item['id']}{suffix}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
