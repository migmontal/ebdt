# ebdt: Evaluation of Binary Diagnostic Tests

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Overview

`ebdt` is an R package designed for comprehensive evaluation of binary diagnostic tests. It provides functions to calculate performance metrics (sensitivity, specificity, predictive values, likelihood ratios), visualize results through ROC curves and confusion matrices, and compare multiple diagnostic tests.

This package is particularly useful for:
- Medical researchers evaluating diagnostic accuracy
- Clinical epidemiologists assessing screening tools
- Statisticians performing diagnostic test validation
- Healthcare professionals comparing diagnostic methods

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

## Documentation

- **Website**: [https://migmontal.github.io/ebdt](https://migmontal.github.io/ebdt)
- **Vignettes**: `vignette("ebdt-introduction")`
- **Issues**: [GitHub Issues](https://github.com/migmontal/ebdt/issues)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Citation

If you use `ebdt` in your research, please cite it as:

Montero-Alonso M.A., Luna del Castillo J.D. (2026). ebdt: Evaluation of the quality of binary diagnostic test parameters. R package version 1.0.0.

```bibtex
@Manual{ebdt2026,
  title = {ebdt: Evaluation of the quality of binary diagnostic test parameters},
  author = {Miguel Angel Montero-Alonso and Juan de Dios Luna del Castillo},
  year = {2026},
  note = {R package version 1.0.0},
}
```

## Finding

Plan Propio de Investigación y Transferencia de la Universidad de Granada. 2025. Programa 21. Programa de estimulación a la investigación.

