
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the sensitivity, standard error & Agresti-Coull CI
#'
#' @title Calculate Sensitivity
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @returns  list with:
#'   - Sensitivity: sensitivity estimation (Se = s1/(s1+s0))
#'   - StdError: binomial standard error of Se
#'   - CI: vector c(inf, sup) IC for Se
#'   - CI_Method: "Agresti-Coull"
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
#'   - Apply continuity correction (Haldane–Anscombe) *in pairs* if there are zeros:
#'    (s1,s0) and/or (r1,r0), avoiding adding 0.5 to cells not related to the
#'    estimated proportion.
#'   - For Wilson, the standard center and half-width are used:
#'     center = (p + z^2/(2n)) / (1 + z^2/n)
#'     half   = z/(1 + z^2/n) * sqrt(p(1-p)/n + z^2/(4n^2))
#'   - For Agresti-Coull:
#'     n_tilde = n + z^2; p_tilde = (x + z^2/2)/n_tilde; half = z*sqrt(p_tilde(1-p_tilde)/n_tilde)
#'
#' @description This function calculate the sensitivity estimator, their
#' standard error estimated and a confidence interval in a traverse or Cross-sectional study.
#'
#' @examples ebdt_se(40, 5, 10, 45)  # Se  0.80 with IC (Agresti-Coull, n=50)
#'
ebdt_se <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
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
  n_cases  <- s1 + s0
  n_ctrls  <- r1 + r0
  if (n_cases == 0) stop("s1 + s0 = 0. Sensitivity cannot be calculated.")

  # ---- Zero correction (Haldane–Anscombe) BY PAIRS ----
  corrected <- FALSE
  if (s1 == 0 || s0 == 0) {
    s1 <- s1 + 0.5
    s0 <- s0 + 0.5
    corrected <- TRUE
  }
  if (r1 == 0 || r0 == 0) {
    r1 <- r1 + 0.5
    r0 <- r0 + 0.5
    corrected <- TRUE
  }
  if (corrected) {
    warning("Continuity correction (+0.5) has been applied to the pair(s) with zeros.")
  }

  # Denominators after possible correction
  n_cases <- s1 + s0
  n_ctrls <- r1 + r0

  # ---- Basic calculations ----
  Se     <- s1 / n_cases
  Sp     <- if (n_ctrls > 0) r0 / n_ctrls else NA_real_
  Youden <- if (!is.na(Sp)) (Se + Sp - 1) else NA_real_

  if (!is.na(Youden) && Youden <= 0) {
    warning("Youden index <= 0; the test does not discriminate better than chance.")
  }

  # Standard error of Se
  se_Se <- sqrt(Se * (1 - Se) / n_cases)

  # Critical value
  z <- stats::qnorm(1 - (1 - conflev) / 2)

  # ---- Confidence Interval for Se ----
  x <- s1
  n <- n_cases
  p_hat <- x / n

  # Agresti-Coull
  n_tilde <- n + z^2
  p_tilde <- (x + (z^2) / 2) / n_tilde
  half    <- z * sqrt(p_tilde * (1 - p_tilde) / n_tilde)
  CI <- c(max(0, p_tilde - half), min(1, p_tilde + half))
  method <- "Agresti-Coull"

  # ---- Output ----

  cat("\n")
  cat(" S E N S I T I V I T Y \n")
  cat("-----------------------\n")
  cat("\n")
  cat("Sensitivity estimated is:", round(Se,digits), "\n")
  cat("Standard error estimated is:", round(se_Se,digits), "\n")
  cat(method,"Method for",100*conflev,"%CI for sensitivity is [", round(CI[[1]],digits),";", round(CI[[2]],digits),"]\n")
  cat("\n")

  invisible(list(
    est = Se, se = se_Se, ci_lower = CI[[1]], ci_upper = CI[[2]],
    ci_method = method, conf_level = conflev
  ))
}
