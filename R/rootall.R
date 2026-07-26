#' @title rootall
#' @description Function to locate multiple roots using a grid and uniroot.
#' @param f Function to be evaluated.
#' @param interval Vector with lower and upper limits.
#' @param lower Lower limit.
#' @param upper Upper limit.
#' @param tol Tolerance.
#' @param maxiter Maximum iterations.
#' @param n Number of nodes in the grid.
#' @param ... Additional arguments for f.
#' @description It is an auxiliary function used to calculate Gart-Nam Confidence Interval
#' for Likelihood Ratios (LR+ and LR-). It finds all roots of a function within a specified
#' interval using a grid-based approach and the uniroot method.
#'
rootall <- function(f, interval,
                    lower, upper,
                    tol = .Machine$double.eps^0.2,
                    maxiter = 20,
                    n = 1000,
                    ...) {
  #-------------------------------
  # Validations
  #-------------------------------
  if (!is.function(f)) stop("'f' must be a function.")
  # Resolve interval/lower/upper safely
  if (!missing(interval)) {
    if (length(interval) != 2L) stop("'interval' must have a length of 2.")
    lower <- min(interval)
    upper <- max(interval)
  } else {
    if (missing(lower) || missing(upper)) {
      stop("You must provide 'interval' or both: 'lower' and 'upper'.")
    }
  }
  if (!is.numeric(lower) || !is.numeric(upper) || !is.finite(lower) || !is.finite(upper))
    stop("'lower' y 'upper' must be finite numbers.")
  if (lower >= upper) stop("'lower' < 'upper' It is not fulfilled.")

  if (!is.numeric(tol) || length(tol) != 1L || !is.finite(tol) || tol <= 0)
    stop("'tol' must be a positive and finite numerical scalar.")
  if (!is.numeric(maxiter) || length(maxiter) != 1L || maxiter <= 0)
    stop("'maxiter' must be a positive integer.")
  if (!is.numeric(n) || length(n) != 1L || n < 1)
    stop("'n' must be a integer >= 1.")
  n <- as.integer(n)
  maxiter <- as.integer(maxiter)

  # Internal tolerances
  zero_tol <- sqrt(.Machine$double.eps)     # to detect "almost zeros"
  dup_tol  <- max(tol, .Machine$double.eps) # to deduplicate roots

  #-------------------------------
  # Assessment grid
  #-------------------------------
  xseq <- seq.int(lower, upper, length.out = n + 1L)

  # Evaluation of f(x): if it is not vectorized, fallback is certain
  mod <- tryCatch(f(xseq, ...), error = function(e) NA_real_)
  if (!is.numeric(mod) || length(mod) != length(xseq)) {
    mod <- vapply(xseq, function(xx) {
      val <- tryCatch(f(xx, ...), error = function(e) NA_real_)
      if (length(val) != 1L) val <- NA_real_
      val
    }, numeric(1))
  }

  # Clean copy for tests (without non-finite)
  mod_clean <- mod
  mod_clean[!is.finite(mod_clean)] <- NA_real_

  #-------------------------------
  # Special case: almost no function across the entire grid
  #-------------------------------
  if (all(is.finite(mod_clean))) {
    if (all(abs(mod_clean) <= zero_tol)) {
      warning("f(x) approx 0 in entire grid; the endpoints of the interval are returned.")
      return(c(lower, upper))
    }
  }

  #-------------------------------
  # Exact zeros (with tolerance))
  #-------------------------------
  zero_idx <- which(is.finite(mod) & abs(mod) <= zero_tol)

  roots_from_zeros <- numeric(0)
  if (length(zero_idx)) {
    roots_from_zeros <- vapply(zero_idx, function(i) {
      lo_i <- if (i > 1L) xseq[i - 1L] else NA_real_
      hi_i <- if (i < length(xseq)) xseq[i + 1L] else NA_real_

      # Only refine if both sides are available and finite in f
      if (is.finite(lo_i) && is.finite(hi_i)) {
        # Avoid attempting if non-finite extrema in f
        f_lo <- mod_clean[i - 1L]
        f_hi <- mod_clean[i + 1L]
        if (is.finite(f_lo) && is.finite(f_hi)) {
          # uniroot requires a sign change. If there isn't one, we'll try anyway.
          # a small numerical broadening by evaluating f() directly.
          out <- tryCatch(
            stats::uniroot(f, lower = lo_i, upper = hi_i, tol = tol, maxiter = maxiter, ...)$root,
            error = function(e) NA_real_
          )
          return(out)
        }
      }
      # If refinement was not possible, we return the node as an approximation.
      xseq[i]
    }, numeric(1))
  }

  #-------------------------------
  # Intervals with sign change (standard bracketing)
  #-------------------------------
  idx_valid <- which(is.finite(mod_clean[1:n]) & is.finite(mod_clean[2:(n + 1L)]))
  sign_prod <- mod_clean[idx_valid] * mod_clean[idx_valid + 1L]
  ii <- idx_valid[which(sign_prod < 0)]   # guaranteed sign cuts

  roots_from_brackets <- numeric(0)
  if (length(ii)) {
    roots_from_brackets <- vapply(ii, function(i) {
      lo <- xseq[i]; hi <- xseq[i + 1L]
      # Avoid attempting uniroot if the evals are not finite.
      if (!is.finite(mod_clean[i]) || !is.finite(mod_clean[i + 1L]))
        return(NA_real_)
      tryCatch(
        stats::uniroot(f, lower = lo, upper = hi, tol = tol, maxiter = maxiter, ...)$root,
        error = function(e) NA_real_
      )
    }, numeric(1))
  }

  #-------------------------------
  # Cleanup and deduplication
  #-------------------------------
  Equi <- c(roots_from_zeros, roots_from_brackets)
  Equi <- Equi[is.finite(Equi)]
  if (!length(Equi)) return(numeric(0))

  Equi <- sort(unique(Equi))  # first unique exact
  # Deduplication by relative/absolute tolerance
  if (length(Equi) > 1L) {
    keep <- c(TRUE, diff(Equi) > dup_tol * (1 + abs(Equi[-length(Equi)])))
    Equi <- Equi[keep]
  }

  # Assured to be in [lower, upper]
  Equi[Equi < lower] <- lower
  Equi[Equi > upper] <- upper

  return(Equi)
}
