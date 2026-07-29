
#' Evaluating of Binary Diagnostic Test (EBDT)
#'
#' Read Excel file and run full diagnostic test analysis
#'
#' Reads a 2x2 contingency table from an Excel file and evaluates all
#' binary diagnostic test quality parameters via [ebdt()].
#'
#' @title ebdt_from_excel
#'
#' @param file Path to the .xlsx or .xls file.
#' @param sheet Sheet name or index. Default 1.
#' @param study Logical. TRUE for cross-sectional/prospective,
#'   FALSE for retrospective. Default TRUE.
#' @param conflev Confidence level (0,1). Default 0.95.
#' @param digits Integer. Number of decimal places. Default 3.
#' @param ... Additional arguments passed to [ebdt()].
#'
#' @keywords internal
#'
#' @details
#' The Excel file must contain a 2x2 contingency table in the
#' top-left corner (first 2 rows, first 2 columns):
#'
#' ```
#' [TP] [FP]
#' [FN] [TN]
#' ```
#'
#' Row 1, Col 1 = TP (Test+/Outcome+)
#' Row 1, Col 2 = FP (Test+/Outcome-)
#' Row 2, Col 1 = FN (Test-/Outcome+)
#' Row 2, Col 2 = TN (Test-/Outcome-)
#'
#' The file is read without column names via
#' [readxl::read_excel()], so any headers are treated as data.
#' If the sheet has more than 2 rows or 2 columns, only the
#' first 2x2 block is used (with a warning).
#'
#' @returns The result list from [ebdt()].
#'
#' @references Montero-Alonso, M.A. (2010). Intervalos de confianza y contrastes
#'   de hipotesis para parametros de tests diagnosticos binarios,
#'   http://hdl.handle.net/10481/4879
#'
#' @examples
#' \dontrun{
#' ebdt_from_excel("datos_prueba.xlsx")
#' ebdt_from_excel("datos_prueba.xlsx", study = FALSE, conflev = 0.99)
#' }
#'
ebdt_from_excel <- function(file, sheet = 1, study = TRUE, conflev = 0.95,
                            digits = 3, ...) {
  # ---- Input validation ----
  if (!is.character(file) || length(file) != 1L || !nzchar(file)) {
    stop("'file' must be a non-empty character string.")
  }
  if (!file.exists(file)) {
    stop(sprintf("File '%s' does not exist.", file))
  }
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop("Package 'readxl' is required. Install it with install.packages('readxl').")
  }

  # ---- Read Excel ----
  raw <- readxl::read_excel(file, sheet = sheet, col_names = FALSE)

  nr <- nrow(raw)
  nc <- ncol(raw)

  if (nr < 2L || nc < 2L) {
    stop(sprintf(
      "Expected at least a 2x2 table. Found %d row(s) x %d column(s).", nr, nc))
  }

  if (nr > 2L || nc > 2L) {
    warning(sprintf(
      "Sheet has %d rows x %d columns. Only the first 2x2 block will be used.", nr, nc))
  }

  # ---- Extract 2x2 core ----
  m <- as.matrix(raw[1:2, 1:2])

  if (!is.numeric(m)) {
    # Attempt conversion
    m <- suppressWarnings(apply(m, 2, as.numeric))
    if (anyNA(m)) {
      stop("Non-numeric values found in the 2x2 table that cannot be converted.")
    }
  }

  vals <- as.integer(round(m))

  if (any(vals < 0)) {
    stop("All cell values must be non-negative.")
  }

  # Map positions: [1,1]=TP, [1,2]=FP, [2,1]=FN, [2,2]=TN
  s1 <- vals[1, 1]
  r1 <- vals[1, 2]
  s0 <- vals[2, 1]
  r0 <- vals[2, 2]

  # ---- Run analysis ----
  ebdt(s1 = s1, r1 = r1, s0 = s0, r0 = r0, study = study,
       conflev = conflev, digits = digits, ...)
}
