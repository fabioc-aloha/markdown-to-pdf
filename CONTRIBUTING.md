# Contributing to Markdown to PDF Converter

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/fabioc-aloha/markdown-to-pdf/issues) to avoid duplicates
2. Use the bug report template when creating a new issue
3. Include:
   - PowerShell version (`$PSVersionTable.PSVersion`)
   - Pandoc version (`pandoc --version`)
   - LaTeX distribution and version
   - Minimal markdown file that reproduces the issue
   - Full error message or unexpected output

### Suggesting Features

1. Check existing issues and discussions first
2. Use the feature request template
3. Describe the use case and expected behavior
4. Consider how it fits with existing features

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test with various markdown files
5. Update documentation if needed
6. Submit a pull request

## Development Setup

### Prerequisites

- PowerShell 5.1+ (or PowerShell Core 7+)
- Pandoc 2.x or later
- TeX Live or MiKTeX
- (Optional) Mermaid CLI for diagram testing

### Testing Your Changes

```powershell
# Basic test
.\convert-to-pdf.ps1 -File sample.md

# Test with all features
.\convert-to-pdf.ps1 -File sample.md -Draft -Confidential -LineNumbers -Toc all
```

### Code Style

- Use meaningful variable names
- Add comments for complex logic
- Follow PowerShell best practices
- Keep functions focused and testable

## Documentation

- Update README.md for user-facing changes
- Update docs/ for detailed documentation
- Add CHANGELOG.md entries for all changes

## Questions?

Open a [discussion](https://github.com/fabioc-aloha/markdown-to-pdf/discussions) or issue if you need help.

Thank you for contributing! 🎉
