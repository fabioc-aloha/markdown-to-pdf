# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do not** open a public issue
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Considerations

This tool processes markdown files and executes:
- **Pandoc** for document conversion
- **LaTeX** for PDF generation
- **Mermaid CLI** (optional) for diagram rendering

### Best Practices

- Only convert trusted markdown files
- Review markdown content before conversion, especially from external sources
- Keep Pandoc, LaTeX, and Mermaid CLI updated
- Run in a sandboxed environment for untrusted content

## Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 1 week
- **Fix Timeline**: Depends on severity

Thank you for helping keep this project secure!
