# ebdt: Evaluation of Binary Diagnostic Test

An R package for calculating quality measures of binary diagnostic tests
with confidence intervals.

## Overview

This package calculates the point estimate and confidence intervals of
diagnostic test quality measures including:

- **Sensitivity & Specificity**: Test accuracy for positives and
  negatives
- **Predictive Values**: PPV and NPV for clinical prediction
- **Likelihood Ratios**: PLR and NLR for test utility
- **Additional measures**: Youden Index, Weighted Kappa, Prevalence

Supports both: - **Cohort/Cross-sectional studies**: Full parameter
set - **Case-Control/Retrospective studies**: Limited to Sensitivity,
Specificity, Youden Index, and Likelihood Ratios

## Installation

``` r

# Install from GitHub
remotes::install_github("migmontal/ebdt")
```

## Quick Start

``` r

library(ebdt)

# Example: 2x2 contingency table from a diagnostic test study
# TP=95, FP=10, FN=5, TN=290
ebdt(s1=95, r1=10, s0=5, r0=290, conflev=0.95, digits=3)
```

## Features

- Automatic calculation of confidence intervals using appropriate
  methods
- Support for both cohort and case-control study designs
- Customizable confidence level and decimal precision
- Formatted console output with 2×2 contingency table
- Interactive Shiny app for user-friendly analysis

## Documentation

See the [online documentation](https://github.com/migmontal/ebdt) for: -
Function reference - Usage examples - Methodological details and
references

## Authors

- **Miguel Angel Montero-Alonso** (ORCID: 0000-0002-1214-9035)
- **Juan de Dios Luna del Castillo** (ORCID: 0000-0002-1854-4968)

## License

MIT + file LICENSE
