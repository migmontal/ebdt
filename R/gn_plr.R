
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' Gart-Nam (GN) CI for positive likelihood ratio (LR+)
#'
#' @title Calculate Gart-Nam CI for positive likelihood ratio
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#' @export
#'
#' @returns list with:
#'   - LinfGNLRp: lower limit of the IC GN for LR+
#'   - LsupGNLRp: upper limit of the IC GN for LR+
#'
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
#'  Positive Likelihood Ratio.
#'
#' @details Requires a `rootall()` function in the environment
#'      (the robust version reviewed above is suitable).
#'
#' @examples gn_plr(40, 5, 10, 45)
#'
gn_plr <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3) {
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
  lower0 <- 1e-8        # avoid x = 0
  upper0 <- 1e2         # initial level
  n0     <- 200L       # initial resolution
  max_expand <- 2L      # Maximum number of elevation expansions
  expand_factor <- 10   # Upper expansion factor
  densify_factor <- 2   # Mesh densification factor per attempt

  #--------------------------------
  # Mathematical assistants
  #--------------------------------
  .Sptilde <- function(x, plus = TRUE) {
    # x>0, check domain
    if (!is.finite(x) || x <= 0) return(NA_real_)
    A <- rr + x * (-2 * nn + r1 + ss) + s1
    D <- -4 * x * nn * r1 + (rr + x * (r1 + ss))^2 +
      2 * (rr + x * (-2 * nn + r1 + ss)) * s1 + s1^2
    if (!is.finite(D) || D < 0) return(NA_real_)
    num <- -(A + (if (plus) +sqrt(D) else -sqrt(D)))
    den <- 2 * x * nn
    if (den == 0) return(NA_real_)
    Sp_tilde <- num / den
    # restrict to [0,1] with slight tolerance (return NA if clearly out)
    if (!is.finite(Sp_tilde) || Sp_tilde <= 0 || Sp_tilde >= 1) return(NA_real_)
    Sp_tilde
  }

  # Construct the "score" that must be annulled in the functions a1/a2/b1/b2
  .score <- function(x, plus = TRUE, sign = +1) {
    Sp <- .Sptilde(x, plus = plus)
    if (!is.finite(Sp)) return(NA_real_)
    denom1 <- rr * (1 - Sp)
    denom2 <- ss * (1 - Sp) * x
    if (denom1 <= 0 || denom2 <= 0) return(NA_real_)
    utilde <- (Sp / denom1) + ((1 - (1 - Sp) * x) / denom2)
    if (!is.finite(utilde) || utilde <= 0) return(NA_real_)
    vtilde <- 1 / utilde
    numer <- (s1 - ss * (1 - Sp) * x)
    denom <- (1 - (1 - Sp) * x) * sqrt(vtilde)
    if (!is.finite(denom) || denom == 0) return(NA_real_)
    (numer / denom) + sign * zalpha
  }

  a1 <- function(x) .score(x, plus = TRUE,  sign = -1)
  a2 <- function(x) .score(x, plus = TRUE,  sign = +1)
  b1 <- function(x) .score(x, plus = FALSE, sign = -1)
  b2 <- function(x) .score(x, plus = FALSE, sign = +1)

  #--------------------------------
  # Root search with retries
  #--------------------------------
  find_roots_pair <- function(f_low, f_high, lower, upper, n) {
    d_low  <- rootall(f_low,  c(lower, upper), n = n)
    d_high <- rootall(f_high, c(lower, upper), n = n)
    list(low = d_low, high = d_high)
  }

  attempt <- 0L
  upper <- upper0
  ngrid <- n0

  roots_a <- find_roots_pair(a1, a2, lower0, upper, ngrid)
  roots_b <- find_roots_pair(b1, b2, lower0, upper, ngrid)

  while ((length(roots_a$low)  == 0L || length(roots_a$high) == 0L ||
          length(roots_b$low)  == 0L || length(roots_b$high) == 0L) &&
         attempt < max_expand) {
    attempt <- attempt + 1L
    upper   <- min(upper * expand_factor, 1e6)
    ngrid   <- ngrid * densify_factor
    roots_a <- find_roots_pair(a1, a2, lower0, upper, ngrid)
    roots_b <- find_roots_pair(b1, b2, lower0, upper, ngrid)
  }

  pick_first <- function(v) if (length(v)) v[1] else NA_real_

  u1 <- pick_first(roots_a$low)
  u2 <- pick_first(roots_a$high)
  u3 <- pick_first(roots_b$low)
  u4 <- pick_first(roots_b$high)

  #--------------------------------
  # Validation and peer selection
  #--------------------------------
  valid_pair <- function(uL, uU, plus) {
    if (!is.finite(uL) || !is.finite(uU) || uL <= 0 || uU <= 0 || uL > uU) return(FALSE)
    SpL <- .Sptilde(uL, plus = plus)
    SpU <- .Sptilde(uU, plus = plus)
    if (!is.finite(SpL) || !is.finite(SpU)) return(FALSE)
    (SpL > 0 && SpL < 1 && SpU > 0 && SpU < 1)
  }

  L1 <- NA_real_; L2 <- NA_real_

  # Prioritize by +sqrt (a1,a2) if not, use -sqr (b1,b2)
  if (valid_pair(u1, u2, plus = TRUE)) {
    L1 <- u1; L2 <- u2
  } else if (valid_pair(u3, u4, plus = FALSE)) {
    L1 <- u3; L2 <- u4
  } else {
    # Fallback if a branch yields a plausible ordered pair
    if (is.finite(u1) && is.finite(u2) && u1 > 0 && u2 > 0 && u1 <= u2) { L1 <- u1; L2 <- u2 }
    else if (is.finite(u3) && is.finite(u4) && u3 > 0 && u4 > 0 && u3 <= u4) { L1 <- u3; L2 <- u4 }
  }

  if (!is.finite(L1) || !is.finite(L2)) {
    warning("No valid roots could be determined for the Gart - Nam IC of LR+.")
  }

  list(LinfGNLRp = L1, LsupGNLRp = L2)
}
