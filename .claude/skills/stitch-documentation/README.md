# Stitch Documentation Skill

Automated extraction and documentation of Stitch UI/UX design system for OWFinance.

## Quick Start

### Export screens to JSON
```bash
python3 stitch_extractor.py --output-format json --output-dir ./exports
```

### Export to Markdown
```bash
python3 stitch_extractor.py --output-format markdown --output-dir ./exports
```

### Export both formats
```bash
python3 stitch_extractor.py --output-format all --output-dir ./exports
```

## What This Skill Does

1. **Scans** all Stitch screens in the source directory
2. **Parses** HTML code to extract components and CSS patterns
3. **Analyzes** screen properties (layout type, responsive behavior, variants)
4. **Categorizes** screens (Dashboard, Transactions, Jars, Settings, etc.)
5. **Generates** structured documentation in JSON, Markdown, and Notion formats

## Generated Files

- `stitch_screens_inventory.json` - Complete inventory with all metadata
- `stitch_screens_detailed_metadata.json` - Detailed extraction results
- `stitch_documentation.md` - Human-readable documentation
- `notion_entries.json` - Ready-to-import Notion entries

## Notion Integration

The skill integrates with Notion to create a living database:

- **Base Page**: [Stitch UI/UX Documentation](https://www.notion.so/337e7ace976781eb95d4cf01bba3a5dc)
- **Database**: [Screen Inventory](https://www.notion.so/5ab55a87954f42b79e8b845d06ade5cf)

### Features

- Full-text search across all screens
- Filter by category, type, or responsive behavior
- View count of components per screen
- Track code and image file sizes
- Status tracking for documentation progress

## Screen Categories

### Dashboard (6 screens)
- Desktop Pro variants (Home 1, Home 2, Light Mode)
- Mobile Lite variants (Dashboard 1, Dashboard 2, Home)

### Transactions (2 screens)
- Mobile Lite transactions list
- Desktop Pro super grid view

### Jars Management (1 screen)
- Desktop Pro jars management interface

### Settings (1 screen)
- Desktop Pro settings configuration

### Modals & Overlays (2 screens)
- Quick add modal (light mode)
- Expanded navigation menu

### Other (5 screens)
- AI Coach Chat
- C Ntaros Mobile Lite
- Liquid Glass Unified (2 variants)
- Precision Vault

## Metadata Extracted Per Screen

| Property | Type | Example |
|----------|------|---------|
| ID | String | `desktop_pro_dashboard_home_1` |
| Name | String | "Desktop Pro Dashboard Home 1" |
| Category | Enum | Dashboard, Transactions, etc. |
| Type | Enum | Mobile, Desktop, Overlay |
| Variants | Array | ["Lite"], ["Pro"], [] |
| Layout Type | Enum | Grid, Flexbox, Absolute/Fixed |
| Responsive | Enum | Mobile Optimized, Desktop Optimized, Yes (Media Queries) |
| Components | Number | Count of interactive elements |
| Code Size | Number | KB |
| Image Size | Number | KB |
| Key CSS Classes | Array | [-rotate-90, absolute, active:scale-95] |

## Architecture

```
.claude/skills/stitch-documentation/
├── SKILL.md                  # Skill definition and documentation
├── README.md                 # This file
├── stitch_extractor.py       # Main extraction engine
└── exports/                  # Generated exports
    ├── stitch_screens_inventory.json
    ├── stitch_documentation.md
    └── notion_entries.json
```

## Usage in Projects

### As a Reusable Skill
```bash
/stitch-documentation --output-format json
```

### As a Library
```python
from stitch_extractor import StitchExtractor

extractor = StitchExtractor("/path/to/screens")
inventory = extractor.generate_inventory()
notion_entries = extractor.generate_notion_entries()
```

## Requirements

- Python 3.6+
- No external dependencies (uses standard library)
- Source directory with Stitch screens (each screen has `code.html` and `screen.png`)

## Configuration

### Source Directory
Default: `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/stitch_ow_finance_2026_master_ui_definitivo`

### Output Directory
Default: Current directory

### Format Options
- `json` - Structured JSON inventory
- `markdown` - Human-readable documentation
- `all` - Both formats

## Examples

### Generate and save inventory
```bash
python3 stitch_extractor.py \
  --output-format json \
  --output-dir /tmp/stitch_exports
```

Output: `/tmp/stitch_exports/stitch_screens_inventory.json`

### Generate documentation
```bash
python3 stitch_extractor.py \
  --output-format markdown \
  --output-dir ./docs/ui-ux
```

Output: `./docs/ui-ux/stitch_documentation.md`

## Notion Database Schema

The skill generates entries compatible with this Notion database structure:

```
Properties:
- Name (Title)
- Screen ID (Text)
- Category (Select)
- Type (Select)
- Variants (Multi-select)
- Layout Type (Select)
- Responsive (Select)
- Components Count (Number)
- Code Size (KB) (Number)
- Image Size (KB) (Number)
- Description (Text)
- Key Classes (Text)
- Status (Select)
```

## Troubleshooting

### No screens found
- Check source directory path is correct
- Verify subdirectories exist with `code.html` files
- Run: `ls -la /path/to/source/`

### Parse errors on specific screens
- Some screens may not have HTML code (design mockups only)
- Check error message in output
- Image exports still available even if HTML missing

### Notion export fails
- Validate Notion API token is active
- Check token has permissions to create pages
- Verify parent page is accessible

## Contributing

To improve this skill:

1. Add new categorization patterns in `_categorize()`
2. Extend metadata extraction in `extract_screen_info()`
3. Add new export formats in `export_*()` methods
4. Update SKILL.md with new features

## License

Internal use - OWFinance 2026 project

## Last Updated

April 2, 2026
