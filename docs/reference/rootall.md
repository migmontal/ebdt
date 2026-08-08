# rootall

Function to locate multiple roots using a grid and uniroot.

It is an auxiliary function used to calculate Gart-Nam Confidence
Interval for Likelihood Ratios (LR+ and LR-). It finds all roots of a
function within a specified interval using a grid-based approach and the
uniroot method.

## Usage

``` r
rootall(
  f,
  interval,
  lower,
  upper,
  tol = .Machine$double.eps^0.2,
  maxiter = 20,
  n = 1000,
  ...
)
```

## Arguments

- f:

  Function to be evaluated.

- interval:

  Vector with lower and upper limits.

- lower:

  Lower limit.

- upper:

  Upper limit.

- tol:

  Tolerance.

- maxiter:

  Maximum iterations.

- n:

  Number of nodes in the grid.

- ...:

  Additional arguments for f.
