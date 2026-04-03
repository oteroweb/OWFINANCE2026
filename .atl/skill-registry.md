# Skill Registry

**Orchestrator use only.** Read this registry once per session to resolve skill paths, then pass pre-resolved paths directly to each sub-agent's launch prompt.

## User Skills

| Trigger | Skill | Path |
|---------|-------|------|
| Prefer Notion MCP for Notion, backlog or ticket work, and use the approved workspace fallback only when MCP auth or connectivity fails. | notion-mcp-integration | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/notion-mcp-integration/SKILL.md` |
| Treat the Drive folder `OWFINANCE` (`https://drive.google.com/drive/folders/1tjxzCrWceyWPXydOL374FytD0ExM_Jkh`) as the canonical documentation hub/source of truth, preserve role ownership, and sync local summaries only when needed. | documentator | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/documentator/SKILL.md` |
| Send low-noise Telegram progress updates, explicit step notifications, optional recurring heartbeats, failure/completion alerts, and quick dev/stage/prod ops status checks without storing secrets in repo files. | telegram-ops-notifier | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/telegram-ops-notifier/SKILL.md` |
| Bridge OWFINANCE context to Telegram with a shared transcript, pulled update queue, inbound message logging, preserved slash commands, and freeform replies via local Gemini CLI or deterministic fallback without pretending it is the exact same native chat. | telegram-context-bridge | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/telegram-context-bridge/SKILL.md` |
| Executive operating role for OWFINANCE2026 strategy, market focus, roadmap bets, and cross-functional tradeoffs. | owf-role-ceo-strategy | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-ceo-strategy/SKILL.md` |
| Customer success role for OWFINANCE2026 onboarding quality, retention feedback loops, and trust-building support operations. | owf-role-customer-success | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-customer-success/SKILL.md` |
| Finance role for OWFINANCE2026 pricing, cost controls, unit economics, and commercial viability decisions. | owf-role-finance-unit-economics | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-finance-unit-economics/SKILL.md` |
| Marketing and growth role for OWFINANCE2026 positioning, acquisition experiments, launch planning, and retention messaging. | owf-role-marketing-growth | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-marketing-growth/SKILL.md` |
| Product operations role for OWFINANCE2026 release health, instrumentation, optimization loops, and decision support. | owf-role-product-operations | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-product-operations/SKILL.md` |
| Product owner operating role for OWFINANCE2026 roadmap shaping, story framing, acceptance criteria, and backlog decisions. | owf-role-product-owner | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-product-owner/SKILL.md` |
| Risk and compliance role for OWFINANCE2026 trust, operational safeguards, AI feature review, and fintech-sensitive decisions. | owf-role-risk-compliance | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-risk-compliance/SKILL.md` |
| Data insights role for OWFINANCE2026 metrics definition, analytical framing, reporting, and evidence-backed decisions. | owf-role-data-insights | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-data-insights/SKILL.md` |
| Engineering architecture role for OWFINANCE2026 technical decisions, system boundaries, maintainability, and implementation guardrails. | owf-role-engineering-architecture | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-engineering-architecture/SKILL.md` |
| QA and release quality role for OWFINANCE2026 test coverage, release confidence, defect prevention, and regression control. | owf-role-qa-release-quality | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-qa-release-quality/SKILL.md` |
| DevOps, platform, and SRE role for OWFINANCE2026 delivery infrastructure, runtime reliability, deployment safety, and operational readiness. | owf-role-devops-platform-sre | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-devops-platform-sre/SKILL.md` |
| Sales and commercial role for OWFINANCE2026 pricing conversations, pipeline shaping, and offer validation. | owf-role-sales-commercial | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-sales-commercial/SKILL.md` |
| Scrum master and delivery planning role for OWFINANCE2026 sprint framing, capacity control, and blocker management. | owf-role-scrum-master-planning | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-scrum-master-planning/SKILL.md` |
| UI and UX design stewardship role for OWFINANCE2026 premium fintech journeys, design consistency, and frontend review. | owf-role-ui-ux-design-steward | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/owf-role-ui-ux-design-steward/SKILL.md` |
| Specialized UX/UI agent expert for OW Finance 2026. Use this skill whenever generating new UI screens, implementing Quasar components, or reviewing frontend design. | ow-finance-ux-expert | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/ow-finance-ux-expert/SKILL.md` |
| UI/UX design intelligence for planning, building, reviewing, and improving interfaces. | ui-ux-pro-max | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/ui-ux-pro-max/SKILL.md` |
| React composition patterns for component architecture, compound components, and reusable APIs. | vercel-composition-patterns | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/vercel-composition-patterns/SKILL.md` |
| React and Next.js performance optimization guidelines for component work, fetching, and bundle optimization. | vercel-react-best-practices | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/vercel-react-best-practices/SKILL.md` |
| React Native and Expo best practices for mobile performance, animations, and native APIs. | vercel-react-native-skills | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/vercel-react-native-skills/SKILL.md` |
| Review UI code for Web Interface Guidelines compliance. | web-design-guidelines | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.agents/skills/web-design-guidelines/SKILL.md` |

## SDD Skills

| Skill | Path |
|------|------|
| sdd-init | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-init/SKILL.md` |
| sdd-explore | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-explore/SKILL.md` |
| sdd-propose | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-propose/SKILL.md` |
| sdd-spec | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-spec/SKILL.md` |
| sdd-design | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-design/SKILL.md` |
| sdd-tasks | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-tasks/SKILL.md` |
| sdd-apply | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-apply/SKILL.md` |
| sdd-verify | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-verify/SKILL.md` |
| sdd-archive | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/sdd-archive/SKILL.md` |
| skill-registry | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/skill-registry/SKILL.md` |

## Shared Conventions

| File | Path | Notes |
|------|------|-------|
| AGENTS.md | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/AGENTS.md` | Main project rules |
| CLAUDE.md | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/CLAUDE.md` | Agent Teams Lite orchestrator instructions |
| SAAS_ROLE_SYSTEM.md | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/docs/01-configuracion/SAAS_ROLE_SYSTEM.md` | Operating-role handbook |
| Engram convention | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/_shared/engram-convention.md` | SDD persistence for Engram |
| Persistence contract | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/_shared/persistence-contract.md` | Artifact store behavior |
| OpenSpec convention | `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.claude/skills/_shared/openspec-convention.md` | Filesystem artifact layout |
