---
header-includes:
  - \usepackage{booktabs}
  - \usepackage{array}
  - \usepackage{float}
---

# Test Table

```{=latex}
\begin{table}[H]
\centering
\caption{Test Table}
\begin{tabular}{@{}>{\raggedright\arraybackslash}p{0.28\textwidth}lccc>{\raggedright\arraybackslash}p{0.15\textwidth}@{}}
\toprule
\textbf{Column 1} & \textbf{Col 2} & \textbf{Col 3} & \textbf{Col 4} & \textbf{Col 5} & \textbf{Column 6} \\
\midrule
Test & A & .803 & .804 & .673 & Some text here \\
\bottomrule
\end{tabular}
\end{table}
```
