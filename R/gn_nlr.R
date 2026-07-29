
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' Gart-Nam (GN) CI for negative likelihood ratio (LR-)
#'
#' @title Calculate Gart-Nam CI for negative likelihood ratio
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
#' @description This function calculate Gart-Nam Confidence Interval for
#'  Negative Likelihood Ratio.
#'
#' @details Requires a `rootall()` function in the environment
#'   (the robust version reviewed above is suitable).
#'
#' @examples gn_nlr(7450, 2001, 2003, 5850)
#'
gn_nlr <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
  #--------------------------------
  # Input validation
  #--------------------------------
  vals <- c(s1, s0, r1, r0)
  if (any(!is.numeric(vals)) || any(!is.finite(vals))) {
    stop("s1, s0, r1, r0 must be finite numeric.")
  }
  if (any(vals < 0)) {
    stop("Values cannot be negative.")
  }
  if (!is.numeric(conflev) || length(conflev) != 1L || conflev <= 0 || conflev >= 1) {
    stop("conflev must be within the interval (0, 1).")
  }
  if (!exists("rootall", mode = "function")) {
    stop("'rootall' function is not available in the environment.")
  }

  #--------------------------------
  # Parameters and auxiliaries
  #--------------------------------
  ss <- s1 + s0
  rr <- r1 + r0
  if (ss <= 0) stop("s1 + s0 must be > 0.")
  if (rr <= 0) stop("r1 + r0 must be > 0.")
  nn <- ss + rr
  zalpha <- stats::qnorm(1 - (1 - conflev) / 2)

  # Search parameters
  lower0 <- 1e-8        # avoid x = 0initial level
  upper0 <- 1e3         # initial level
  n0     <- 1000L       # initial resolution
  max_expand <- 3L      # nº máximo de expansiones de cota
  expand_factor <- 10   # factor de expansión de upper
  densify_factor <- 5   # factor de densificación de malla por intento

  #--------------------------------
  # Mathematical assistants
  #--------------------------------
  .Sptilde_nlr <- function(x, plus = TRUE) {
    if (!is.finite(x) || x <= 0) return(NA_real_)
    A <- rr + s0 + (r0 + ss) * x
    D <- -4 * nn * (r0 + s0) * x + (-rr - s0 - (r0 + ss) * x)^2
    if (!is.finite(D) || D < 0) return(NA_real_)
    num <- A + (if (plus) +sqrt(D) else -sqrt(D))
    den <- 2 * nn * x
    if (den == 0) return(NA_real_)
    Sp_tilde <- num / den
    # Restrict to (0,1) to avoid spurious values
    if (!is.finite(Sp_tilde) || Sp_tilde <= 0 || Sp_tilde >= 1) return(NA_real_)
    Sp_tilde
  }

  # Statistic that must be cancelled (a3/a4/b3/b4)
  .score_nlr <- function(x, plus = TRUE, sign = +1) {
    Sp <- .Sptilde_nlr(x, plus = plus)
    if (!is.finite(Sp)) return(NA_real_)
    denom1 <- rr * Sp
    denom2 <- ss * Sp * x
    if (denom1 <= 0 || denom2 <= 0) return(NA_real_)
    utilde <- (1 - Sp) / denom1 + (1 - Sp * x) / denom2
    if (!is.finite(utilde) || utilde <= 0) return(NA_real_)
    vtilde <- 1 / utilde
    numer  <- (s0 - ss * Sp * x)
    denom  <- (1 - Sp * x) * sqrt(vtilde)
    if (!is.finite(denom) || denom == 0) return(NA_real_)
    (numer / denom) + sign * zalpha
  }

  a3 <- function(x) .score_nlr(x, plus = TRUE,  sign = -1)
  a4 <- function(x) .score_nlr(x, plus = TRUE,  sign = +1)
  b3 <- function(x) .score_nlr(x, plus = FALSE, sign = -1)
  b4 <- function(x) .score_nlr(x, plus = FALSE, sign = +1)

  #--------------------------------
  # Root search with retries
  #--------------------------------
  find_roots_pair <- function(f_low, f_high, lower, upper, n) {
    d_low  <- rootall(f_low,  c(lower, upper), n = n)
    d_high <- rootall(f_high, c(lower, upper), n = n)
    list(low = d_low, high = d_high)
  }

  attempt <- 0L
  upper   <- upper0
  ngrid   <- n0

  roots_a <- find_roots_pair(a3, a4, lower0, upper, ngrid)  # rama +sqrt
  roots_b <- find_roots_pair(b3, b4, lower0, upper, ngrid)  # rama -sqrt

  while ((length(roots_a$low)  == 0L || length(roots_a$high) == 0L ||
          length(roots_b$low)  == 0L || length(roots_b$high) == 0L) &&
         attempt < max_expand) {
    attempt <- attempt + 1L
    upper   <- min(upper * expand_factor, 1e6)
    ngrid   <- ngrid * densify_factor
    roots_a <- find_roots_pair(a3, a4, lower0, upper, ngrid)
    roots_b <- find_roots_pair(b3, b4, lower0, upper, ngrid)
  }

  pick_first <- function(v) if (length(v)) v[1] else NA_real_

  u5 <- pick_first(roots_a$low)
  u6 <- pick_first(roots_a$high)
  u7 <- pick_first(roots_b$low)
  u8 <- pick_first(roots_b$high)

  #--------------------------------
  # Validation and peer selection
  #--------------------------------
  valid_pair <- function(uL, uU, plus) {
    if (!is.finite(uL) || !is.finite(uU) || uL <= 0 || uU <= 0 || uL > uU) return(FALSE)
    SpL <- .Sptilde_nlr(uL, plus = plus)
    SpU <- .Sptilde_nlr(uU, plus = plus)
    if (!is.finite(SpL) || !is.finite(SpU)) return(FALSE)
    (SpL > 0 && SpL < 1 && SpU > 0 && SpU < 1)
  }

  L3 <- NA_real_; L4 <- NA_real_

  # Prioritize by +sqrt (a3,a4); if not, use -sqrt (b3,b4)
  if (valid_pair(u5, u6, plus = TRUE)) {
    L3 <- u5; L4 <- u6
  } else if (valid_pair(u7, u8, plus = FALSE)) {
    L3 <- u7; L4 <- u8
  } else {
    # Fallback if a branch yields a plausible ordered pair
    if (is.finite(u5) && is.finite(u6) && u5 > 0 && u6 > 0 && u5 <= u6) { L3 <- u5; L4 <- u6 }
    else if (is.finite(u7) && is.finite(u8) && u7 > 0 && u8 > 0 && u7 <= u8) { L3 <- u7; L4 <- u8 }
  }

  if (!is.finite(L3) || !is.finite(L4)) {
    warning("No valid roots could be determined for the Gart - Nam IC of LR-.")
  }

  list(LinfGNLRn = L3, LsupGNLRn = L4)
}
