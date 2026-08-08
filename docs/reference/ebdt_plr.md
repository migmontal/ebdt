# Calculates the Positive likelihood ratio

This function calculate the Positive Likelihood Ratio estimator, their
standard error estimated and a confidence interval in a traverse or
Cross-sectional study.

## Usage

``` r
ebdt_plr(s1, r1, s0, r0, conflev = 0.95, digits = 3)
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

list with: - est: LR+ = Se / (1 - Sp) - std.err: EE(LR+) by delta method
from the variance in log-LR+ - CI1.sl: lower limit (Simel, log-normal) -
CI.su: upper limit (Simel, log-normal) - CI.gnl: lower limit (Gart &
Nam) - CI.gnu: upper limit (Gart & Nam)

## Details

Evaluating of Binary Diagnostic Test (EBDT)

This function calculates the Positive likelihood ratio (LR+) with Simel
and Gart - Nam ICs

Requires a \`gn_plr()\` function in the environment and \`rootall()\`
function in the environment (the robust version reviewed above is
suitable).

## References

Agresti, A., (2002). Categorical Data Analysis. John Wiley and Sons, New
York.

Agresti, A., Coull, B.A., (1998). Approximate is better than ‘exact’ for
interval estimation of binomial proportions. The American Statistician,
52:119 – 126.

Gart, J.J., Nam J., (1988). Aproximate interval estimation of the ratio
of binomial parameters: a review and corrections for skewness.
Biometrics, 44: 323 – 338.

Montero-Alonso, M.Á.(2010). Intervalos de confianza y contrastes de
hipótesis para parámetros de tests diagnósticos binarios,
http://hdl.handle.net/10481/4879

Simel D.L., Samsa, G.P., Matchar, D.B., (1991). Likelihood ratios with
confidence: sample size estimation for diagnostic test studies. J. Clin
Epidemiology, 44(8): 763-770.

Pepe, M. S. (2003). The statistical evaluation of medical tests for
classification and prediction. Oxford University Press.

Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.

## Examples

``` r
ebdt_plr(40, 5, 10, 45)
#> 
#>  P O S I T I V E   L I K E L I H O O D   R A T I O 
#> ---------------------------------------------------
#> 
#> Positive Likelihood Ratio estimated is: 8 
#> Standard error estimated is: 3.441 
#> Simel 95 %CI for LR+ is [ 3.443 ; 18.587 ]
#> Gart-Nam 95 %CI for LR+ is [ 3.687 ; 18.578 ]
#> 
#> Gart-Nam CI is narrower than Simel CI.
#> 
```
