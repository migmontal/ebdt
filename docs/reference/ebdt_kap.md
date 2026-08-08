# Calculate the weighted Kappa coefficient

This function calculate the Weighted Kappa Coeficient estimator, their
standard error estimated with Wald and Logit confidence interval in a
traverse study.

## Usage

``` r
ebdt_kap(s1, r1, s0, r0, conflev = 0.95, digits = 3)
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

data.frame, in columns: c_index, Kappa, StdError, CI_Wald_L, CI_Wald_U,
CI_Logit_L, CI_Logit_U

## Details

Evaluating of Binary Diagnostic Test (EBDT)

This function calculates the "Kappa" coefficient weighted by c
(0.1..0.9) with Wald and Logit ICs

## References

Agresti, A., (2002). Categorical Data Analysis. John Wiley and Sons, New
York.

Agresti, A., Coull, B.A., (1998). Approximate is better than ‘exact’ for
interval estimation of binomial proportions. The American Statistician,
52:119 – 126.

Montero-Alonso, M.Á.(2010). Intervalos de confianza y contrastes de
hipótesis para parámetros de tests diagnósticos binarios,
http://hdl.handle.net/10481/4879

Roldán Nofuentes J.A., Luna del Castillo J.D., Montero Alonso, M.A.,
(2009). Confidence intervals of weighted kappa coefficient of a binary
diagnostic test. Communications in Statistics. Simulation and
Computation, 38: 1562 – 1578.

Pepe, M. S. (2003). The statistical evaluation of medical tests for
classification and prediction. Oxford University Press.

Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.

## Examples

``` r
ebdt_kap(40, 5, 10, 45)
#> 
#>  W E I G H T E D   K A P P A   C O E F I C I E N T 
#> ---------------------------------------------------
#> 
#> All Confidence Intervals are at 95 %,
#> 
#>   c_index Kappa StdError CI_Wald_l CI_Wald_u CI_Logit_l CI_Logit_u  Best
#> 1     0.1 0.761    0.043     0.677     0.844      0.668      0.834 Logit
#> 2     0.2 0.745    0.044     0.659     0.830      0.650      0.821 Logit
#> 3     0.3 0.729    0.044     0.642     0.816      0.634      0.807 Logit
#> 4     0.4 0.714    0.045     0.626     0.803      0.618      0.794 Logit
#> 5     0.5 0.700    0.046     0.610     0.790      0.603      0.782 Logit
#> 6     0.6 0.686    0.046     0.595     0.777      0.589      0.769 Logit
#> 7     0.7 0.673    0.047     0.581     0.765      0.575      0.758 Logit
#> 8     0.8 0.660    0.047     0.568     0.753      0.562      0.746 Logit
#> 9     0.9 0.648    0.048     0.555     0.742      0.550      0.735 Logit
```
