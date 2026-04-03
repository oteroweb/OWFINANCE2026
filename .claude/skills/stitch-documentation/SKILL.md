# Stitch Documentation Skill

Extract and document Stitch UI/UX screens, components, layouts, and flows.

## Description

This skill automatically extracts metadata from Stitch project screens and generates comprehensive documentation in multiple formats (Notion, JSON, Markdown).

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `projectId` | string | No | Stitch project ID (default: `5968657237763273187`) |
| `notionToken` | string | No | Notion API token for Notion export |
| `outputFormat` | enum | No | Output format: `notion`, `json`, `markdown` (default: `json`) |
| `sourceDir` | string | No | Local directory with exported Stitch screens |
| `exportPath` | string | No | Path to save exported data |

## Usage Examples

### Export all screens to JSON
```bash
/stitch-documentation --outputFormat json
```

### Export to Notion (requires token)
```bash
/stitch-documentation --outputFormat notion --notionToken "ntn_..."
```

### Process custom source directory
```bash
/stitch-documentation --sourceDir "/path/to/screens" --outputFormat json
```

## Features

### Screen Extraction
- Enumerate all screens in project
- Extract metadata: ID, name, category, type, variants
- Parse HTML/code structure
- Detect layout types (Flexbox, Grid, Absolute)
- Identify responsive properties
- Extract component inventory

### Categorization
Automatically categorizes screens into:
- Dashboard (multiple variants: Lite, Pro)
- Transactions (mobile and desktop)
- Jars Management
- Settings
- Modals & Overlays
- Navigation
- Other

### Output Formats

#### JSON Inventory
Complete structured inventory with all metadata:
```json
{
  "project_id": "5968657237763273187",
  "export_date": "2026-04-02T...",
  "total_screens": 17,
  "screens": [
    {
      "id": "screen_id",
      "name": "Screen Name",
      "category": "Dashboard",
      "type": "Mobile",
      "variants": ["Lite", "Pro"],
      "layout_type": "Grid",
      "responsive": "Mobile Optimized",
      "components_count": 10,
      "code_size_kb": 10.52,
      "image_size_kb": 243.93,
      "description": "...",
      "key_classes": [...]
    }
  ],
  "categories": {...},
  "layouts": {...},
  "components": {...},
  "flows": [...]
}
```

#### Notion Database
Creates a database with:
- Properties: ID, Name, Category, Type, Variants, Layout Type, Responsive, Component Count, Code Size, Image Size, Status
- Full searchable catalog
- Views: By Category, By Type, By Responsive
- Easy filtering and sorting

#### Markdown Export
Human-readable documentation with:
- Screen inventory by category
- Component library with usage
- Layout patterns and grid system
- User flow documentation
- Responsive variants table

## API Reference

### Available Properties

**Screen Object:**
- `id` (string): Unique screen identifier
- `name` (string): Human-readable name
- `category` (string): Screen category
- `type` (string): Mobile, Desktop, or Overlay
- `variants` (array): Lite, Pro, Mini variants
- `layout_type` (string): Flexbox, Grid, Absolute/Fixed
- `responsive` (string): Responsive indicators
- `components_count` (number): Count of UI components
- `code_size_kb` (number): HTML/CSS size
- `image_size_kb` (number): Screenshot size
- `description` (string): Screen description
- `key_classes` (array): Important CSS classes

## Output Files

```
.
├── stitch_screens_inventory.json          # Complete inventory
├── stitch_screens_detailed_metadata.json  # Detailed metadata
├── stitch_documentation.md                # Markdown export
└── notion_entries.json                    # Notion database entries
```

## Integration with Notion

When `--outputFormat notion` is specified:

1. Creates base page: "Stitch UI/UX - Documentación Completa"
2. Creates database: "📋 Screen Inventory"
3. Populates 17 screens with all metadata
4. Creates filtered views:
   - By Category (Dashboard, Transactions, etc.)
   - By Type (Mobile, Desktop, Overlay)
   - By Responsive (Mobile Optimized, Desktop Optimized)
5. Establishes links between related screens

**Notion Base URL:** https://www.notion.so/337e7ace976781eb95d4cf01bba3a5dc

**Database URL:** https://www.notion.so/5ab55a87954f42b79e8b845d06ade5cf

**Data Source ID:** `0c9b8773-8b66-4890-99e5-3bf44cb6edd1`

## Technical Details

### Stack
- Language: Python 3
- Dependencies: None (uses standard library)
- Stitch Integration: HTML parsing, metadata extraction
- Notion Integration: Notion API v1

### Processing Steps
1. Scan source directory for screen folders
2. Parse HTML code files
3. Extract component tree
4. Identify CSS patterns and classes
5. Categorize screens
6. Generate metadata
7. Create output in requested format

### Metadata Extraction
- HTML Parser: Identifies components, classes, IDs
- Responsive Detection: Media queries, mobile/desktop naming
- Layout Analysis: CSS classnames (grid, flex, absolute)
- Component Inventory: Button, input, form, canvas, svg counts

## Troubleshooting

### Missing Screens
- Check source directory has subdirectories with `code.html` and `screen.png`
- Verify `--sourceDir` parameter points to correct location

### Notion Integration Issues
- Validate `notionToken` is active and has API access
- Check token has permissions to create pages and databases
- Ensure parent page ID is accessible

### Parse Errors
- Some screens may not have code.html (e.g., design mockups)
- These are marked with `parse_error` in metadata
- Image exports still available for reference

## Related Documentation

- [Stitch Design System](../docs/MASTER_UI_SOURCES.md)
- [OWFinance UI/UX Architecture](../docs/ARQUITECTURA_PROYECTO.md)
- [Responsive Layout Patterns](../docs/10-layout-refactor-legacy-pro-lite-mini-spec.md)

## Maintainers

- Created: 2026-04-02
- Last Updated: 2026-04-02
- Status: Stable

## License

Internal use only - OWFinance 2026 project
