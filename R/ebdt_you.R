
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the Youden Index, standard error & Agresti-Coull CI
#'
#' @title Calculate Youden index
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @returns list with:
#'   - YoudenIndex: Youden Index estimation J = Se + Sp - 1
#'   - StdError: standard error of J by delta method assuming independence of cases and controls
#'   - CI: approximate normal confidence interval for J
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
#' @references Youden, W.J., (1950). Index for rating diagnostic tests. Cancer, 3: 32 – 35.
#'
#' @references Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
#'        Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.
#'
#' @description This function calculate Youden index estimator, their standard error
#'  estimated and a confidence interval in a traverse or Cross-sectional study.
#'
#' @details
#' - Corrección Haldane–Anscombe *in pairs* if there are zeros: (s1,s0) and/or (r1,r0),
#'    +0.5 is added to both cells of the pair.
#' - EE(J) is calculated as: sqrt( Se*(1-Se)/n_cases + Sp*(1-Sp)/n_ctrls ),
#'   valid under independence between cases and controls (common in diagnostic studies).
#' - IC is constructed with normal approximation: J ± z * EE(J).
#'
#' @examples ebdt_you(40, 5, 10, 45)
#'
ebdt_you <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
  # ---- Input validation ----
  vals <- c(s1, s0, r1, r0)
  if (any(!is.numeric(vals)) || any(!is.finite(vals))) {
    stop("All arguments s1, r1, s0, r0 must be finite numeric.")
  }
  if (any(lengths(list(s1, r1, s0, r0)) != 1)) {
    stop("s1, r1, s0, r0 must be length-1 scalars.")
  }
  if (any(vals < 0)) {
    stop("The values cannot be negative.")
  }
  if (!is.numeric(conflev) || length(conflev) != 1 || conflev <= 0 || conflev >= 1) {
    stop("conflev must be within the interval (0, 1).")
  }
  if (!is.numeric(digits) || length(digits) != 1 || digits < 0) {
    stop("digits must be a single non-negative integer.")
  }
  digits <- as.integer(digits)

  # ---- Denominators ----
  n_cases <- s1 + s0
  n_ctrls <- r1 + r0
  if (n_cases == 0) stop("s1 + s0 = 0. Sensitivity (Se) cannot be calculated.")
  if (n_ctrls == 0) stop("r1 + r0 = 0. Specificity (Sp) cannot be calculated.")

  # ---- Pairwise Haldane–Anscombe correction ----
  corrected_pairs <- character(0)
  if (s1 == 0 || s0 == 0) {
    s1 <- s1 + 0.5
    s0 <- s0 + 0.5
    corrected_pairs <- c(corrected_pairs, "(s1,s0)")
  }
  if (r1 == 0 || r0 == 0) {
    r1 <- r1 + 0.5
    r0 <- r0 + 0.5
    corrected_pairs <- c(corrected_pairs, "(r1,r0)")
  }
  if (length(corrected_pairs) > 0) {
    warning(sprintf("Continuity correction (+0.5) applied to the pairs: %s",
                    paste(corrected_pairs, collapse = ", ")))
  }

  # Recalculate denominators after possible corrections
  n_cases <- s1 + s0
  n_ctrls <- r1 + r0

  # ---- Basic calculations ----
  Se <- s1 / n_cases
  Sp <- r0 / n_ctrls
  Youden <- Se + Sp - 1

  # ---- Standard error by delta method (independent cases and controls) ----
  se.Youden <- sqrt(Se * (1 - Se) / n_cases + Sp * (1 - Sp) / n_ctrls)

  # ---- Approximate normal CI for J (truncated to [-1, 1]) ----
  z <- stats::qnorm(1 - (1 - conflev) / 2)
  CI_raw <- c(Youden - z * se.Youden, Youden + z * se.Youden)
  CI <- c(max(-1, CI_raw[1]), min(1, CI_raw[2]))

  # ---- Note and warnings ----
  note_msg <- if (Youden <= 0) {
    warning("Youden index <= 0; the test does not discriminate better than chance.")
    "Youden <= 0 (does not discriminate better than chance)"
  } else {
    "OK"
  }

  # ---- Output ----

  cat("\n")
  cat(" Y O U D E N  I N D E X \n")
  cat("------------------------\n")
  cat("\n")
  cat("Youden index estimated is:", round(Youden,digits), "\n")
  cat("Standard error estimated is:", round(se.Youden,digits), "\n")
  cat(100*conflev,"%CI for Youden index is [", round(CI[[1]],digits),";", round(CI[[2]],digits),"]\n")
  cat("\n")

  invisible(list(
    est = Youden, se = se.Youden, ci_lower = CI[[1]], ci_upper = CI[[2]],
    ci_method = "normal_approx", conf_level = conflev, youden_note = note_msg
  ))
}
