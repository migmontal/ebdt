# Calculate Sensitivity

This function calculate the sensitivity estimator, their standard error
estimated and a confidence interval in a traverse or Cross-sectional
study.

## Usage

``` r
ebdt_se(s1, r1, s0, r0, conflev = 0.95, digits = 3)
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

list with: - Sensitivity: sensitivity estimation (Se = s1/(s1+s0)) -
StdError: binomial standard error of Se - CI: vector c(inf, sup) IC for
Se - CI_Method: "Agresti-Coull"

## Details

Evaluating of Binary Diagnostic Test (EBDT)

This function calculates the sensitivity, standard error & Agresti-Coull
CI

\- Apply continuity correction (Haldane–Anscombe) \*in pairs\* if there
are zeros: (s1,s0) and/or (r1,r0), avoiding adding 0.5 to cells not
related to the estimated proportion. - For Wilson, the standard center
and half-width are used: center = (p + z^2/(2n)) / (1 + z^2/n) half =
z/(1 + z^2/n) \* sqrt(p(1-p)/n + z^2/(4n^2)) - For Agresti-Coull:
n_tilde = n + z^2; p_tilde = (x + z^2/2)/n_tilde; half =
z\*sqrt(p_tilde(1-p_tilde)/n_tilde)

## References

Agresti, A., (2002). Categorical Data Analysis. John Wiley and Sons, New
York.

Agresti, A., Coull, B.A., (1998). Approximate is better than ‘exact’ for
interval estimation of binomial proportions. The American Statistician,
52:119 – 126.

Montero-Alonso, M.Á.(2010). Intervalos de confianza y contrastes de
hipótesis para parámetros de tests diagnósticos binarios,
http://hdl.handle.net/10481/4879

Pepe, M. S. (2003). The statistical evaluation of medical tests for
classification and prediction. Oxford University Press.

Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.

## Examples

``` r
ebdt_se(40, 5, 10, 45)
#> 
#>  S E N S I T I V I T Y 
#> -----------------------
#> 
#> Sensitivity estimated is: 0.8 
#> Standard error estimated is: 0.057 
#> Agresti-Coull Method for 95 %CI for sensitivity is [ 0.668 ; 0.889 ]
#> 
```
