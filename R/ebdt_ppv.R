
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the Positive Predictive Value (PPV)
#' with Simel and Gart - Nam ICs
#'
#' @title Calculates the Positive Predictive Value (only Cross-sectional study)
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @returns list with:
#'   - est: PPV = s1 / (s1 + r1)
#'   - StdError: binomial standard error of PPV
#'   - CI: vector c(inf, sup) IC for NPV
#'   - CI_Method: "Agresti-Coull"
#'
#' @export
#' @references Agresti, A., (2002). Categorical Data Analysis.
#'        John Wiley and Sons, New York.
#'
#' @references Agresti, A., Coull, B.A., (1998). Approximate is better than ‘exact’
#'        for interval estimation of binomial proportions.
#'        The American Statistician, 52:119 – 126.
#'
#' @references Montero-Alonso, M.Á.(2010). Intervalos de confianza y contrastes
#'        de hipótesis para parámetros de tests diagnósticos binarios,
#'        http://hdl.handle.net/10481/4879
#'
#' @references Simel D.L., Samsa, G.P., Matchar, D.B., (1991). Likelihood ratios
#'        with confidence: sample size estimation for diagnostic test studies.
#'        J. Clin Epidemiology, 44(8): 763-770.
#'
#' @references Pepe, M. S. (2003). The statistical evaluation of medical tests for
#'        classification and prediction. Oxford University Press.
#'
#' @references Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
#'        Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.
#'
#' @description This function calculate the Positive predictive value estimator,
#'  their standard error estimated and a confidence interval in a traverse.
#' @examples ebdt_ppv(40, 5, 10, 45)
#'
ebdt_ppv <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
  # ---- Input validation ----
  vals <- c(s1, s0, r1, r0)
  if (any(!is.numeric(vals)) || any(!is.finite(vals))) {
    stop("All arguments s1, r1, s0, r0 must be finite numeric scalars.")
  }
  if (any(lengths(list(s1, r1, s0, r0)) != 1)) {
    stop("s1, r1, s0, r0 must be length-1 scalars.")
  }
  if (any(vals < 0)) stop("The values cannot be negative.")
  if (!is.numeric(conflev) || length(conflev) != 1 || conflev <= 0 || conflev >= 1) {
    stop("conflev must be within the interval (0, 1).")
  }
  if (!is.numeric(digits) || length(digits) != 1 || digits < 0) {
    stop("digits must be a single non-negative integer.")
  }
  digits <- as.integer(digits)

  # ---- Denominators of PPV (only positive) ----
  n_pos <- s1 + r1
  if (n_pos == 0) stop("s1 + r1 = 0. PPV cannot be calculated.")

  # ---- Zero correction (Haldane–Anscombe) BY PAIRS (only (s1, r1)) ----
  if (s1 == 0 || r1 == 0) {
    s1 <- s1 + 0.5
    r1 <- r1 + 0.5
    n_pos <- s1 + r1
    warning("Continuity correction (+0.5) applied on the pair (s1, r1).")
  }

  # ---- Basic calculations ----
  p_hat <- s1 / n_pos              # PPV
  se_ppv <- sqrt(p_hat * (1 - p_hat) / n_pos)

  # ---- Critical value ----
  z <- stats::qnorm(1 - (1 - conflev) / 2)

  # ---- Confidence Interval ----

  # Agresti–Coull
  n_tilde <- n_pos + z^2
  p_tilde <- (s1 + (z^2) / 2) / n_tilde
  half    <- z * sqrt(p_tilde * (1 - p_tilde) / n_tilde)
  CI <- c(max(0, p_tilde - half), min(1, p_tilde + half))
  method <- "Agresti-Coull"

  # ---- Output ----

  cat("\n")
  cat(" POSITIVE PREDICTIVE VALUE \n")
  cat("---------------------------\n")
  cat("\n")
  cat("Positive Predictive Value estimated is:", round(p_hat,digits), "\n")
  cat("Standard error estimated is:", round(se_ppv,digits), "\n")
  cat(method,"Method for",100*conflev,"%CI for PPV is [", round(CI[[1]],digits),";", round(CI[[2]],digits),"]\n")
  cat("\n")

  invisible(list(
    est = p_hat, se = se_ppv, ci_lower = CI[[1]], ci_upper = CI[[2]],
    ci_method = method, conf_level = conflev
  ))
}
