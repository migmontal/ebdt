# Calculates the Negative likelihood ratio

This function calculate the Negative Likelihood Ratio estimator, their
standard error estimated and a confidence interval in a traverse or
Cross-sectional study.

## Usage

``` r
ebdt_nlr(s1, r1, s0, r0, conflev = 0.95, digits = 3)
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

list with: - LinfGNLRn: lower limit of the IC GN for LR- - LsupGNLRn:
upper limit of the IC GN for LR-

## Details

Evaluating of Binary Diagnostic Test (EBDT)

This function calculates the Negative likelihood ratio (LR-) with Simel
and Gart - Nam ICs

Requires a \`gn_nlr()\` function in the environment and \`rootall()\`
function in the environment (the robust version reviewed above is
suitable).

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
ebdt_nlr(40, 5, 10, 45)
#> 
#>  N E G A T I V E   L I K E L I H O O D   R A T I O 
#> ---------------------------------------------------
#> 
#> Negative Likelihood Ratio estimated is: 0.222 
#> Standard error estimated is: 0.064 
#> Simel 95 %CI for LR- is [ 0.127 ; 0.39 ]
#> Gart-Nam 95 %CI for LR- is [ 0.124 ; 0.371 ]
#> 
#> Gart-Nam CI is narrower than Simel CI.
#> 
```
