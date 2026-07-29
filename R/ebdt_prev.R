
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the Prevalence (proportion of cases),
#'    standard error & Agresti-Coull CI
#'
#' @title Calculate Prevalence (only Cross-sectional study)
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @returns list with:
#'   - Prevalence: prevalence estimation prev = (s1 + s0)/(s1 + s0 + r1 + r0)
#'   - StdError: binomial standard error of prevalence
#'   - CI: vector c(inf, sup) IC for prevalence
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
#' @references Pepe, M. S. (2003). The statistical evaluation of medical tests for
#'        classification and prediction. Oxford University Press.
#'
#' @references Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
#'        Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.
#'
#' @description This function calculate prevalence estimator, their standard error
#'  estimated and a confidence interval in a traverse study.
#' @examples ebdt_prev(7450, 2001, 2003, 5850)
#'
ebdt_prev <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
  # ---- Input validation ----
  vals <- c(s1, s0, r1, r0)
  if (any(!is.numeric(vals)) || any(!is.finite(vals))) {
    stop("All arguments s1, r1, s0, r0 must be finite numeric scalars.")
  }
  if (any(lengths(list(s1, r1, s0, r0)) != 1)) {
    stop("s1, r1, s0, r0 must be length-1 scalars.")
  }
  if (any(vals < 0)) stop("The values cannot be negative.")
  if (!is.numeric(conflev) || length(conflev) != 1L || conflev <= 0 || conflev >= 1) {
    stop("conflev must be within the interval (0, 1).")
  }
  if (!is.numeric(digits) || length(digits) != 1L || digits < 0) {
    stop("digits must be a single non-negative integer.")
  }
  digits <- as.integer(digits)

  # ---- Basic calculations ----
  ss <- s1 + s0
  rr <- r1 + r0
  nn <- ss + rr
  if (nn == 0) stop("s1 + s0 + r1 + r0 = 0. Prevalence cannot be calculated.")

  prev <- ss / nn
  se_prev <- sqrt(prev * (1 - prev) / nn)

  # ---- Critical value ----
  z <- stats::qnorm(1 - (1 - conflev) / 2)

  # ---- Confidence Interval for prevalence ----

  # Agresti–Coull
  n_tilde <- nn + z^2
  p_tilde <- (ss + (z^2) / 2) / n_tilde
  half    <- z * sqrt(p_tilde * (1 - p_tilde) / n_tilde)
  CI <- c(max(0, p_tilde - half), min(1, p_tilde + half))
  method <- "Agresti-Coull"

  # ---- Output ----

  cat("\n")
  cat(" P R E V A L E N C E \n")
  cat("---------------------\n")
  cat("\n")
  cat("Prevalence estimated is:", round(prev,digits), "\n")
  cat("Standard error estimated is:", round(se_prev,digits), "\n")
  cat(method,"Method for",100*conflev,"%CI for prevalence is [", round(CI[[1]],digits),";", round(CI[[2]],digits),"]\n")
  cat("\n")

  invisible(list(
    est = prev, se = se_prev, ci_lower = CI[[1]], ci_upper = CI[[2]],
    ci_method = method, conf_level = conflev
  ))
}
