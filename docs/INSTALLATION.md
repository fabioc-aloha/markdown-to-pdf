# Installation Guide

This guide walks you through installing all required dependencies for the Markdown to PDF Converter.

## System Requirements

- **Operating System**: Windows 10/11, macOS, or Linux
- **PowerShell**: Version 5.1 or later (Windows) or PowerShell Core 7+ (cross-platform)
- **Disk Space**: ~2-4 GB for LaTeX distribution

## Required Dependencies

### 1. Pandoc

Pandoc is the universal document converter that handles the markdown processing.

#### Windows

**Option A: Using winget (recommended)**

```powershell
winget install --id JohnMacFarlane.Pandoc
```

**Option B: Using Chocolatey**

```powershell
choco install pandoc
```

**Option C: Manual Installation**

1. Download from [pandoc.org/installing.html](https://pandoc.org/installing.html)
2. Run the installer
3. Restart your terminal

#### macOS

```bash
brew install pandoc
```

#### Linux (Ubuntu/Debian)

```bash
sudo apt-get install pandoc
```

#### Verify Installation

```powershell
pandoc --version
```

Expected output: `pandoc 3.x.x` or similar

---

### 2. LaTeX Distribution

LaTeX handles the PDF generation with professional typesetting.

#### Windows

**Option A: MiKTeX (recommended for Windows)**

1. Download from [miktex.org/download](https://miktex.org/download)
2. Run the installer
3. Choose "Install missing packages on-the-fly: Yes"
4. Restart your terminal

**Option B: TeX Live**

```powershell
winget install --id TeXLive.TeXLive
```

#### macOS

**Option A: MacTeX (recommended)**

```bash
brew install --cask mactex
```

**Option B: BasicTeX (smaller)**

```bash
brew install --cask basictex
```

#### Linux (Ubuntu/Debian)

```bash
sudo apt-get install texlive-xetex texlive-fonts-recommended texlive-fonts-extra
```

#### Verify Installation

```powershell
xelatex --version
```

Expected output: `XeTeX 3.x` or similar

---

### 3. Required LaTeX Packages

The converter uses these LaTeX packages (most are included by default):

| Package | Purpose |
| ------- | ------- |
| `tcolorbox` | Callout boxes |
| `enumitem` | List formatting |
| `lastpage` | "Page X of Y" numbering |
| `draftwatermark` | DRAFT watermark |
| `hyperref` | Clickable links |
| `caption` | Figure/table captions |
| `longtable` | Multi-page tables |
| `booktabs` | Professional table rules |
| `float` | Figure placement |
| `fancyhdr` | Headers and footers |
| `fontspec` | Font selection (XeLaTeX) |
| `titlesec` | Section formatting |
| `xcolor` | Color support |
| `fvextra` | Code line numbers |

**MiKTeX**: Packages install automatically on first use.

**TeX Live**: Install missing packages:

```bash
tlmgr install tcolorbox draftwatermark fvextra
```

---

## Optional Dependencies

### 4. Mermaid CLI (for diagrams)

Mermaid CLI renders flowcharts, sequence diagrams, and other visualizations.

#### Prerequisites

Node.js must be installed first:

**Windows**

```powershell
winget install --id OpenJS.NodeJS
```

**macOS**

```bash
brew install node
```

**Linux**

```bash
sudo apt-get install nodejs npm
```

#### Install Mermaid CLI

```bash
npm install -g @mermaid-js/mermaid-cli
```

#### Verify Installation

```bash
mmdc --version
```

Expected output: `3.x.x` or similar

---

### 5. Times New Roman Font

The converter uses Times New Roman for APA-compliant formatting.

- **Windows**: Included by default
- **macOS**: Included with Microsoft Office, or install via:
  ```bash
  brew install --cask font-times-new-roman
  ```
- **Linux**: Install Microsoft fonts:
  ```bash
  sudo apt-get install ttf-mscorefonts-installer
  ```

---

## Verification Checklist

Run these commands to verify your installation:

```powershell
# Check Pandoc
pandoc --version

# Check LaTeX
xelatex --version

# Check Mermaid (optional)
mmdc --version

# Check Node.js (if using Mermaid)
node --version
```

## Quick Test

After installation, test the converter:

```powershell
cd c:\Development\markdown-to-pdf
.\convert-to-pdf.ps1 -File "sample.md" -OpenAfterBuild
```

If successful, the sample PDF will open automatically.

## Troubleshooting

### "pandoc: command not found"

- Restart your terminal after installation
- Verify PATH includes Pandoc installation directory

### "xelatex: command not found"

- Restart your terminal after installing LaTeX
- Windows: Ensure MiKTeX/TeX Live bin directory is in PATH

### "mmdc: command not found"

- Verify Node.js is installed: `node --version`
- Reinstall: `npm install -g @mermaid-js/mermaid-cli`

### Missing LaTeX packages

MiKTeX should auto-install. For TeX Live:

```bash
tlmgr install <package-name>
```

### Font not found

If Times New Roman isn't available, edit the script to use a different font, or install the font for your OS.

## Next Steps

- Read the [User Guide](USER_GUIDE.md) for detailed usage instructions
- Try the [sample.md](../sample.md) to see all features in action
