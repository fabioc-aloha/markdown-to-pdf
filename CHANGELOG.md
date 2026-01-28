# Changelog

All notable changes to the Markdown to PDF Converter.

## [1.0.0] - 2025-01-28

### Added

- **Core Conversion**
  - Markdown to PDF conversion via Pandoc and XeLaTeX
  - APA 7th edition formatting with Times New Roman font
  - Automatic fallback to pdflatex if xelatex unavailable

- **Cover Pages**
  - `[title]...[/title]` markers for professional title pages
  - Automatic extraction of title, author, and date for PDF metadata
  - Support for markdown formatting within title blocks

- **Table of Contents**
  - `[toc]` - Basic table of contents
  - `[toc:figures]` - TOC with list of figures
  - `[toc:tables]` - TOC with list of tables
  - `[toc:all]` - TOC with both lists

- **Mermaid Diagrams**
  - Automatic rendering of Mermaid diagram blocks
  - Intelligent scaling based on diagram dimensions
  - Support for flowcharts, sequence diagrams, class diagrams, Gantt charts

- **Callout Boxes**
  - Five GitHub-style alert types: NOTE, TIP, WARNING, IMPORTANT, CAUTION
  - Colored backgrounds with icons
  - Multi-line support

- **Page Layout**
  - `[pagebreak]` markers for manual page breaks
  - Running title in header (customizable via `-RunningTitle`)
  - "Page X of Y" numbering
  - Configurable line spacing

- **Document Modes**
  - `-Draft` flag for DRAFT watermark overlay
  - `-Confidential` flag for confidential footer with rule
  - `-LineNumbers` flag for code block line numbers
  - `-TwoColumn` flag for newsletter layout

- **Tables**
  - Automatic smaller font and single spacing
  - Tables kept together (no page breaks within)
  - Bottom border enforcement
  - Caption support with `Table:` prefix

- **Figures**
  - Caption extraction from image alt text
  - Width control with `{ width=X% }` syntax
  - Automatic figure numbering

- **Typography**
  - Disabled word hyphenation for cleaner text
  - Widow and orphan control
  - Inline code highlighting with background

- **Bibliography**
  - APA 7th edition citation style (CSL)
  - BibTeX bibliography support
  - Parenthetical and narrative citations

- **Utilities**
  - `-OpenAfterBuild` to auto-open generated PDF
  - Smart horizontal rule removal before section headers
  - Dependency checking with helpful messages

### Documentation

- README.md with feature overview and quick start
- INSTALLATION.md with step-by-step setup guide
- USER_GUIDE.md with comprehensive usage instructions
- TROUBLESHOOTING.md with common issues and solutions
- sample.md demonstrating all features

---

## Future Roadmap

### Planned Features

- [ ] Custom CSS/styling support
- [ ] HTML output option
- [ ] DOCX output option
- [ ] Template system for different document types
- [ ] Batch conversion of multiple files
- [ ] Watch mode for live preview
- [ ] Custom LaTeX preamble injection
- [ ] Alternative citation styles (MLA, Chicago, IEEE)

### Under Consideration

- Cross-platform shell script version (bash)
- GUI wrapper application
- VS Code extension integration
- Custom Mermaid themes
