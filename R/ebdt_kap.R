
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' This function calculates the "Kappa" coefficient weighted by c (0.1..0.9)
#' with Wald and Logit ICs
#'
#' @title Calculate the weighted Kappa coefficient
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#'
#' @return data.frame, in columns:
#'   c_index, Kappa, StdError, CI_Wald_L, CI_Wald_U, CI_Logit_L, CI_Logit_U
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
#' @references Roldán Nofuentes J.A., Luna del Castillo J.D., Montero Alonso, M.A., (2009).
#'        Confidence intervals of weighted kappa coefficient of a binary diagnostic test.
#'        Communications in Statistics. Simulation and Computation, 38: 1562 – 1578.
#'
#' @references Pepe, M. S. (2003). The statistical evaluation of medical tests for
#'        classification and prediction. Oxford University Press.
#'
#' @references Zhou, X.-H., Obuchowski, N. A., y McClish, D. K. (2011). Statistical
#'        Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.
#'
#' @description This function calculate the Weighted Kappa Coeficient estimator,
#'  their standard error estimated  with Wald and Logit confidence interval
#'   in a traverse study.
#' @examples ebdt_kap(7450, 2001, 2003, 5850)
#'
ebdt_kap <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
  # ---- Input validation ----
  vals <- c(s1, s0, r1, r0)
  if (any(!is.numeric(vals)) || any(!is.finite(vals))) {
    stop("s1, s0, r1, r0 must be finite numeric scalars.")
  }
  if (any(lengths(list(s1, r1, s0, r0)) != 1L)) {
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

  ss <- s1 + s0
  rr <- r1 + r0
  nn <- ss + rr
  if (ss <= 0) stop("s1 + s0 must be > 0.")
  if (rr <= 0) stop("r1 + r0 must be > 0.")

  # ---- Zero correction (Haldane–Anscombe) BY PAIRS ----
  corrected <- character(0)
  if (s1 == 0) { s1 <- s1 + 0.5; corrected <- c(corrected, "s1") }
  if (s0 == 0) { s0 <- s0 + 0.5; corrected <- c(corrected, "s0") }
  if (r1 == 0) { r1 <- r1 + 0.5; corrected <- c(corrected, "r1") }
  if (r0 == 0) { r0 <- r0 + 0.5; corrected <- c(corrected, "r0") }
  if (length(corrected) > 0) {
    warning(sprintf("Continuity correction (+0.5) applied to pairs: %s",
                    paste(corrected, collapse = ", ")))
  }

  # Recalculate metrics
  ss <- s1 + s0
  rr <- r1 + r0
  nn <- ss + rr

  Se <- s1 / ss
  Sp <- r0 / rr
  Youden <- Se + Sp - 1
  if (Youden <= 0) {
    warning("Youden index <= 0; the test does not discriminate better than chance.")
  }

  # ---- c Index configuration  ---
  pindex <- seq(0.1, 0.9, 0.1)

  # ---- Critical value ----
  z <- stats::qnorm(1 - (1 - conflev) / 2)

  # Data frame de salida
  result <- data.frame(
    c_index    = pindex,
    Kappa      = NA_real_,
    StdError   = NA_real_,
    CI_Wald_l  = NA_real_,
    CI_Wald_u  = NA_real_,
    CI_Logit_l = NA_real_,
    CI_Logit_u = NA_real_,
    Best       = rep(NA_character_, length(pindex)),
    stringsAsFactors = FALSE
  )

  # ---- Loop through c ----
  for (i in seq_along(pindex)) {
    c <- pindex[i]

    # "kap(c)"; simplifies to the numerator = s1*r0 - s0*r1
    num <- s1 * (r1 + r0) + r0 * (s1 + s0) - (s1 + s0) * (r1 + r0)
    den <- ((s0 + r0) * (s1 + s0) * c) + ((s1 + r1) * (r1 + r0) * (1 - c))

    kap <- NA_real_
    se  <- NA_real_
    Lw  <- NA_real_; Uw <- NA_real_
    Ll  <- NA_real_; Ul <- NA_real_

    # Validate denominator and calculate kap
    if (is.finite(den) && den != 0) {
      kap <- num / den
      var_kap <- kap * (1 - kap) / nn

      # Ensure var >= 0
      if (!is.finite(var_kap) || var_kap < 0) var_kap <- NA_real_

      # Std. Error
      se <- if (is.finite(var_kap) && var_kap >= 0) sqrt(var_kap) else NA_real_

      # Wald CI on original scale, truncated to [-1, 1]
      if (is.finite(kap) && is.finite(se)) {
        Lw <- max(-1, kap - z * se)
        Uw <- min( 1, kap + z * se)
      }

      # IC Logit: se_logit = se / (kap*(1-kap))
      # Protection when kap ~ 0 or 1, or var_kap is not finite
      if (is.finite(kap) && is.finite(se) && kap > 0 && kap < 1) {
        se_logit <- se / (kap * (1 - kap))
        if (is.finite(se_logit) && se_logit >= 0) {
          lo <- stats::plogis(stats::qlogis(kap) - z * se_logit)
          hi <- stats::plogis(stats::qlogis(kap) + z * se_logit)
          Ll <- max(-1, lo)
          Ul <- min( 1, hi)
        }
      }
    } else {
      warning(sprintf("Invalid denominator (<=0 or NA) for c = %.1f; NA is returned.", c))
    }

    #Best CI by width (handles NAs)
    w_width <- if (is.finite(Lw) && is.finite(Uw)) Uw - Lw else NA_real_
    l_width <- if (is.finite(Ll) && is.finite(Ul)) Ul - Ll else NA_real_
    best_ci <- if (is.finite(w_width) && is.finite(l_width)) {
      if (w_width < l_width) "Wald" else if (w_width > l_width) "Logit" else "="
    } else if (is.finite(w_width)) {
      "Wald"
    } else if (is.finite(l_width)) {
      "Logit"
    } else {
      NA_character_
    }

    result[i, ] <- list(
      c_index    = c,
      Kappa      = round(kap, digits),
      StdError   = round(se, digits),
      CI_Wald_l  = round(Lw, digits),
      CI_Wald_u  = round(Uw, digits),
      CI_Logit_l = round(Ll, digits),
      CI_Logit_u = round(Ul, digits),
      Best       = best_ci
    )
  }

  # ---- Output ----

  cat("\n")
  cat(" W E I G H T E D   K A P P A   C O E F I C I E N T \n")
  cat("---------------------------------------------------\n")
  cat("\n")
  cat("All Confidence Intervals are at",100*conflev,"%,\n")
  cat("\n")

  print(result)
  invisible(result)
}
