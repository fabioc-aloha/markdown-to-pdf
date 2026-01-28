# Troubleshooting Guide

Solutions to common issues with the Markdown to PDF Converter.

## Table of Contents

1. [Dependency Issues](#dependency-issues)
2. [Conversion Errors](#conversion-errors)
3. [Formatting Problems](#formatting-problems)
4. [Diagram Issues](#diagram-issues)
5. [Performance Issues](#performance-issues)

---

## Dependency Issues

### Pandoc Not Found

**Symptom:**

```
Error: Pandoc not found. Please install from https://pandoc.org
```

**Solutions:**

1. **Verify installation:**
   ```powershell
   pandoc --version
   ```

2. **Restart terminal** after installing Pandoc

3. **Check PATH** (Windows):
   - Open System Properties → Environment Variables
   - Ensure `C:\Program Files\Pandoc` is in PATH

4. **Reinstall:**
   ```powershell
   winget install --id JohnMacFarlane.Pandoc
   ```

---

### LaTeX/XeLaTeX Not Found

**Symptom:**

```
xelatex: command not found
```

**Solutions:**

1. **Install a LaTeX distribution:**
   - Windows: [MiKTeX](https://miktex.org/download)
   - macOS: `brew install --cask mactex`
   - Linux: `sudo apt-get install texlive-xetex`

2. **Restart terminal** after installation

3. **Check PATH:**
   ```powershell
   # Find xelatex location
   Get-Command xelatex
   ```

4. **Use pdflatex fallback** - The script automatically falls back to pdflatex if xelatex isn't available

---

### Missing LaTeX Packages

**Symptom:**

```
! LaTeX Error: File `tcolorbox.sty' not found.
```

**Solutions:**

**MiKTeX (Windows):**
- Should auto-install on first use
- Enable "Install missing packages on-the-fly" in MiKTeX Console
- Manual install: `mpm --install tcolorbox`

**TeX Live:**
```bash
tlmgr install tcolorbox draftwatermark fvextra booktabs caption float fancyhdr
```

**Common packages needed:**

| Package | Purpose |
| ------- | ------- |
| tcolorbox | Callout boxes |
| draftwatermark | DRAFT watermark |
| fvextra | Line numbers in code |
| booktabs | Table formatting |
| lastpage | "Page X of Y" |

---

### Mermaid CLI Not Found

**Symptom:**

```
- Mermaid CLI: Not found (diagrams disabled)
```

**Solutions:**

1. **Install Node.js first:**
   ```powershell
   winget install --id OpenJS.NodeJS
   ```

2. **Install Mermaid CLI:**
   ```bash
   npm install -g @mermaid-js/mermaid-cli
   ```

3. **Restart terminal**

4. **Verify:**
   ```bash
   mmdc --version
   ```

5. **Check npm global path:**
   ```bash
   npm config get prefix
   ```
   Ensure this path is in your system PATH.

---

## Conversion Errors

### "File not found"

**Symptom:**

```
File not found: document.md
```

**Solutions:**

1. **Use absolute path:**
   ```powershell
   .\convert-to-pdf.ps1 -File "C:\full\path\to\document.md"
   ```

2. **Check current directory:**
   ```powershell
   Get-Location
   ```

3. **Verify file exists:**
   ```powershell
   Test-Path "document.md"
   ```

---

### LaTeX Compilation Errors

**Symptom:**

```
! Missing $ inserted.
```
or
```
! Undefined control sequence.
```

**Solutions:**

1. **Check for special characters** in your markdown:
   - `&` should be `\&` in tables (auto-handled in callouts)
   - `%` in text may cause issues
   - `$` triggers math mode
   - `#` outside headers
   - `_` in plain text

2. **Escape special characters:**
   ```markdown
   Revenue increased 15\% this quarter.
   The AT\&T merger...
   ```

3. **Check callout content** for unescaped characters

4. **Review the temp file** (kept on error):
   - Look for `_temp_*.md` in the script directory
   - Check for problematic content

---

### PDF Not Generated

**Symptom:**

```
- Failed to generate PDF
```

**Solutions:**

1. **Check the pandoc output** displayed after failure

2. **Run pandoc manually** to see detailed errors:
   ```powershell
   pandoc document.md -o test.pdf --pdf-engine=xelatex 2>&1
   ```

3. **Simplify the document** to isolate the problem:
   - Remove diagrams
   - Remove callouts
   - Remove tables
   - Test each section

---

## Formatting Problems

### Font Not Found

**Symptom:**

```
! fontspec error: "font-not-found"
```

**Solutions:**

1. **Install Times New Roman:**
   - Windows: Included by default
   - macOS: Install Microsoft Office or fonts package
   - Linux: `sudo apt-get install ttf-mscorefonts-installer`

2. **Use a different font** - Edit the script:
   ```latex
   \setmainfont{DejaVu Serif}  % or another available font
   ```

3. **List available fonts:**
   ```bash
   fc-list | grep -i "times"
   ```

---

### Tables Breaking Across Pages

**Symptom:** Tables split awkwardly between pages

**Solutions:**

1. Tables are wrapped in minipage by default to prevent breaks
2. For very long tables, consider splitting manually
3. Add `[pagebreak]` before large tables

---

### Two-Column Tables Look Wrong

**Symptom:** Tables render as plain text in two-column mode

**Explanation:** This is expected behavior. LaTeX longtable is incompatible with two-column layout.

**Solutions:**

1. Avoid `-TwoColumn` for table-heavy documents
2. Use simpler data presentation (lists instead of tables)
3. Create table images and include as figures

---

### Header/Footer Not Showing

**Symptom:** Running title or page numbers missing

**Solutions:**

1. First page is intentionally styled differently (no header)
2. Check that document has multiple pages
3. Verify `-RunningTitle` parameter if using custom header

---

### Code Blocks Not Styled

**Symptom:** Code appears without syntax highlighting

**Solutions:**

1. Specify the language:
   ````markdown
   ```python
   code here
   ```
   ````

2. Supported languages: python, javascript, powershell, bash, json, yaml, sql, and many more

---

## Diagram Issues

### Diagrams Not Rendering

**Symptom:** Mermaid code appears as text

**Solutions:**

1. **Verify Mermaid CLI:**
   ```bash
   mmdc --version
   ```

2. **Check syntax** - Test at [mermaid.live](https://mermaid.live)

3. **Review script output** for rendering errors

4. **Check temporary files** in `.figures/` directory

---

### Diagram Too Large/Small

**Symptom:** Diagram doesn't fit well on page

**Solutions:**

1. The script auto-scales diagrams - usually no action needed

2. **Simplify complex diagrams:**
   - Use shorter labels
   - Reduce nodes
   - Split into multiple diagrams

3. **Add page break** before large diagrams:
   ```markdown
   [pagebreak]

   ```mermaid
   ...
   ```
   ```

---

### Diagram Rendering Fails

**Symptom:**

```
- Failed to render diagram X
```

**Solutions:**

1. **Check Mermaid syntax** at [mermaid.live](https://mermaid.live)

2. **Common syntax errors:**
   - Missing direction (`flowchart TD` not just `flowchart`)
   - Unclosed brackets
   - Special characters in labels

3. **Update Mermaid CLI:**
   ```bash
   npm update -g @mermaid-js/mermaid-cli
   ```

4. **Check puppeteer/chromium** (Mermaid dependency):
   ```bash
   npm install -g puppeteer
   ```

---

## Performance Issues

### Slow Conversion

**Causes and solutions:**

1. **Many diagrams** - Each adds 1-2 seconds
   - Reduce diagram count if possible
   - Pre-render diagrams as images

2. **First run** - LaTeX packages downloading
   - MiKTeX: Initial installs take time
   - Subsequent runs are faster

3. **Large documents** - More processing time
   - Consider splitting into multiple files

4. **Complex tables** - LaTeX processing overhead
   - Simplify table structure

---

### High Memory Usage

**Solutions:**

1. **Close other applications** during conversion

2. **Process smaller documents**

3. **Reduce diagram complexity**

4. **Check for infinite loops** in Mermaid syntax

---

## Getting More Help

### Enable Verbose Output

Check the temporary markdown file for debugging:

```powershell
# Look for temp files
Get-ChildItem "_temp_*.md"
```

### Manual Pandoc Test

```powershell
pandoc document.md -o test.pdf --pdf-engine=xelatex -V geometry:margin=1in --verbose
```

### Check Pandoc/LaTeX Logs

```powershell
# Pandoc with more output
pandoc document.md -o test.pdf --pdf-engine=xelatex 2>&1 | Out-File pandoc-log.txt
```

### Report Issues

When reporting problems, include:

1. PowerShell version: `$PSVersionTable.PSVersion`
2. Pandoc version: `pandoc --version`
3. LaTeX version: `xelatex --version`
4. Error message (full text)
5. Minimal markdown that reproduces the issue
