# ebdt_from_excel

Evaluating of Binary Diagnostic Test (EBDT)

## Usage

``` r
ebdt_from_excel(file, sheet = 1, study = TRUE, conflev = 0.95, digits = 3, ...)
```

## Arguments

- file:

  Path to the .xlsx or .xls file.

- sheet:

  Sheet name or index. Default 1.

- study:

  Logical. TRUE for cross-sectional/prospective, FALSE for
  retrospective. Default TRUE.

- conflev:

  Confidence level (0,1). Default 0.95.

- digits:

  Integer. Number of decimal places. Default 3.

- ...:

  Additional arguments passed to \[ebdt()\].

## Value

The result list from \[ebdt()\].

## Details

Read Excel file and run full diagnostic test analysis

Reads a 2x2 contingency table from an Excel file and evaluates all
binary diagnostic test quality parameters via \[ebdt()\].

The Excel file must contain a 2x2 contingency table in the top-left
corner (first 2 rows, first 2 columns):

“\` \[TP\] \[FP\] \[FN\] \[TN\] “\`

Row 1, Col 1 = TP (Test+/Outcome+) Row 1, Col 2 = FP (Test+/Outcome-)
Row 2, Col 1 = FN (Test-/Outcome+) Row 2, Col 2 = TN (Test-/Outcome-)

The file is read without column names via \[readxl::read_excel()\], so
any headers are treated as data. If the sheet has more than 2 rows or 2
columns, only the first 2x2 block is used (with a warning).

## References

Montero-Alonso, M.A. (2010). Intervalos de confianza y contrastes de
hipotesis para parametros de tests diagnosticos binarios,
http://hdl.handle.net/10481/4879

## Examples

``` r
if (FALSE) { # \dontrun{
ebdt_from_excel("datos_prueba.xlsx")
ebdt_from_excel("datos_prueba.xlsx", study = FALSE, conflev = 0.99)
} # }
```
