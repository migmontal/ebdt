
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the Specificity, standard error & Agresti-Coull CI
#'
#' @title Calculate Specificity
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @returns list with:
#'   - Specificity: Specificity estimation (Sp = r0/(r1+r0))
#'   - StdError: binomial standard error of Sp
#'   - CI: vector c(inf, sup) IC for Sp
#'   - CI_Method: "Agresti-Coull
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
#' @details
#' - Apply continuity correction (Haldane–Anscombe) *in pairs* if there are zeros:
#'    (r1,r0) y/o (s1,s0), +0.5 is added to both cells of the pair.
#' - Agresti-Coull:
#'     n_tilde = n + z^2
#'     p_tilde = (x + z^2/2)/n_tilde
#'     half    = z * sqrt( p_tilde(1-p_tilde) / n_tilde )
#'
#' @description This function calculate the specificity estimator, their
#' standard error estimated and a confidence interval in a traverse or
#' Cross-sectional study.
#' @examples ebdt_sp(40, 5, 10, 45)
#'
ebdt_sp <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
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

  # Original denominators
  n_cases <- s1 + s0
  n_ctrls <- r1 + r0
  if (n_ctrls == 0) stop("r1 + r0 = 0. Specificity cannot be calculated.")

  # ---- Zero correction (Haldane–Anscombe) BY PAIRS ----
  corrected <- FALSE
  if (r1 == 0 || r0 == 0) {
    r1 <- r1 + 0.5
    r0 <- r0 + 0.5
    corrected <- TRUE
  }
  if (s1 == 0 || s0 == 0) {
    s1 <- s1 + 0.5
    s0 <- s0 + 0.5
    corrected <- TRUE
  }
  if (corrected) {
    warning("Continuity correction (+0.5) has been applied to the pair(s) with zeros.")
  }

  # Denominators after possible correction
  n_cases <- s1 + s0
  n_ctrls <- r1 + r0

  # ---- Basic calculations ----
  Sp     <- r0 / n_ctrls
  Se     <- if (n_cases > 0) s1 / n_cases else NA_real_
  Youden <- if (!is.na(Se)) (Se + Sp - 1) else NA_real_

  if (!is.na(Youden) && Youden <= 0) {
    warning("Youden index <= 0; the test does not discriminate better than chance.")
  } else if (is.na(Youden)) {
    warning("Youden cannot be evaluated (cases are missing: s1 + s0 = 0).")
  }

  # Standard error of Sp
  se_Sp <- sqrt(Sp * (1 - Sp) / n_ctrls)

  # Critical value
  z <- stats::qnorm(1 - (1 - conflev) / 2)

  # ---- Confidence interval for Sp ----
  x <- r0
  n <- n_ctrls
  p_hat <- x / n

  # Agresti-Coull
  n_tilde <- n + z^2
  p_tilde <- (x + (z^2) / 2) / n_tilde
  half    <- z * sqrt(p_tilde * (1 - p_tilde) / n_tilde)
  CI <- c(max(0, p_tilde - half), min(1, p_tilde + half))
  method <- "Agresti-Coull"

  # ---- output ----

  cat("\n")
  cat(" S P E C I F I C I T Y \n")
  cat("-----------------------\n")
  cat("\n")
  cat("Specificity estimated is:", round(Sp,digits), "\n")
  cat("Standard error estimated is:", round(se_Sp,digits), "\n")
  cat(method,"Method for",100*conflev,"%CI for specificity is [", round(CI[[1]],digits),";", round(CI[[2]],digits),"]\n")
  cat("\n")

  invisible(list(
    est = Sp, se = se_Sp, ci_lower = CI[[1]], ci_upper = CI[[2]],
    ci_method = method, conf_level = conflev
  ))
}
