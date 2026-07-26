
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' Calculate the point estimate and confidence intervals of the quality measures
#' of a binary diagnostic test.
#'
#' @title Calculate all parameters of a binary diagnostic test in a traverse or
#'        Cross-sectional study.
#'
#' @param s1 Non-negative numeric. TP - True positive  (cases correctly classified as +).
#' @param r1 Non-negative numeric. FP - False positives (controls classified as +).
#' @param s0 Non-negative numeric. FN - False negatives (cases classified as -).
#' @param r0 Non-negative numeric. TN - True negatives (controls classified as -).
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#' @param study Logical. If TRUE in a traverse or Cross-sectional study,
#'        FALSE in a Case Control or Retrospective study. Default TRUE.
#' @param print_table Logical. If TRUE, print 2x2 table. Default TRUE.
#' @param quiet Logical. If TRUE, it reduces non-critical messages
#'        (maintains important warnings). Default is FALSE.
#'
#' @returns No return value; prints formatted results to the console. List with:
#'         Sensitivity, Specificity, Youden_Index, Prevalence, PPV, NPV, PLR,
#'         NLR, Weighted_Kappa and their Confidence intervals.
#' @export
#' @description
#' This function calculate Sensitivity, Specificity, positive and negative predictive
#' value, positive and negative Likelihood Ratio, Weighted Kappa coeficient,
#' Youden Index, prevalence and their Confidence intervals in a traverse or
#' Cross-sectional study, and Sensitivity, Specificity, Youden Index,
#' positive and negative Likelihood Ratio in a Case Control or Retrospective study.
#'
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
#' @examples ebdt(40, 5, 10, 45, conflev = 0.95, digits = 4)
#'
ebdt <- function(s1, r1, s0, r0, conflev = 0.95, digits = 3, study = TRUE,
                 print_table = TRUE, quiet = FALSE) {
  start_time <- Sys.time()

  # ---- Input validation ----
  vals <- c(s1, r1, s0, r0)
  if (any(!is.numeric(vals)) || any(!is.finite(vals)) ||
      any(lengths(list(s1, r1, s0, r0)) != 1L)) {
    stop("s1, r1, s0, r0 must be finite numeric scalars (length 1).")
  }
  if (any(vals < 0)) stop("The values cannot be negative.")

  if (!is.numeric(conflev) || length(conflev) != 1L || conflev <= 0 || conflev >= 1) {
    stop("conflev must be within the interval (0, 1).")
  }

  if (!is.numeric(digits) || length(digits) != 1L || digits < 0) {
    stop("digits must be a single non-negative integer.")
  }
  digits <- as.integer(digits)

  if (!is.logical(study) || length(study) != 1L) {
    stop("study must be a single logical (TRUE/FALSE).")
  }
  if (!is.logical(print_table) || length(print_table) != 1L) {
    stop("print_table must be a single logical (TRUE/FALSE).")
  }
  if (!is.logical(quiet) || length(quiet) != 1L) {
    stop("quiet must be a single logical (TRUE/FALSE).")
  }

  ss <- s1 + s0
  rr <- r1 + r0
  if (ss <= 0) stop("s1 + s0 must be > 0.")
  if (rr <= 0) stop("r1 + r0 must be > 0.")

  # ---- 2x2 Table (optional) ----
  if (isTRUE(print_table)) {
    tb1 <- as.table(
      rbind(c(s1, r1, s1+r1), c(s0, r0, s0+r0), c(s1+s0, r1+r0, s1+r1+r0+s0)))
    dimnames(tb1) <- list(Test = c("Test +", "Test -", "Total"),
                          Outcome = c("Outcome +", "Outcome -", "Total"))
    if (!quiet) {
      cat("Matrix of data is:\n\n")
      print(tb1)
      cat("\n")
    }
  }

  # ---- HHelper: safe to invoke subfunctions if they exist ----
  safe_call <- function(fun_name, ...) {
    if (exists(fun_name, mode = "function")) {
      fn <- get(fun_name, mode = "function")
      out <- tryCatch(fn(...),
                      error = function(e) {
                        warning(sprintf("Error in %s(): %s", fun_name, conditionMessage(e)))
                        return(NA)
                      })
      return(out)
    } else {
      warning(sprintf("Function '%s' is not available in the environment. NA is returned.", fun_name))
      return(NA)
    }
  }

  # ---- Output ----

  cat("\n")
  cat("--------------------------------------\n")
  cat(" EVALUATING OF BINARY DIAGNOSTIC TEST \n")
  cat("--------------------------------------\n")
  cat("\n")

  # ---- Calls to all functions ----

  if (isTRUE(study)) {
    cat("       -----------------------\n")
    cat("        Cross-sectional study \n")
    cat("       -----------------------\n")
    results <- list(
      Sensitivity      = safe_call("ebdt_se", s1, r1, s0, r0, conflev, digits = digits),
      Specificity      = safe_call("ebdt_sp", s1, r1, s0, r0, conflev, digits = digits),
      Youden_Index     = safe_call("ebdt_you", s1, r1, s0, r0, conflev, digits = digits),
      Prevalence       = safe_call("ebdt_prev", s1, r1, s0, r0, conflev, digits = digits),
      PPV              = safe_call("ebdt_ppv", s1, r1, s0, r0, conflev, digits = digits),
      NPV              = safe_call("ebdt_npv", s1, r1, s0, r0, conflev, digits = digits),
      PLR              = safe_call("ebdt_plr", s1, r1, s0, r0, conflev, digits = digits),
      NLR              = safe_call("ebdt_nlr", s1, r1, s0, r0, conflev, digits = digits),
      Weighted_Kappa   = safe_call("ebdt_kap", s1, r1, s0, r0, conflev, digits = digits),
      Execution_Time   = Sys.time() - start_time
    )
  } else {
    cat("---------------------\n")
    cat(" Retrospective study \n")
    cat("---------------------\n")
    results <- list(
      Sensitivity      = safe_call("ebdt_se", s1, r1, s0, r0, conflev, digits = digits),
      Specificity      = safe_call("ebdt_sp", s1, r1, s0, r0, conflev, digits = digits),
      Youden_Index     = safe_call("ebdt_you", s1, r1, s0, r0, conflev, digits = digits),
      PLR              = safe_call("ebdt_plr", s1, r1, s0, r0, conflev, digits = digits),
      NLR              = safe_call("ebdt_nlr", s1, r1, s0, r0, conflev, digits = digits),
      Execution_Time   = Sys.time() - start_time
    )
  }

  # ---- Execution time ----
  exec_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  if (!quiet) {
    cat("\nExecution time:", format(round(exec_time, digits), nsmall = digits), "seconds\n")
  }

  invisible(results)
}
