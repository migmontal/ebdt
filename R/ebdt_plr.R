
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the Positive likelihood ratio (LR+)
#' with Simel and Gart - Nam ICs
#'
#' @title Calculates the Positive likelihood ratio
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @returns list with:
#'   - est: LR+ = Se / (1 - Sp)
#'   - std.err: EE(LR+) by delta method from the variance in log-LR+
#'   - CI1.sl: lower limit (Simel, log-normal)
#'   - CI.su:  upper limit (Simel, log-normal)
#'   - CI.gnl: lower limit (Gart & Nam)
#'   - CI.gnu: upper limit (Gart & Nam)
#'
#' @export
#' @references Agresti, A., (2002). Categorical Data Analysis.
#'        John Wiley and Sons, New York.
#'
#' @references Agresti, A., Coull, B.A., (1998). Approximate is better than ‘exact’
#'        for interval estimation of binomial proportions.
#'        The American Statistician, 52:119 – 126.
#'
#' @references Gart, J.J., Nam J., (1988). Aproximate interval estimation of the
#'        ratio of binomial parameters: a review and corrections for skewness.
#'        Biometrics, 44: 323 – 338.
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
#' @description This function calculate the Positive Likelihood Ratio estimator,
#'  their standard error estimated and a confidence interval in a traverse or
#'  Cross-sectional study.
#' @details Requires a `gn_plr()` function in the environment and `rootall()`
#'  function in the environment (the robust version reviewed above is suitable).
#'
#' @examples ebdt_plr(7450, 2001, 2003, 5850)
#'
ebdt_plr <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
  # ---- Input validation ----
  vals <- c(s1, s0, r1, r0)
  if (any(!is.numeric(vals)) || any(!is.finite(vals))) {
    stop("s1, s0, r1, r0 must be finite numeric scalars.")
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

  if (!exists("gn_plr", mode = "function")) {
    stop("'gn_plr' function is not available.")
  }

  # ---- Original denominators ----
  ss <- s1 + s0
  rr <- r1 + r0
  if (ss <= 0) stop("s1 + s0 must be > 0. ")
  if (rr <= 0) stop("r1 + r0 must be > 0. ")

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
    warning(sprintf("Continuity correction (+0.5) applied to pairs: %s",
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
  if (Sp >= 1) Sp <- 1 - .Machine$double.eps
  if (Se <= 0) Se <- .Machine$double.eps

  LRpos <- Se / (1 - Sp)

  # ---- Standard error by delta (from var(log LR+)) ----
  var_logLR <- (1 - Se) / (ss * Se) + (Sp) / (rr * (1 - Sp))
  se_logLR  <- sqrt(var_logLR)
  sigmaLRp  <- LRpos * se_logLR

  # ---- IC Simel (log-normal) ----
  z <- stats::qnorm(1 - (1 - conflev) / 2)
  LinfLRp <- exp(log(LRpos) - z * se_logLR)
  LsupLRp <- exp(log(LRpos) + z * se_logLR)

  # ---- IC Gart & Nam ----
  A <- gn_plr(s1, r1, s0, r0, conflev)
  LinfGNLRp <- if (!is.null(A$LinfGNLRp) && is.finite(A$LinfGNLRp) && A$LinfGNLRp > 0) A$LinfGNLRp else NA_real_
  LsupGNLRp <- if (!is.null(A$LsupGNLRp) && is.finite(A$LsupGNLRp) && A$LsupGNLRp > 0) A$LsupGNLRp else NA_real_
  if (is.finite(LinfGNLRp) && is.finite(LsupGNLRp) && LinfGNLRp > LsupGNLRp) {
    tmp <- LinfGNLRp; LinfGNLRp <- LsupGNLRp; LsupGNLRp <- tmp
  }

  # Span (width) of CI
  sim_width <- if (all(is.finite(c(LinfLRp, LsupLRp)))) LsupLRp - LinfLRp else NA_real_
  gn_width  <- if (all(is.finite(c(LinfGNLRp, LsupGNLRp)))) LsupGNLRp - LinfGNLRp else NA_real_

  # ---- Output ----

  cat("\n")
  cat(" P O S I T I V E   L I K E L I H O O D   R A T I O \n")
  cat("---------------------------------------------------\n")
  cat("\n")
  cat("Positive Likelihood Ratio estimated is:", round(LRpos,digits), "\n")
  cat("Standard error estimated is:", round(sigmaLRp,digits), "\n")
  cat("Simel",100*conflev,"%CI for LR+ is [", round(LinfLRp,digits),";", round(LsupLRp,digits),"]\n")
  cat("Gart-Nam",100*conflev,"%CI for LR+ is [", round(LinfGNLRp,digits),";", round(LsupGNLRp,digits),"]\n")
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
    est = LRpos, se = sigmaLRp,
    simel_ci_lower = LinfLRp, simel_ci_upper = LsupLRp,
    gartnam_ci_lower = LinfGNLRp, gartnam_ci_upper = LsupGNLRp,
    conf_level = conflev
  ))
}
