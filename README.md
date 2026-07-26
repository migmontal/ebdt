# ebdt: Evaluation of Binary Diagnostic Tests

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN status](https://www.r-pkg.org/badges/version/ebdt)](https://CRAN.R-project.org/package=ebdt)
[![R-CMD-check](https://github.com/migmontal/ebdt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/migmontal/ebdt/actions/workflows/R-CMD-check.yaml)
[![ORCID](https://img.shields.io/badge/ORCID-0000--0003--XXXX--XXXX-green)](https://orcid.org/0000-0003-XXXX-XXXX)
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
actual_disease <- c(rep(1, 50), rep(0, 50))
test_results <- c(rbinom(50, 1, 0.85), rbinom(50, 1, 0.10))

# Calculate diagnostic performance metrics
metrics <- calculate_metrics(actual_disease, test_results)
print(metrics)

# Visualize results
plot_roc_curve(actual_disease, test_results)
plot_confusion_matrix(actual_disease, test_results)
```

## Main Features

- **Performance Metrics**: Sensitivity, specificity, accuracy, predictive values, likelihood ratios
- **ROC Curve Analysis**: Generate ROC curves with AUC computation
- **Confusion Matrix Visualization**: Beautiful confusion matrix plots
- **Test Comparison**: Compare multiple diagnostic tests side-by-side

## Documentation

- **Website**: [https://migmontal.github.io/ebdt](https://migmontal.github.io/ebdt)
- **Vignettes**: `vignette("ebdt-introduction")`
- **Issues**: [GitHub Issues](https://github.com/migmontal/ebdt/issues)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Citation

If you use `ebdt` in your research, please cite it as:

```bibtex
@Manual{ebdt2024,
  title = {ebdt: Evaluation of Binary Diagnostic Tests},
  author = {Montalbán, Miguel},
  year = {2024},
  note = {R package version 0.1.0},
  url = {https://github.com/migmontal/ebdt}
}
```
