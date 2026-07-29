
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the Negative Predictive Value (NPV)
#' with Simel and Gart - Nam ICs
#'
#' @title Calculates the Negative Predictive Value (only Cross-sectional study)
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @returns list with:
#'   - est: NPV =  r0 / (s0 + r0)
#'   - StdError: binomial standard error of NPV
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
#' @references Pepe, M. S. (2003). The statistical evaluation of medical tests for
#'        classification and prediction. Oxford University Press.
#'
#' @references Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
#'        Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.
#'
#' @description This function calculate the Negative predictive value estimator,
#'  their standard error estimated and a confidence interval in a traverse.
#' @examples ebdt_npv(7450, 2001, 2003, 5850)
#'
ebdt_npv <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
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

  # ---- Denominators of NPV (only negative) ----
  n_neg <- s0 + r0
  if (n_neg == 0) stop("s0 + r0 = 0. NPV cannot be calculated.")

  # ---- Zero correction (Haldane–Anscombe) BY PAIRS (only (s0, r0)) ----
  if (s0 == 0 || r0 == 0) {
    s0 <- s0 + 0.5
    r0 <- r0 + 0.5
    n_neg <- s0 + r0
    warning("Continuity correction (+0.5) applied on the pair (s0, r0).")
  }

  # ---- Basic calculations ----
  p_hat <- r0 / n_neg              # NPV
  se_npv <- sqrt(p_hat * (1 - p_hat) / n_neg)

  # ---- Critical value ----
  z <- stats::qnorm(1 - (1 - conflev) / 2)

  # ---- Confidence Interval ----

  # Agresti–Coull
  n_tilde <- n_neg + z^2
  p_tilde <- (r0 + (z^2) / 2) / n_tilde
  half    <- z * sqrt(p_tilde * (1 - p_tilde) / n_tilde)
  CI <- c(max(0, p_tilde - half), min(1, p_tilde + half))
  method <- "Agresti-Coull"

  # ---- Output ----

  cat("\n")
  cat(" NEGATIVE PREDICTIVE VALUE \n")
  cat("---------------------------\n")
  cat("\n")
  cat("Negative Predictive Value estimated is:", round(p_hat,digits), "\n")
  cat("Standard error estimated is:", round(se_npv,digits), "\n")
  cat(method,"Method for",100*conflev,"%CI for NPV is [", round(CI[[1]],digits),";", round(CI[[2]],digits),"]\n")
  cat("\n")

  invisible(list(
    est = p_hat, se = se_npv, ci_lower = CI[[1]], ci_upper = CI[[2]],
    ci_method = method, conf_level = conflev
  ))
}
