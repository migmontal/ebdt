# Calculate all parameters of a binary diagnostic test in a traverse or Cross-sectional study.

This function calculate Sensitivity, Specificity, positive and negative
predictive value, positive and negative Likelihood Ratio, Weighted Kappa
coeficient, Youden Index, prevalence and their Confidence intervals in a
traverse or Cross-sectional study, and Sensitivity, Specificity, Youden
Index, positive and negative Likelihood Ratio in a Case Control or
Retrospective study.

## Usage

``` r
ebdt(
  s1,
  r1,
  s0,
  r0,
  conflev = 0.95,
  digits = 3,
  study = TRUE,
  verbose = TRUE,
  print_table = TRUE,
  quiet = FALSE
)
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

- study:

  Logical. If TRUE in a traverse or Cross-sectional study, FALSE in a
  Case Control or Retrospective study. Default TRUE.

- verbose:

  Logical. If TRUE, it prints the execution time. Default is TRUE.

- print_table:

  Logical. If TRUE, print 2x2 table. Default TRUE.

- quiet:

  Logical. If TRUE, it reduces non-critical messages (maintains
  important warnings). Default is FALSE.

## Value

No return value; prints formatted results to the console. List with:
Sensitivity, Specificity, Youden_Index, Prevalence, PPV, NPV, PLR, NLR,
Weighted_Kappa and their Confidence intervals.

## Details

Evaluating of Binary Diagnostic Test (EBDT)

Calculate the point estimate and confidence intervals of the quality
measures of a binary diagnostic test.

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
ebdt(40, 5, 10, 45, conflev = 0.95, digits = 4)
#> Matrix of data is:
#> 
#>         Outcome
#> Test     Outcome + Outcome - Total
#>   Test +        40         5    45
#>   Test -        10        45    55
#>   Total         50        50   100
#> 
#> 
#> --------------------------------------
#>  EVALUATING OF BINARY DIAGNOSTIC TEST 
#> --------------------------------------
#> 
#>        -----------------------
#>         Cross-sectional study 
#>        -----------------------
#> 
#>  S E N S I T I V I T Y 
#> -----------------------
#> 
#> Sensitivity estimated is: 0.8 
#> Standard error estimated is: 0.0566 
#> Agresti-Coull Method for 95 %CI for sensitivity is [ 0.6677 ; 0.8895 ]
#> 
#> 
#>  S P E C I F I C I T Y 
#> -----------------------
#> 
#> Specificity estimated is: 0.9 
#> Standard error estimated is: 0.0424 
#> Agresti-Coull Method for 95 %CI for specificity is [ 0.7821 ; 0.9609 ]
#> 
#> 
#>  Y O U D E N  I N D E X 
#> ------------------------
#> 
#> Youden index estimated is: 0.7 
#> Standard error estimated is: 0.0707 
#> 95 %CI for Youden index is [ 0.5614 ; 0.8386 ]
#> 
#> 
#>  P R E V A L E N C E 
#> ---------------------
#> 
#> Prevalence estimated is: 0.5 
#> Standard error estimated is: 0.05 
#> Agresti-Coull Method for 95 %CI for prevalence is [ 0.4038 ; 0.5962 ]
#> 
#> 
#>  POSITIVE PREDICTIVE VALUE 
#> ---------------------------
#> 
#> Positive Predictive Value estimated is: 0.8889 
#> Standard error estimated is: 0.0468 
#> Agresti-Coull Method for 95 %CI for PPV is [ 0.7605 ; 0.9561 ]
#> 
#> 
#>  NEGATIVE PREDICTIVE VALUE 
#> ---------------------------
#> 
#> Negative Predictive Value estimated is: 0.8182 
#> Standard error estimated is: 0.052 
#> Agresti-Coull Method for 95 %CI for NPV is [ 0.6947 ; 0.9001 ]
#> 
#> 
#>  P O S I T I V E   L I K E L I H O O D   R A T I O 
#> ---------------------------------------------------
#> 
#> Positive Likelihood Ratio estimated is: 8 
#> Standard error estimated is: 3.4409 
#> Simel 95 %CI for LR+ is [ 3.4433 ; 18.5868 ]
#> Gart-Nam 95 %CI for LR+ is [ 3.6873 ; 18.5783 ]
#> 
#> Gart-Nam CI is narrower than Simel CI.
#> 
#> 
#>  N E G A T I V E   L I K E L I H O O D   R A T I O 
#> ---------------------------------------------------
#> 
#> Negative Likelihood Ratio estimated is: 0.2222 
#> Standard error estimated is: 0.0637 
#> Simel 95 %CI for LR- is [ 0.1267 ; 0.3898 ]
#> Gart-Nam 95 %CI for LR- is [ 0.1242 ; 0.3715 ]
#> 
#> Gart-Nam CI is narrower than Simel CI.
#> 
#> 
#>  W E I G H T E D   K A P P A   C O E F I C I E N T 
#> ---------------------------------------------------
#> 
#> All Confidence Intervals are at 95 %,
#> 
#>   c_index  Kappa StdError CI_Wald_l CI_Wald_u CI_Logit_l CI_Logit_u  Best
#> 1     0.1 0.7609   0.0427    0.6773    0.8445     0.6677     0.8344 Logit
#> 2     0.2 0.7447   0.0436    0.6592    0.8301     0.6504     0.8205 Logit
#> 3     0.3 0.7292   0.0444    0.6421    0.8163     0.6340     0.8071 Logit
#> 4     0.4 0.7143   0.0452    0.6257    0.8028     0.6183     0.7942 Logit
#> 5     0.5 0.7000   0.0458    0.6102    0.7898     0.6034     0.7816 Logit
#> 6     0.6 0.6863   0.0464    0.5953    0.7772     0.5891     0.7694 Logit
#> 7     0.7 0.6731   0.0469    0.5811    0.7650     0.5755     0.7577 Logit
#> 8     0.8 0.6604   0.0474    0.5676    0.7532     0.5625     0.7463 Logit
#> 9     0.9 0.6481   0.0478    0.5546    0.7417     0.5500     0.7352 Logit
#> 
#> Execution time: 0.1475 seconds
```
