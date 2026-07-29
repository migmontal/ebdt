
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the Negative likelihood ratio (LR-)
#' with Simel and Gart - Nam ICs
#'
#' @title Calculates the Negative likelihood ratio
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @returns list with:
#'   - LinfGNLRn: lower limit of the IC GN for LR-
#'   - LsupGNLRn: upper limit of the IC GN for LR-
#'
#' @export
#' @references Agresti, A., (2002). Categorical Data Analysis.
#'        John Wiley and Sons, New York.
#'
#' @references Gart, J.J., Nam J., (1988). Aproximate interval estimation of the
#'        ratio of binomial parameters: a review and corrections for skewness.
#'        Biometrics, 44: 323 – 338.
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
#' @description This function calculate the Negative Likelihood Ratio estimator,
#'  their standard error estimated and a confidence interval in a traverse or
#'  Cross-sectional study.
#'
#' @details Requires a `gn_nlr()` function in the environment and `rootall()`
#'  function in the environment (the robust version reviewed above is suitable).
#'
#' @examples ebdt_nlr(7450, 2001, 2003, 5850)
#'
ebdt_nlr <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
  # ---- Input validation ----
  vals <- c(s1, s0, r1, r0)
  if (any(!is.numeric(vals)) || any(!is.finite(vals))) {
    stop("s1, s0, r1, r0 must be finite numeric scalars.")
  }
  if (any(lengths(list(s1, r1, s0, r0)) != 1L)) {
    stop("s1, r1, s0, r0 must be length-1 scalars.")
  }
  if (any(vals < 0)) {
    stop("The values cannot be negative.")
  }
  if (!is.numeric(conflev) || length(conflev) != 1L || conflev <= 0 || conflev >= 1) {
    stop("conflev must be within the interval (0, 1).")
  }
  if (!is.numeric(digits) || length(digits) != 1L || digits < 0) {
    stop("digits must be a single non-negative integer.")
  }
  digits <- as.integer(digits)
  if (!exists("gn_nlr", mode = "function")) {
    stop("Gart-Nam CI requires function 'gn_nlr' to be available in the environment.")
  }

  # ---- Original denominators ----
  ss <- s1 + s0
  rr <- r1 + r0
  if (ss <= 0) stop("s1 + s0 must be > 0.")
  if (rr <= 0) stop("r1 + r0 must be > 0.")

  # ---- Zero correction (Haldane–Anscombe) BY PAIRS ----
  corrected <- character(0)
  if (s1 == 0 || s0 == 0) {
    s1 <- s1 + 0.5; s0 <- s0 + 0.5
    corrected <- c(corrected, "(s1,s0)")
  }
  if (r1 == 0 || r0 == 0) {
    r1 <- r1 + 0.5; r0 <- r0 + 0.5
    corrected <- c(corrected, "(r1,r0)")
  }
  if (length(corrected) > 0) {
    warning(sprintf("Continuity correction (+0.5) has been applied to the pair(s) with zeros.",
                    paste(corrected, collapse = ", ")))
  }

  # ---- Recalculate metrics ----
  ss <- s1 + s0
  rr <- r1 + r0
  Se <- s1 / ss
  Sp <- r0 / rr
  You <- Se + Sp - 1
  if (You <= 0) {
    warning("Youden index <= 0; the test does not discriminate better than chance.")
  }

  # Avoid LR- degenerations
  if (Sp <= 0) Sp <- .Machine$double.eps
  if (Se >= 1) Se <- 1 - .Machine$double.eps

  LRneg <- (1 - Se) / Sp

  # ---- Standard error by delta (from var(log LR-)) ----
  var_logLR <- Se / (ss * (1 - Se)) + (1 - Sp) / (rr * Sp)
  se_logLR  <- sqrt(var_logLR)
  sigmaLRn  <- LRneg * se_logLR

  # ---- IC Simel (log-normal) ----
  z <- stats::qnorm(1 - (1 - conflev) / 2)
  LinfLRn <- exp(log(LRneg) - z * se_logLR)
  LsupLRn <- exp(log(LRneg) + z * se_logLR)

  # ---- IC Gart & Nam ----
  B <- gn_nlr(s1, r1, s0, r0, conflev)
  LinfGNLRn <- if (!is.null(B$LinfGNLRn) && is.finite(B$LinfGNLRn) && B$LinfGNLRn > 0) B$LinfGNLRn else NA_real_
  LsupGNLRn <- if (!is.null(B$LsupGNLRn) && is.finite(B$LsupGNLRn) && B$LsupGNLRn > 0) B$LsupGNLRn else NA_real_
  if (is.finite(LinfGNLRn) && is.finite(LsupGNLRn) && LinfGNLRn > LsupGNLRn) {
    tmp <- LinfGNLRn; LinfGNLRn <- LsupGNLRn; LsupGNLRn <- tmp
  }

  # Span (width) of CI
  sim_width <- if (all(is.finite(c(LinfLRn, LsupLRn)))) LsupLRn - LinfLRn else NA_real_
  gn_width  <- if (all(is.finite(c(LinfGNLRn, LsupGNLRn)))) LsupGNLRn - LinfGNLRn else NA_real_

  # ---- Output ----

  cat("\n")
  cat(" N E G A T I V E   L I K E L I H O O D   R A T I O \n")
  cat("---------------------------------------------------\n")
  cat("\n")
  cat("Negative Likelihood Ratio estimated is:", round(LRneg,digits), "\n")
  cat("Standard error estimated is:", round(sigmaLRn,digits), "\n")
  cat("Simel",100*conflev,"%CI for LR- is [", round(LinfLRn,digits),";", round(LsupLRn,digits),"]\n")
  cat("Gart-Nam",100*conflev,"%CI for LR- is [", round(LinfGNLRn,digits),";", round(LsupGNLRn,digits),"]\n")
  cat("\n")
  if (is.finite(sim_width) && is.finite(gn_width)) {
    if (sim_width < gn_width) {
      cat("Simel CI is narrower than Gart-Nam CI.\n")
    } else if (sim_width > gn_width) {
      cat("Gart-Nam CI is narrower than Simel CI.\n")
    } else {
      cat("Both intervals have the same width.\n")
    }
  } else if (is.finite(sim_width) && !is.finite(gn_width)) {
    cat("Only Simel CI is available.\n")
  } else if (!is.finite(sim_width) && is.finite(gn_width)) {
    cat("Only Gart-Nam CI is available.\n")
  } else {
    cat("No valid confidence interval could be computed.\n")
  }
  cat("\n")

  invisible(list(
    est = LRneg, se = sigmaLRn,
    simel_ci_lower = LinfLRn, simel_ci_upper = LsupLRn,
    gartnam_ci_lower = LinfGNLRn, gartnam_ci_upper = LsupGNLRn,
    conf_level = conflev
  ))
}
