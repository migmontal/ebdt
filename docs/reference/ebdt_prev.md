# Calculate Prevalence (only Cross-sectional study)

This function calculate prevalence estimator, their standard error
estimated and a confidence interval in a traverse study.

## Usage

``` r
ebdt_prev(s1, r1, s0, r0, conflev = 0.95, digits = 3)
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

list with: - Prevalence: prevalence estimation prev = (s1 + s0)/(s1 +
s0 + r1 + r0) - StdError: binomial standard error of prevalence - CI:
vector c(inf, sup) IC for prevalence - CI_Method: "Agresti-Coull"

## Details

Evaluating of Binary Diagnostic Test (EBDT)

This function calculates the Prevalence (proportion of cases), standard
error & Agresti-Coull CI

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
ebdt_prev(40, 5, 10, 45)
#> 
#>  P R E V A L E N C E 
#> ---------------------
#> 
#> Prevalence estimated is: 0.5 
#> Standard error estimated is: 0.05 
#> Agresti-Coull Method for 95 %CI for prevalence is [ 0.404 ; 0.596 ]
#> 
```
