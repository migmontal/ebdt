# ebdt: Evaluation of Binary Diagnostic Tests

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![R Shiny](https://img.shields.io/badge/Shiny-1.9.1-blue?logo=r)
![License](https://img.shields.io/badge/license-MIT-green)
<!-- badges: end -->

## Overview
<p align="justify">
The <code>ebdt</code> package evaluates the quality of a binary diagnostic test under complete verification. It computes point estimates and confidence intervals for sensitivity, specificity, Youden index, positive and negative predictive values, positive and negative likelihood ratios, weighted kappa coefficient, and disease prevalence, for both, cross-sectional (prospective) and retrospective study designs. </p>

This package is particularly useful for:
- Medical researchers evaluating diagnostic accuracy
- Clinical epidemiologists assessing screening tools
- Statisticians performing diagnostic test validation
- Healthcare professionals comparing diagnostic methods

## Reference

- Agresti, A., (2002). Categorical Data Analysis. John Wiley and Sons, New York.
- Agresti, A., Coull, B.A., (1998). Approximate is better than ‘exact’ for interval estimation of binomial proportions. The American Statistician, 52:119 – 126.
- Gart, J.J., Nam J., (1988). Aproximate interval estimation of the ratio of binomial parameters: a review and corrections for skewness. Biometrics, 44: 323 – 338.
- Montero-Alonso, M.A. (2010). [Intervalos de confianza y contrastes de hipotesis para parametros de tests diagnosticos binarios](http://hdl.handle.net/10481/4879). Universidad de Granada. 
- Simel D.L., Samsa, G.P., Matchar, D.B., (1991). Likelihood ratios with confidence: sample size estimation for diagnostic test studies. J. Clin Epidemiology, 44(8): 763-770.
- Roldán Nofuentes J.A., Luna del Castillo J.D., Montero Alonso, M.A., (2009). Confidence intervals of weighted kappa coefficient of a binary diagnostic test. Communications in Statistics. Simulation and Computation, 38: 1562 – 1578.
- Pepe, M. S. (2003). The statistical evaluation of medical tests for classification and prediction. Oxford University Press.
- Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.

--- 

## Authors

- **Miguel Ángel Montero-Alonso** <a href="https://orcid.org/0000-0002-1214-9035" target="_blank" rel="noopener">ORCID</a>
  <p>Department of Statistics and Operations Research, Faculty of Medicine, University of Granada, Granada, Spain  
  Instituto de Investigación Biosanitaria ibs.GRANADA, Granada, Spain  
  Email: mmontero@ugr.es</p>

- **Juan de Dios Luna del Castillo** <a href="https://orcid.org/0000-0002-1854-4968" target="_blank" rel="noopener">ORCID</a>
  <p>Department of Statistics and Operations Research, Faculty of Medicine, University of Granada, Granada, Spain  
  Instituto de Investigación Biosanitaria ibs.GRANADA, Granada, Spain  
  Email: jdluna@ugr.es</p>

---

## Installation

### From GitHub (development version)

```r
install.packages("devtools")
devtools::install_github("migmontal/ebdt")
```

### From CRAN (once released)

```r
install.packages("ebdt")
```

## Quick Start

```r
library(ebdt)

# Example: Evaluate a diagnostic test
ebdt(231,32,27,55)

```

---

## Citation

If you use `ebdt` in your research, please cite it as:

Montero-Alonso M.A., Luna del Castillo J.D. (2026). ebdt: Evaluation of the quality of binary diagnostic test parameters. R package version 1.0.1.

```bibtex
@Manual{ebdt2026,
  title = {ebdt: Evaluation of the quality of binary diagnostic test parameters},
  author = {Miguel Angel Montero-Alonso and Juan de Dios Luna del Castillo},
  year = {2026},
  note = {R package version 1.0.1},
}
```

---

## Shiny app

The package includes an interactive Shiny application:

```r
shiny::runApp(system.file("app", package = "ebdt"))

```

and you can also find it at:

```r
https://migmontal.shinyapps.io/ebdt/

```

---

## Vignettes
Find summarized information at the following link:

[https://migmontal.github.io/ebdt-webside/](https://migmontal.github.io/ebdt-website/)

---

## Funding

Plan Propio de Investigación y Transferencia de la Universidad de Granada. 2024. Programa 21. Programa de estimulación a la investigación.

---

## License

MIT License - see [LICENSE](LICENSE) file for details. Copyright (c) 2026 Universidad de Granada.

