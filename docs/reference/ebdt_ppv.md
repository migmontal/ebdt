# Calculates the Positive Predictive Value (only Cross-sectional study)

This function calculate the Positive predictive value estimator, their
standard error estimated and a confidence interval in a traverse.

## Usage

``` r
ebdt_ppv(s1, r1, s0, r0, conflev = 0.95, digits = 3)
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

list with: - est: PPV = s1 / (s1 + r1) - StdError: binomial standard
error of PPV - CI: vector c(inf, sup) IC for NPV - CI_Method:
"Agresti-Coull"

## Details

Evaluating of Binary Diagnostic Test (EBDT)

This function calculates the Positive Predictive Value (PPV) with Simel
and Gart - Nam ICs

## References

Agresti, A., (2002). Categorical Data Analysis. John Wiley and Sons, New
York.

Agresti, A., Coull, B.A., (1998). Approximate is better than ‘exact’ for
interval estimation of binomial proportions. The American Statistician,
52:119 – 126.

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
ebdt_ppv(40, 5, 10, 45)
#> 
#>  POSITIVE PREDICTIVE VALUE 
#> ---------------------------
#> 
#> Positive Predictive Value estimated is: 0.889 
#> Standard error estimated is: 0.047 
#> Agresti-Coull Method for 95 %CI for PPV is [ 0.76 ; 0.956 ]
#> 
```
