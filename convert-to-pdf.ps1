<#
.SYNOPSIS
    Markdown to PDF Converter - Professional document conversion with APA 7th edition formatting.

.DESCRIPTION
    Converts Markdown files to professionally formatted PDF documents using Pandoc and XeLaTeX.
    Supports cover pages, table of contents, Mermaid diagrams, callout boxes, and more.

.PARAMETER File
    Path to the Markdown file to convert (required).

.PARAMETER LineSpacing
    Line spacing multiplier. Default is 1.5.

.PARAMETER Draft
    Adds a "DRAFT" watermark to all pages.

.PARAMETER Confidential
    Adds "CONFIDENTIAL" footer with a rule line on all pages.

.PARAMETER LineNumbers
    Shows line numbers in code blocks (code review mode).

.PARAMETER TwoColumn
    Uses a two-column newsletter-style layout. Note: tables render as text in this mode.

.PARAMETER RunningTitle
    Custom running title for the page header. Overrides the document title.

.PARAMETER OpenAfterBuild
    Automatically opens the generated PDF after conversion.

.EXAMPLE
    .\convert-to-pdf.ps1 -File "document.md"
    
.EXAMPLE
    .\convert-to-pdf.ps1 -File "document.md" -Draft -Confidential -OpenAfterBuild

.EXAMPLE
    .\convert-to-pdf.ps1 -File "document.md" -LineSpacing 1.15 -RunningTitle "Short Title"

.NOTES
    Dependencies:
    - Pandoc (required)
    - XeLaTeX or pdfLaTeX (required)
    - Mermaid CLI (optional, for diagram rendering)
    - Times New Roman font (for APA formatting)

    Markdown Extensions Supported:
    - [title]...[/title] - Cover page content
    - [toc], [toc:figures], [toc:tables], [toc:all] - Table of contents
    - [pagebreak] - Manual page break
    - > [!NOTE], > [!TIP], > [!WARNING], > [!IMPORTANT], > [!CAUTION] - Callout boxes
    - ```mermaid - Mermaid diagrams with intelligent scaling
    - Table: Caption - Table captions
    - ![Caption](image.png) - Figure captions
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$File,
    
    [double]$LineSpacing = 1.5,
    [switch]$Draft,
    [switch]$Confidential,
    [switch]$LineNumbers,
    [switch]$TwoColumn,
    [string]$RunningTitle,
    [switch]$OpenAfterBuild
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FiguresDir = Join-Path $ScriptDir ".figures"
$BibFile = Join-Path $ScriptDir "references\bibliography.bib"
$CslFile = Join-Path $ScriptDir "references\apa-7th-edition.csl"

# Check for Mermaid CLI
$mmdcPath = Get-Command mmdc -ErrorAction SilentlyContinue
$hasMermaid = $null -ne $mmdcPath

# Check for LaTeX engine
$xelatexPath = Get-Command xelatex -ErrorAction SilentlyContinue
$pdfEngine = if ($xelatexPath) { "xelatex" } else { "pdflatex" }

# Check for bibliography support
$hasBibliography = (Test-Path $BibFile) -and (Test-Path $CslFile)

#region Functions

function ConvertTo-MermaidDiagrams {
    param(
        [string]$Content,
        [string]$BaseName
    )
    
    if (-not $hasMermaid) {
        return @{ Content = $Content; DiagramCount = 0 }
    }
    
    $mermaidPattern = '(?s)```mermaid\r?\n(.+?)```'
    $mermaidMatches = [regex]::Matches($Content, $mermaidPattern)
    
    if ($mermaidMatches.Count -eq 0) {
        return @{ Content = $Content; DiagramCount = 0 }
    }
    
    if (-not (Test-Path $FiguresDir)) {
        New-Item -ItemType Directory -Path $FiguresDir -Force | Out-Null
    }
    
    $diagramCount = 0
    $figureIndex = 1
    $processedContent = $Content
    
    foreach ($match in $mermaidMatches) {
        $mermaidCode = $match.Groups[1].Value
        $figName = "${BaseName}_fig${figureIndex}"
        $mmdFile = Join-Path $FiguresDir "$figName.mmd"
        $pngFile = Join-Path $FiguresDir "$figName.png"
        
        [System.IO.File]::WriteAllText($mmdFile, $mermaidCode, [System.Text.UTF8Encoding]::new($false))
        
        $mmdcArgs = @("-i", $mmdFile, "-o", $pngFile, "-b", "white", "-s", "5")
        $null = & mmdc @mmdcArgs 2>&1
        
        if (Test-Path $pngFile) {
            # Get image dimensions to calculate needed space
            Add-Type -AssemblyName System.Drawing
            $img = [System.Drawing.Image]::FromFile($pngFile)
            $imgWidth = $img.Width
            $imgHeight = $img.Height
            $img.Dispose()
            
            # Calculate scaling based on page space
            $scaleFactor = 468.0 / $imgWidth
            $scaledHeight = $imgHeight * $scaleFactor
            $linesNeeded = [math]::Ceiling($scaledHeight / 18) + 4
            $maxPageLines = 50
            
            if ($linesNeeded -gt $maxPageLines) {
                $widthPercent = [math]::Max([math]::Floor(($maxPageLines / $linesNeeded) * 100), 70)
                Write-Host "    - Rendered diagram $figureIndex ($imgWidth x $imgHeight px -> $widthPercent%)" -ForegroundColor Gray
            } elseif ($linesNeeded -gt 35) {
                $widthPercent = 75
                Write-Host "    - Rendered diagram $figureIndex ($imgWidth x $imgHeight px -> $widthPercent%)" -ForegroundColor Gray
            } elseif ($linesNeeded -gt 25) {
                $widthPercent = 85
                Write-Host "    - Rendered diagram $figureIndex ($imgWidth x $imgHeight px -> $widthPercent%)" -ForegroundColor Gray
            } else {
                $widthPercent = 100
                Write-Host "    - Rendered diagram $figureIndex ($imgWidth x $imgHeight px)" -ForegroundColor Gray
            }
            
            $diagramCount++
            $escapedPngPath = $pngFile.Replace('\', '/')
            $imgRef = "``````{=latex}`n\begin{center}`n```````n`n![]($escapedPngPath){ width=$widthPercent% }`n`n``````{=latex}`n\end{center}`n``````"
            $processedContent = $processedContent.Replace($match.Value, $imgRef)
        } else {
            Write-Warning "    - Failed to render diagram $figureIndex"
        }
        
        Remove-Item $mmdFile -Force -ErrorAction SilentlyContinue
        $figureIndex++
    }
    
    return @{ Content = $processedContent; DiagramCount = $diagramCount }
}

function ConvertTo-MarkdownExtensions {
    param([string]$Content)
    
    # Remove --- adjacent to [pagebreak] markers
    $Content = $Content -replace '---\s*\r?\n\s*\[pagebreak\]', '[pagebreak]'
    $Content = $Content -replace '\[pagebreak\]\s*\r?\n\s*---', '[pagebreak]'
    
    # Remove --- immediately before section headings
    $Content = $Content -replace '(?m)^---\s*\r?\n\s*\r?\n##\s', '## '
    $Content = $Content -replace '(?m)^---\s*\r?\n##\s', '## '
    
    # Remove --- at document end
    $Content = $Content -replace '\r?\n---\s*$', ''
    
    # Process [pagebreak] markers
    $Content = $Content -replace '\[pagebreak\]', "``````{=latex}`n\newpage`n``````"
    
    # Process callout boxes
    $calloutTypes = @{
        'NOTE' = @{ color = 'blue!10'; border = 'blue!50'; icon = '\textbf{📝 Note:}' }
        'TIP' = @{ color = 'green!10'; border = 'green!50'; icon = '\textbf{💡 Tip:}' }
        'WARNING' = @{ color = 'yellow!15'; border = 'orange!50'; icon = '\textbf{⚠️ Warning:}' }
        'IMPORTANT' = @{ color = 'purple!10'; border = 'purple!50'; icon = '\textbf{❗ Important:}' }
        'CAUTION' = @{ color = 'red!10'; border = 'red!50'; icon = '\textbf{🔴 Caution:}' }
    }
    
    foreach ($type in $calloutTypes.Keys) {
        $style = $calloutTypes[$type]
        $pattern = "(?m)^>\s*\[!$type\]\s*\r?\n((?:^>.*\r?\n?)+)"
        $Content = [regex]::Replace($Content, $pattern, {
            param($m)
            $calloutContent = $m.Groups[1].Value -replace '(?m)^>\s?', ''
            $calloutContent = $calloutContent.Trim() -replace '&', '\&' -replace '%', '\%'
            "``````{=latex}`n\begin{tcolorbox}[colback=$($style.color),colframe=$($style.border),left=2mm,right=2mm,top=1mm,bottom=1mm]`n$($style.icon) $calloutContent`n\end{tcolorbox}`n``````"
        })
    }
    
    # Process figure captions
    $Content = [regex]::Replace($Content, '!\[([^\]]+)\]\(([^)]+)\)(\{[^}]*\})?', {
        param($m)
        $caption = $m.Groups[1].Value
        $path = $m.Groups[2].Value
        $attrs = $m.Groups[3].Value
        if ($caption -and $caption -ne '') {
            $width = "width=\textwidth"
            if ($attrs -match 'width=(\d+)%') {
                $widthPct = [int]$Matches[1] / 100
                $width = "width=$widthPct\textwidth"
            }
            "``````{=latex}`n\begin{figure}[H]`n\centering`n\includegraphics[$width]{$path}`n\caption{$caption}`n\end{figure}`n``````"
        } else {
            $m.Value
        }
    })
    
    # Process table captions
    $Content = $Content -replace '(?m)^Table:\s*(.+)$', "``````{=latex}`n\captionof{table}{`$1}`n``````"
    
    return $Content
}

function Get-DocumentStructure {
    param([string]$Content)
    
    $result = @{
        HasTitle = $false
        HasToc = $false
        TitleContent = ""
        MainTitle = ""
        Authors = ""
        Date = ""
        BodyContent = $Content
    }
    
    # Look for [title]...[/title] markers
    if ($Content -match '(?s)\[title\]\s*\r?\n(.+?)\[/title\]') {
        $titleSection = $Matches[1].Trim()
        $result.HasTitle = $true
        
        if ($titleSection -match '^#\s+(.+?)(\r?\n|$)') {
            $result.MainTitle = $Matches[1].Trim()
            $titleSection = $titleSection -replace '^#\s+.+?(\r?\n|$)', ''
        }
        
        if ($titleSection -match '\*\*Authors?\*\*:?\s*(.+?)(\r?\n|$)') {
            $result.Authors = $Matches[1].Trim()
        } elseif ($titleSection -match '([A-Z][a-z]+ [A-Z][a-z]+)\s*[&]\s*([A-Z][a-z]+ [A-Z][a-z]+)') {
            $result.Authors = $Matches[0].Trim()
        }
        
        if ($titleSection -match '(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},?\s+\d{4}') {
            $result.Date = $Matches[0].Trim()
        } elseif ($titleSection -match '\d{4}-\d{2}-\d{2}') {
            $result.Date = $Matches[0].Trim()
        }
        
        $titleSection = $titleSection -replace '<div[^>]*>', '' -replace '</div>', ''
        $result.TitleContent = $titleSection.Trim()
        $Content = $Content -replace '(?s)\[title\]\s*\r?\n.+?\[/title\]\s*\r?\n?', ''
    }
    
    # Look for [toc] marker
    if ($Content -match '\[toc(:[\w,]+)?\]') {
        $tocFlags = $Matches[1]
        $result.HasToc = $true
        
        $titleRepeat = ""
        if ($result.MainTitle) {
            $titleRepeat = "`n`n# " + $result.MainTitle + "`n"
        }
        
        $tocContent = "\tableofcontents"
        if ($tocFlags -match 'figures|all') { $tocContent += "`n\listoffigures" }
        if ($tocFlags -match 'tables|all') { $tocContent += "`n\listoftables" }
        
        $tocReplacement = "``````{=latex}`n$tocContent`n\newpage`n``````" + $titleRepeat
        $Content = $Content -replace '\[toc(:[\w,]+)?\]\s*(\r?\n---\s*)?(\r?\n)?', $tocReplacement
    }
    
    $result.BodyContent = $Content
    return $result
}

function New-YamlHeader {
    param(
        [double]$Spacing,
        [string]$Title,
        [string]$Author
    )
    
    $yaml = "---`n"
    $yaml += "documentclass: article`n"
    $yaml += "geometry: `"margin=1in`"`n"
    $yaml += "fontsize: 12pt`n"
    $yaml += "linestretch: $Spacing`n"
    $yaml += "link-citations: true`n"
    $yaml += "header-includes:`n"
    
    # Page setup
    $yaml += "  - \usepackage{setspace}`n"
    $yaml += "  - \usepackage{fancyhdr}`n"
    $yaml += "  - \usepackage{lastpage}`n"
    $yaml += "  - \pagestyle{fancy}`n"
    $yaml += "  - \fancyhf{}`n"
    
    # Running title
    $displayTitle = if ($script:RunningTitle) { $script:RunningTitle } elseif ($Title) { $Title } else { "" }
    $yaml += "  - \fancyhead[L]{\small\textit{$displayTitle}}`n"
    $yaml += "  - \fancyhead[R]{\small\thepage\ of \pageref{LastPage}}`n"
    
    # Footer
    if ($script:Confidential) {
        $yaml += "  - \fancyfoot[C]{\small\textbf{CONFIDENTIAL}}`n"
        $yaml += "  - \renewcommand{\footrulewidth}{0.4pt}`n"
    } else {
        $yaml += "  - \fancyfoot[C]{}`n"
    }
    $yaml += "  - \renewcommand{\headrulewidth}{0.4pt}`n"
    
    # Draft watermark
    if ($script:Draft) {
        $yaml += "  - \usepackage{draftwatermark}`n"
        $yaml += "  - \SetWatermarkText{DRAFT}`n"
        $yaml += "  - \SetWatermarkScale{1}`n"
        $yaml += "  - \SetWatermarkColor[gray]{0.9}`n"
    }
    
    # Floats and tables
    $yaml += "  - \usepackage{float}`n"
    $yaml += "  - \floatplacement{figure}{H}`n"
    $yaml += "  - \floatplacement{table}{H}`n"
    $yaml += "  - \usepackage{longtable}`n"
    $yaml += "  - \usepackage{booktabs}`n"
    $yaml += "  - \usepackage{etoolbox}`n"
    $yaml += "  - \AtBeginEnvironment{longtable}{\small\setstretch{1.0}}`n"
    $yaml += "  - \AtBeginEnvironment{tabular}{\small\setstretch{1.0}}`n"
    $yaml += "  - \AtEndEnvironment{longtable}{\bottomrule}`n"
    $yaml += "  - \let\oldlongtable\longtable`n"
    $yaml += "  - \def\longtable{\begin{minipage}{\textwidth}\vspace{0.5em}\oldlongtable}`n"
    $yaml += "  - \let\oldendlongtable\endlongtable`n"
    $yaml += "  - \def\endlongtable{\oldendlongtable\end{minipage}}`n"
    
    # Graphics
    $yaml += "  - \usepackage{graphicx}`n"
    $yaml += "  - \usepackage{grffile}`n"
    $yaml += "  - \usepackage{caption}`n"
    $yaml += "  - \captionsetup[figure]{labelfont=bf}`n"
    $yaml += "  - \captionsetup[table]{labelfont=bf}`n"
    
    # Fonts and formatting
    $yaml += "  - \AtBeginDocument{\thispagestyle{empty}}`n"
    $yaml += "  - \usepackage{fontspec}`n"
    $yaml += "  - \setmainfont{Times New Roman}`n"
    $yaml += "  - \usepackage{titlesec}`n"
    $yaml += "  - \usepackage{needspace}`n"
    $yaml += "  - \titleformat{\section}{\normalfont\Large\bfseries}{}{0em}{}`n"
    $yaml += "  - \titleformat{\subsection}{\normalfont\large\bfseries}{}{0em}{}`n"
    $yaml += "  - \titleformat{\subsubsection}{\normalfont\normalsize\bfseries}{}{0em}{}`n"
    
    # Callout boxes
    $yaml += "  - \usepackage[most]{tcolorbox}`n"
    
    # Hyperlinks and metadata
    $hyperrefOptions = "colorlinks=true,linkcolor=blue,urlcolor=blue,citecolor=blue"
    if ($Title) { $hyperrefOptions += ",pdftitle={$($Title -replace '"', "'" -replace '\\', '')}" }
    if ($Author) { $hyperrefOptions += ",pdfauthor={$($Author -replace '"', "'" -replace '\\', '')}" }
    $yaml += "  - \usepackage[$hyperrefOptions]{hyperref}`n"
    
    # Typography
    $yaml += "  - \widowpenalty=10000`n"
    $yaml += "  - \clubpenalty=10000`n"
    $yaml += "  - \hyphenpenalty=10000`n"
    $yaml += "  - \exhyphenpenalty=10000`n"
    
    # Lists
    $yaml += "  - \usepackage{enumitem}`n"
    $yaml += "  - \setlist{nosep,leftmargin=*}`n"
    
    # Code styling
    $yaml += "  - \usepackage{xcolor}`n"
    $yaml += "  - \definecolor{codebg}{gray}{0.95}`n"
    $yaml += "  - \let\oldtexttt\texttt`n"
    $yaml += "  - \renewcommand{\texttt}[1]{\colorbox{codebg}{\oldtexttt{#1}}}`n"
    
    # Line numbers
    if ($script:LineNumbers) {
        $yaml += "  - \usepackage{fvextra}`n"
        $yaml += "  - \DefineVerbatimEnvironment{Highlighting}{Verbatim}{numbers=left,numbersep=5pt,frame=lines,framesep=2mm,commandchars=\\\{\}}`n"
    }
    
    $yaml += "---`n`n"
    return $yaml
}

function New-TitlePage {
    param(
        [string]$MainTitle,
        [string]$TitleContent
    )
    
    $titleLines = $TitleContent -split '\r?\n'
    
    $latex = "\begin{titlepage}`n\thispagestyle{empty}`n\centering`n\vspace*{2cm}`n`n"
    $latex += "{\Huge\bfseries $MainTitle\par}`n`n\vspace{2cm}`n`n"
    
    foreach ($line in $titleLines) {
        $trimmedLine = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmedLine)) { 
            $latex += "\vspace{0.5cm}`n"
            continue 
        }
        # Escape LaTeX special characters
        $trimmedLine = $trimmedLine -replace '&', '\&' -replace '%', '\%' -replace '\$', '\$' -replace '#', '\#' -replace '_', '\_'
        # Convert markdown formatting
        $trimmedLine = $trimmedLine -replace '\*\*([^*]+)\*\*', '\textbf{$1}' -replace '\*([^*]+)\*', '\textit{$1}'
        $latex += "$trimmedLine\\[0.3cm]`n"
    }
    
    $latex += "`n\vfill`n\end{titlepage}`n`n\newpage`n`n"
    return $latex
}

function Convert-MarkdownToPdf {
    param(
        [string]$InputFile,
        [double]$Spacing = 1.5
    )
    
    if (-not (Test-Path $InputFile)) {
        Write-Warning "File not found: $InputFile"
        return $false
    }
    
    $OutputFile = [System.IO.Path]::ChangeExtension($InputFile, ".pdf")
    $FileName = Split-Path -Leaf $InputFile
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    
    if (Test-Path $OutputFile) { Remove-Item $OutputFile -Force }
    
    Write-Host "  Converting: $FileName" -ForegroundColor Cyan
    
    $originalContent = Get-Content $InputFile -Raw -Encoding UTF8
    $docStructure = Get-DocumentStructure -Content $originalContent
    
    if ($docStructure.HasTitle) {
        Write-Host "    - Found [title] marker: $($docStructure.MainTitle)" -ForegroundColor Gray
    }
    if ($docStructure.HasToc) {
        Write-Host "    - Found [toc] marker" -ForegroundColor Gray
    }
    
    # Process Mermaid diagrams
    $processResult = ConvertTo-MermaidDiagrams -Content $docStructure.BodyContent -BaseName $BaseName
    $bodyContent = $processResult.Content
    if ($processResult.DiagramCount -gt 0) {
        Write-Host "    - Processed $($processResult.DiagramCount) diagram(s)" -ForegroundColor Gray
    }
    
    # Process markdown extensions
    $bodyContent = ConvertTo-MarkdownExtensions -Content $bodyContent
    
    # Build document
    $yamlHeader = New-YamlHeader -Spacing $Spacing -Title $docStructure.MainTitle -Author $docStructure.Authors
    
    if ($docStructure.HasTitle) {
        $titlePage = New-TitlePage -MainTitle $docStructure.MainTitle -TitleContent $docStructure.TitleContent
        $finalContent = $yamlHeader + $titlePage + $bodyContent
    } else {
        $finalContent = $yamlHeader + $bodyContent
    }
    
    $TempMarkdown = Join-Path $ScriptDir "_temp_$BaseName.md"
    [System.IO.File]::WriteAllText($TempMarkdown, $finalContent, [System.Text.UTF8Encoding]::new($false))
    
    try {
        $markdownFormat = "markdown+raw_tex+implicit_figures"
        if ($script:TwoColumn) {
            $markdownFormat = "markdown+raw_tex+implicit_figures-pipe_tables-simple_tables-multiline_tables-grid_tables"
        }
        
        $pandocArgs = @($TempMarkdown, "-o", $OutputFile, "--pdf-engine=$pdfEngine", "-f", $markdownFormat, "--standalone")
        
        if ($script:TwoColumn) {
            $pandocArgs += @("-V", "classoption=twocolumn")
        }
        
        if ($hasBibliography) {
            $pandocArgs += @("--citeproc", "--bibliography=$BibFile", "--csl=$CslFile")
        }
        
        Write-Host "    - Running pandoc..." -ForegroundColor Gray
        $output = & pandoc @pandocArgs 2>&1
        
        if (Test-Path $OutputFile) {
            $Size = [math]::Round((Get-Item $OutputFile).Length / 1KB, 1)
            Write-Host "    - Generated: $(Split-Path -Leaf $OutputFile) ($Size KB)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "    - Failed to generate PDF" -ForegroundColor Red
            Write-Host "    Output: $output" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "    - Error: $_" -ForegroundColor Red
        return $false
    }
    finally {
        if (Test-Path $TempMarkdown) { Remove-Item $TempMarkdown -Force -ErrorAction SilentlyContinue }
        if (Test-Path $FiguresDir) { Remove-Item $FiguresDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

#endregion

# Main execution
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  Markdown to PDF Converter" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Pandoc not found. Please install from https://pandoc.org" -ForegroundColor Red
    exit 1
}

Write-Host "  Dependencies:" -ForegroundColor White
Write-Host "    - Pandoc: Available" -ForegroundColor Green
Write-Host "    - PDF Engine: $pdfEngine" -ForegroundColor $(if ($xelatexPath) { "Green" } else { "Yellow" })
Write-Host "    - Mermaid CLI: $(if ($hasMermaid) { 'Available' } else { 'Not found (diagrams disabled)' })" -ForegroundColor $(if ($hasMermaid) { "Green" } else { "DarkYellow" })
if ($hasBibliography) {
    Write-Host "    - Bibliography: Available" -ForegroundColor Green
}
Write-Host ""

$FilePath = if ([System.IO.Path]::IsPathRooted($File)) { $File } else { Join-Path (Get-Location) $File }

if (Convert-MarkdownToPdf -InputFile $FilePath -Spacing $LineSpacing) {
    $OutputFile = [System.IO.Path]::ChangeExtension($FilePath, ".pdf")
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Yellow
    
    if ($OpenAfterBuild -and (Test-Path $OutputFile)) {
        Write-Host ""
        Write-Host "Opening PDF..." -ForegroundColor Cyan
        Start-Process $OutputFile
    }
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  Conversion failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Yellow
    exit 1
}
