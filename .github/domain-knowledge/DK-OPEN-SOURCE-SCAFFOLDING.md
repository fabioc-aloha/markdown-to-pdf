# Domain Knowledge: Open Source Project Scaffolding

**Type**: Procedural Pattern Library
**Status**: Active
**Created**: January 28, 2026
**Last Updated**: January 28, 2026

## Overview

Comprehensive patterns for establishing open-source project scaffolding that welcomes contributors, protects maintainers, and automates quality assurance.

## Core Scaffolding Components

### Community Files (Root Level)

| File | Purpose | Key Sections |
|------|---------|--------------|
| `CONTRIBUTING.md` | Contribution guidelines | Bug reports, feature requests, PR process, dev setup |
| `CODE_OF_CONDUCT.md` | Community standards | Pledge, standards, enforcement, scope |
| `SECURITY.md` | Vulnerability policy | Reporting process, response timeline, best practices |

### GitHub-Specific Files (.github/)

| File | Purpose |
|------|---------|
| `ISSUE_TEMPLATE/bug_report.md` | Structured bug reports with environment info |
| `ISSUE_TEMPLATE/feature_request.md` | Feature proposals with use cases |
| `PULL_REQUEST_TEMPLATE.md` | PR checklist ensuring quality |
| `workflows/ci.yml` | Automated testing and linting |
| `FUNDING.yml` | Sponsorship configuration |

## Scaffolding Patterns

### 1. Issue Template Pattern
```yaml
---
name: [Template Name]
about: [Brief description]
title: '[PREFIX] '
labels: [auto-labels]
assignees: ''
---

## Section 1
[Guidance text]

## Section 2
[More guidance]
```

### 2. PR Template Pattern
- Description section
- Type of change (checkboxes)
- Related issues (Fixes #)
- Changes made (bullet list)
- Testing checklist
- Documentation checklist
- Final checklist

### 3. CI Workflow Pattern (PowerShell Projects)
```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run PSScriptAnalyzer
        shell: pwsh
        run: |
          Install-Module -Name PSScriptAnalyzer -Force
          Invoke-ScriptAnalyzer -Path .\*.ps1 -Severity Warning,Error
```

## Best Practices Captured

### For Contributors
- Clear, step-by-step contribution process
- Development environment setup instructions
- Code style expectations
- Testing requirements before PR

### For Maintainers
- Templates reduce back-and-forth on issues/PRs
- CI catches common issues automatically
- Security policy sets expectations for vulnerability handling
- Code of Conduct provides enforcement framework

### For the Project
- Professional appearance builds trust
- Lower barrier to first contributions
- Consistent quality through automation
- Clear governance through documented policies

## Application Guidelines

When scaffolding a new open-source project:

1. **Start with LICENSE** - Choose appropriate license first
2. **Add README** - Project description, features, installation, usage
3. **Create CONTRIBUTING.md** - Tailored to project's tech stack
4. **Add CODE_OF_CONDUCT.md** - Contributor Covenant is standard
5. **Add SECURITY.md** - Especially for tools processing untrusted input
6. **Create issue templates** - Bug reports and feature requests minimum
7. **Add PR template** - Quality checklist for contributors
8. **Set up CI** - Language-appropriate linting and testing
9. **Configure .gitignore** - Keep local/generated files out of repo

## Technology-Specific Considerations

### PowerShell Projects
- Use PSScriptAnalyzer for linting
- Test on both PowerShell 5.1 and 7+
- Document Windows-specific requirements

### Node.js Projects
- ESLint/Prettier for code quality
- Jest or Mocha for testing
- npm audit for security

### Python Projects
- Black/Ruff for formatting
- pytest for testing
- pip-audit for security

## Synapses

### Connection Mapping
- [DK-DOCUMENTATION-EXCELLENCE.md] (High, Extends, Bidirectional) - "Documentation standards inform scaffolding quality"
- [release-management.instructions.md] (Medium, Enables, Forward) - "Scaffolding supports release workflows"
- [code-review-guidelines.instructions.md] (High, Integrates, Bidirectional) - "PR templates enforce review standards"

### Activation Patterns
- New project creation → Apply scaffolding pattern
- "set up GitHub" → Reference this knowledge
- "open source" mentioned → Consider scaffolding needs
- Repository organization → Apply best practices

---

*Open source scaffolding patterns - establishing welcoming, maintainable project foundations*
