# Calculate Specificity

This function calculate the specificity estimator, their standard error
estimated and a confidence interval in a traverse or Cross-sectional
study.

## Usage

``` r
ebdt_sp(s1, r1, s0, r0, conflev = 0.95, digits = 3, verbose = TRUE)
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

- verbose:

  Logical. If TRUE, it prints the execution time. Default is TRUE.

## Value

list with: - Specificity: Specificity estimation (Sp = r0/(r1+r0)) -
StdError: binomial standard error of Sp - CI: vector c(inf, sup) IC for
Sp - CI_Method: "Agresti-Coull

## Details

Evaluating of Binary Diagnostic Test (EBDT)

This function calculates the Specificity, standard error & Agresti-Coull
CI

\- Apply continuity correction (Haldane–Anscombe) \*in pairs\* if there
are zeros: (r1,r0) y/o (s1,s0), +0.5 is added to both cells of the
pair. - Agresti-Coull: n_tilde = n + z^2 p_tilde = (x + z^2/2)/n_tilde
half = z \* sqrt( p_tilde(1-p_tilde) / n_tilde )

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
ebdt_sp(40, 5, 10, 45)
#> 
#>  S P E C I F I C I T Y 
#> -----------------------
#> 
#> Specificity estimated is: 0.9 
#> Standard error estimated is: 0.042 
#> Agresti-Coull Method for 95 %CI for specificity is [ 0.782 ; 0.961 ]
#> 
```
