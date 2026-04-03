#!/usr/bin/env python3
"""
Stitch Documentation Extractor
Extracts and documents Stitch UI screens for OWFinance
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
from html.parser import HTMLParser
from typing import Dict, List, Any

class HTMLMetadataParser(HTMLParser):
    """Parse HTML to extract component and styling metadata"""

    def __init__(self):
        super().__init__()
        self.components = []
        self.classes = set()
        self.ids = set()
        self.data_attrs = {}

    def handle_starttag(self, tag, attrs):
        attr_dict = dict(attrs)

        if "class" in attr_dict:
            classes = attr_dict["class"].split()
            self.classes.update(classes)

        if "id" in attr_dict:
            self.ids.add(attr_dict["id"])

        for key, value in attr_dict.items():
            if key.startswith("data-"):
                self.data_attrs[key] = value

        if tag in ["button", "input", "select", "form", "canvas", "svg"]:
            self.components.append({"type": tag, "class": attr_dict.get("class", "")})


class StitchExtractor:
    """Main extraction engine for Stitch screens"""

    def __init__(self, source_dir: str):
        self.source_dir = source_dir
        self.screens = []

    def extract_screen_info(self, screen_dir: str) -> Dict[str, Any]:
        """Extract metadata from a single screen"""
        screen_path = os.path.join(self.source_dir, screen_dir)
        code_file = os.path.join(screen_path, "code.html")
        image_file = os.path.join(screen_path, "screen.png")

        info = {
            "id": screen_dir,
            "name": screen_dir.replace("_", " ").title(),
            "has_code": os.path.exists(code_file),
            "has_image": os.path.exists(image_file),
            "code_size": os.path.getsize(code_file) if os.path.exists(code_file) else 0,
            "image_size": os.path.getsize(image_file) if os.path.exists(image_file) else 0,
            "components": [],
            "unique_classes": [],
            "layout_type": "Unknown",
            "responsive": "Unknown",
            "category": self._categorize(screen_dir),
            "type": self._get_type(screen_dir),
            "variants": self._get_variants(screen_dir),
        }

        if info["has_code"]:
            try:
                with open(code_file, "r") as f:
                    html_content = f.read()

                parser = HTMLMetadataParser()
                parser.feed(html_content)

                info["components"] = parser.components[:10]
                info["unique_classes"] = sorted(list(parser.classes))[:20]

                # Detect layout
                html_lower = html_content.lower()
                if "grid" in html_lower:
                    info["layout_type"] = "Grid"
                elif "flex" in html_lower:
                    info["layout_type"] = "Flexbox"
                elif "absolute" in html_lower or "fixed" in html_lower:
                    info["layout_type"] = "Absolute/Fixed"

                # Detect responsive
                if "media" in html_lower or "@media" in html_content:
                    info["responsive"] = "Yes (Media Queries)"
                elif "mobile" in screen_dir.lower() or "lite" in screen_dir.lower():
                    info["responsive"] = "Mobile Optimized"
                elif "pro" in screen_dir.lower() or "desktop" in screen_dir.lower():
                    info["responsive"] = "Desktop Optimized"

            except Exception as e:
                info["parse_error"] = str(e)

        return info

    def _categorize(self, screen_id: str) -> str:
        """Categorize screen by name patterns"""
        screen_lower = screen_id.lower()
        if "dashboard" in screen_lower:
            return "Dashboard"
        elif "jar" in screen_lower:
            return "Jars Management"
        elif "transaction" in screen_lower:
            return "Transactions"
        elif "settings" in screen_lower:
            return "Settings"
        elif "modal" in screen_lower:
            return "Modals"
        elif "navigation" in screen_lower:
            return "Navigation"
        return "Other"

    def _get_type(self, screen_id: str) -> str:
        """Determine screen type"""
        screen_lower = screen_id.lower()
        if "mobile" in screen_lower or "lite" in screen_lower:
            return "Mobile"
        elif "desktop" in screen_lower or "pro" in screen_lower:
            return "Desktop"
        elif "modal" in screen_lower or "navigation" in screen_lower:
            return "Overlay"
        return "Unknown"

    def _get_variants(self, screen_id: str) -> List[str]:
        """Extract variants"""
        variants = []
        if "lite" in screen_id.lower():
            variants.append("Lite")
        if "pro" in screen_id.lower():
            variants.append("Pro")
        return variants

    def extract_all(self) -> List[Dict[str, Any]]:
        """Extract all screens from source directory"""
        screens = []
        for screen_dir in sorted(os.listdir(self.source_dir)):
            screen_path = os.path.join(self.source_dir, screen_dir)
            if os.path.isdir(screen_path):
                screens.append(self.extract_screen_info(screen_dir))

        self.screens = screens
        return screens

    def generate_inventory(self) -> Dict[str, Any]:
        """Generate complete inventory"""
        if not self.screens:
            self.extract_all()

        categories = {}
        valid_cats = ["Dashboard", "Transactions", "Jars Management", "Settings", "Modals", "Navigation", "Other"]

        for cat in valid_cats:
            categories[cat] = [s for s in self.screens if s.get("category") == cat]

        return {
            "project_id": "5968657237763273187",
            "export_date": datetime.now().isoformat(),
            "total_screens": len(self.screens),
            "screens": self.screens,
            "categories": categories,
        }

    def generate_notion_entries(self) -> List[Dict[str, Any]]:
        """Generate entries for Notion database"""
        if not self.screens:
            self.extract_all()

        entries = []
        for screen in self.screens:
            entry = {
                "Name": screen["name"],
                "Screen ID": screen["id"],
                "Category": screen["category"],
                "Type": screen["type"],
                "Variants": json.dumps(screen["variants"]),
                "Layout Type": screen["layout_type"],
                "Responsive": screen["responsive"],
                "Components Count": len(screen.get("components", [])),
                "Code Size (KB)": round(screen.get("code_size", 0) / 1024, 2),
                "Image Size (KB)": round(screen.get("image_size", 0) / 1024, 2),
                "Description": f"Screen: {screen['name']} | Type: {screen['type']}",
                "Key Classes": ", ".join(screen.get("unique_classes", [])[:5]),
                "Status": "Documented"
            }
            entries.append(entry)

        return entries

    def export_json(self, output_path: str) -> None:
        """Export inventory to JSON"""
        inventory = self.generate_inventory()
        with open(output_path, "w") as f:
            json.dump(inventory, f, indent=2)
        print(f"Exported inventory to {output_path}")

    def export_markdown(self, output_path: str) -> None:
        """Export documentation to Markdown"""
        if not self.screens:
            self.extract_all()

        md_content = "# Stitch Documentation\n\n"
        md_content += f"Generated: {datetime.now().isoformat()}\n"
        md_content += f"Total Screens: {len(self.screens)}\n\n"

        # Group by category
        for category in ["Dashboard", "Transactions", "Jars Management", "Settings", "Modals", "Navigation", "Other"]:
            screens = [s for s in self.screens if s["category"] == category]
            if not screens:
                continue

            md_content += f"## {category}\n\n"
            for screen in screens:
                md_content += f"### {screen['name']}\n\n"
                md_content += f"- **ID**: {screen['id']}\n"
                md_content += f"- **Type**: {screen['type']}\n"
                md_content += f"- **Variants**: {', '.join(screen['variants']) or 'None'}\n"
                md_content += f"- **Layout**: {screen['layout_type']}\n"
                md_content += f"- **Responsive**: {screen['responsive']}\n"
                md_content += f"- **Components**: {len(screen.get('components', []))}\n"
                md_content += f"- **Code Size**: {round(screen.get('code_size', 0) / 1024, 2)} KB\n"
                md_content += f"- **Image Size**: {round(screen.get('image_size', 0) / 1024, 2)} KB\n\n"

        with open(output_path, "w") as f:
            f.write(md_content)
        print(f"Exported markdown to {output_path}")


def main():
    """CLI entry point"""
    import argparse

    parser = argparse.ArgumentParser(description="Extract Stitch screen documentation")
    parser.add_argument("--source-dir", default="/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/stitch_ow_finance_2026_master_ui_definitivo", help="Source directory with screens")
    parser.add_argument("--output-format", choices=["json", "markdown", "all"], default="json", help="Output format")
    parser.add_argument("--output-dir", default=".", help="Output directory")

    args = parser.parse_args()

    extractor = StitchExtractor(args.source_dir)

    if args.output_format in ["json", "all"]:
        output_path = os.path.join(args.output_dir, "stitch_screens_inventory.json")
        extractor.export_json(output_path)

    if args.output_format in ["markdown", "all"]:
        output_path = os.path.join(args.output_dir, "stitch_documentation.md")
        extractor.export_markdown(output_path)

    print(f"✓ Extraction complete: {len(extractor.screens)} screens processed")


if __name__ == "__main__":
    main()
