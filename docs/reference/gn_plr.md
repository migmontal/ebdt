# Calculate Gart-Nam CI for positive likelihood ratio

This function calculate Gart-Nam Confidence Interval for Positive
Likelihood Ratio.

## Usage

``` r
gn_plr(s1, r1, s0, r0, conflev = 0.95, digits = 3)
```

## Arguments

- s1:

  Non-negative numeric. TP - True positive (cases correctly classified
  as +).

- r1:

  Non-negative numeric. FP - False positives (controls classified as +).

- s0:

  Non-negative numeric. FN - False negatives (cases classified as -).

- r0:

  Non-negative numeric. TN - True negatives (controls classified as -).

- conflev:

  Confidence level (0,1). Default 0.95.

- digits:

  Integer. Number of decimal places. Default 3.

## Value

list with: - LinfGNLRp: lower limit of the IC GN for LR+ - LsupGNLRp:
upper limit of the IC GN for LR+

## Details

Evaluating of Binary Diagnostic Test (EBDT)

Gart-Nam (GN) CI for positive likelihood ratio (LR+)

Requires a \`rootall()\` function in the environment (the robust version
reviewed above is suitable).

## References

Agresti, A., (2002). Categorical Data Analysis. John Wiley and Sons, New
York.

Gart, J.J., Nam J., (1988). Aproximate interval estimation of the ratio
of binomial parameters: a review and corrections for skewness.
Biometrics, 44: 323 – 338.

Montero-Alonso, M.Á.(2010). Intervalos de confianza y contrastes de
hipótesis para parámetros de tests diagnósticos binarios,
http://hdl.handle.net/10481/4879

Pepe, M. S. (2003). The statistical evaluation of medical tests for
classification and prediction. Oxford University Press.

Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.

## Examples

``` r
gn_plr(40, 5, 10, 45)
#> $LinfGNLRp
#> [1] 3.687286
#> 
#> $LsupGNLRp
#> [1] 18.57829
#> 
```
