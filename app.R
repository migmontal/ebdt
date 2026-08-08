# Install ebdt from GitHub if not available (for shinyapps.io deployment)
if (!require("ebdt", quietly = TRUE)) {
  tryCatch({
    if (!require("remotes", quietly = TRUE)) {
      install.packages("remotes", repos = "https://cloud.r-project.org")
    }
    remotes::install_github("migmontal/ebdt", quiet = TRUE, upgrade = "never")
    library(ebdt)
  }, error = function(e) {
    stop("Failed to install ebdt package: ", conditionMessage(e))
  })
}

library(shiny)
library(bslib)
library(bsicons)
library(DT)
library(shinyalert)

# Metrics mapping
METRICS_ALL <- list(
  "Sensitivity (Se)"               = "ebdt_se",
  "Specificity (Sp)"               = "ebdt_sp",
  "Positive Predictive Value (PPV)" = "ebdt_ppv",
  "Negative Predictive Value (NPV)" = "ebdt_npv",
  "Positive Likelihood Ratio (PLR)" = "ebdt_plr",
  "Negative Likelihood Ratio (NLR)" = "ebdt_nlr",
  "Youden Index (You)"              = "ebdt_you",
  "Prevalence (Prev)"              = "ebdt_prev",
  "Weighted Kappa (Kap)"           = "ebdt_kap"
)

METRICS_RETRO <- METRICS_ALL[c(
  "Sensitivity (Se)", "Specificity (Sp)", "Positive Likelihood Ratio (PLR)",
  "Negative Likelihood Ratio (NLR)", "Youden Index (You)"
)]

# Theme setup
custom_theme <- bs_theme(
  version = 5,
  preset = "flatly",
  primary = "#0D6EFD",
  secondary = "#6C757D",
  success = "#198754",
  info = "#0DCAF0",
  warning = "#FFC107",
  danger = "#DC3545"
)

ui <- page_navbar(
  title = "Evaluating Binary Diagnostic Tests - EBDT",
  theme = custom_theme,
  window_title = "EBDT - Binary Diagnostic Test Evaluation",

  tags$head(
    tags$style(HTML("
      .nav-tabs .nav-link.active {
        background-color: #DC3545 !important;
        border-color: #DC3545 !important;
        color: white !important;
      }
      .nav-tabs .nav-link {
        color: #333 !important;
      }
      .nav-tabs .nav-link:hover {
        border-color: #DC3545 !important;
      }
      .navbar-nav .nav-link {
        color: #A8E6B2 !important;
      }
      .navbar-nav .nav-link.active {
        color: white !important;
        background-color: #0D6EFD !important;
        border-radius: 0.375rem;
      }
    "))
  ),

  nav_panel(
    "Info",
    icon = bs_icon("info-circle"),
    full_screen = TRUE,

    div(
      style = "background-color: #E3F6F5; padding: 15px; border-radius: 5px; margin-bottom: 10px;",
      card_header(strong(bs_icon("book"), " About EBDT"))
    ),
    div(
      style = "background-color: #f0f0f0; padding: 15px; border-radius: 5px; margin-bottom: 10px;",
      p(tags$code("ebdt"), " Shiny app evaluates the quality of a binary diagnostic test under complete verification.
         It computes point estimates and confidence intervals for sensitivity, specificity, Youden index,
         positive and negative predictive values, positive and negative likelihood ratios, weighted kappa coefficient,
         and disease prevalence for both cross-sectional and retrospective study designs using the ",
        tags$code("ebdt"), " library."
      )
    ),

    div(
      style = "background-color: #E3F6F5; padding: 15px; border-radius: 5px; margin-bottom: 10px;",
      card_header(strong(bs_icon("people"), " Authors"))
    ),
    div(
      style = "background-color: #f0f0f0; padding: 15px; border-radius: 5px; margin-bottom: 10px;",
      tags$p(tags$b("Miguel Ángel Montero-Alonso "),
             tags$a("ORCID", href = "https://orcid.org/0000-0002-1214-9035", target = "_blank")),
      tags$p(tags$b("Juan de Dios Luna del Castillo "),
             tags$a("ORCID", href = "https://orcid.org/0000-0002-1854-4968", target = "_blank")),
      tags$p(
        tags$a("Department of Statistics and Operational Research", href = "https://estadistica.ugr.es", target = "_blank"),
        tags$br(),
        tags$a("University of Granada", href = "https://www.ugr.es/", target = "_blank")
      )
    ),

    div(
      style = "background-color: #E3F6F5; padding: 15px; border-radius: 5px; margin-bottom: 10px;",
      card_header(strong(bs_icon("bookmark"), " References"))
    ),
    div(
      style = "background-color: #f0f0f0; padding: 15px; border-radius: 5px; margin-bottom: 10px;",
      tags$ul(
        style = "font-size: 0.95em; line-height: 1.6;",
        tags$li("Agresti, A. (2002). Categorical Data Analysis. John Wiley and Sons, New York."),
        tags$li("Agresti, A., Coull, B.A. (1998). Approximate is better than 'exact' for interval estimation of binomial proportions. The American Statistician, 52:119–126."),
        tags$li("Gart, J.J., Nam J. (1988). Approximate interval estimation of the ratio of binomial parameters: a review and corrections for skewness. Biometrics, 44: 323–338."),
        tags$li("Montero-Alonso, M.Á. (2010). Intervalos de confianza y contrastes de hipótesis para parámetros de tests diagnósticos binarios, Doctoral Thesis."),
        tags$li("Simel D.L., Samsa, G.P., Matchar, D.B. (1991). Likelihood ratios with confidence: sample size estimation for diagnostic test studies. J. Clin Epidemiology, 44(8): 763-770."),
        tags$li("Roldán Nofuentes J.A., Luna del Castillo J.D., Montero-Alonso, M.Á. (2009). Confidence intervals of weighted kappa coefficient of a binary diagnostic test. Communications in Statistics. Simulation and Computation, 38: 1562–1578."),
        tags$li("Pepe, M. S. (2003). The statistical evaluation of medical tests for classification and prediction. Oxford University Press."),
        tags$li("Zhou, X.-H., Obuchowski, N. A., McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.")
      )
    )
  ),

  nav_panel(
    "Calculate",
    layout_sidebar(
      sidebar = sidebar(
        title = "Input Parameters",
        open = "desktop",

        card(
          card_header(strong(bs_icon("table"), " Contingency Table Data")),

          fileInput(
            "excel_file",
            "Upload Excel file (.xlsx)",
            accept = c(".xlsx", ".xls", ".csv")
          ),

          tags$small("Or enter data manually:", class = "d-block mb-3"),

          numericInput("s1", "True Positive (TP):", value = 40, min = 0),
          numericInput("r1", "False Positive (FP):", value = 5, min = 0),
          numericInput("s0", "False Negative (FN):", value = 10, min = 0),
          numericInput("r0", "True Negative (TN):", value = 45, min = 0),

          numericInput("conflev", "Confidence level:", value = 0.95, min = 0.50, max = 0.999, step = 0.01),
          numericInput("digits", "Number of decimals:", value = 3, min = 0, max = 10, step = 1),

          uiOutput("validation_message")
        ),

        br(),

        tags$div(
          style = "margin-bottom: 1rem;",
          tags$div(
            style = "background-color: #f8f9fa; padding: 1rem; border-radius: 0.375rem; border: 1px solid #dee2e6;",
            tags$div(
              style = "background-color: #0DCAF0; color: white; padding: 0.5rem 0.75rem; border-radius: 0.25rem 0.25rem 0 0; margin: -1rem -1rem 1rem -1rem; font-weight: bold;",
              bs_icon("gear"), " Analysis Options"
            ),
            selectInput("target1", "Study Type:", choices = c("Cross-sectional", "Retrospective")),
            selectInput("target2", "Parameters to Calculate:", choices = c("All", names(METRICS_ALL)))
          )
        ),

        br(),

        card(
          card_header(strong(bs_icon("download"), " Export Options")),
          checkboxInput("export_check", "Export results to TXT?", value = FALSE),
          conditionalPanel(
            condition = "input.export_check == true",
            br(),
            downloadButton("downloadData", "Download result.txt", class = "btn-success w-100")
          )
        ),

        br(),

        actionButton("run", label = "Calculate", class = "btn-primary w-100", size = "lg")
      ),

      navset_card_tab(
        nav_panel(
          "Contingency Table",
          icon = bs_icon("grid-1x2"),
          card(
            full_screen = TRUE,
            card_header(strong("2x2 Contingency Table")),
            DTOutput("contingency_table_dt")
          )
        ),

        nav_panel(
          "Results",
          icon = bs_icon("bar-chart"),
          card(
            full_screen = TRUE,
            card_header(strong("Analysis Results")),
            tags$div(
              style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; font-family: 'Courier New', monospace; font-size: 0.9em; max-height: 600px; overflow-y: auto; line-height: 1.6;",
              verbatimTextOutput("consola")
            )
          )
        ),

        nav_panel(
          "History",
          icon = bs_icon("clock-history"),
          card(
            full_screen = TRUE,
            card_header(strong("Calculation History")),
            DTOutput("history_table"),
            br(),
            actionButton("clear_history", "Clear History", class = "btn-warning btn-sm")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Corrected structure matching all 9 columns
  history_data <- reactiveVal(data.frame(
    Timestamp  = character(),
    StudyType  = character(),
    TP         = numeric(),
    FP         = numeric(),
    FN         = numeric(),
    TN         = numeric(),
    ConfLevel  = numeric(),
    Digits     = numeric(),
    Parameters = character(),
    stringsAsFactors = FALSE
  ))

  observeEvent(input$target1, {
    choices <- if (input$target1 == "Retrospective") {
      c("All", names(METRICS_RETRO))
    } else {
      c("All", names(METRICS_ALL))
    }
    updateSelectInput(session, "target2", choices = choices)
  })

  output$validation_message <- renderUI({
    s1 <- input$s1; r1 <- input$r1; s0 <- input$s0; r0 <- input$r0

    if (is.na(s1) || is.na(r1) || is.na(s0) || is.na(r0)) {
      tags$div(class = "alert alert-warning mt-2", bs_icon("exclamation-triangle"), " Please fill all fields")
    } else if (s1 < 0 || r1 < 0 || s0 < 0 || r0 < 0) {
      tags$div(class = "alert alert-danger mt-2", bs_icon("x-circle"), " All values must be non-negative")
    } else {
      total_diseased <- s1 + s0
      total_healthy  <- r1 + r0
      total          <- total_diseased + total_healthy

      tags$div(
        class = "alert alert-info mt-2",
        bs_icon("check-circle"),
        tags$strong(" Data Summary: "),
        sprintf("Total: %d | Diseased: %d | Healthy: %d", total, total_diseased, total_healthy)
      )
    }
  })

  read_2x2_from_file <- function(path) {
    ext <- tolower(tools::file_ext(path))
    if (ext %in% c("xlsx", "xls")) {
      if (!requireNamespace("readxl", quietly = TRUE)) {
        stop("Package 'readxl' is missing. Install it to read Excel files.")
      }
      raw <- readxl::read_excel(path, col_names = FALSE)
    } else {
      raw <- utils::read.csv(path, header = FALSE, stringsAsFactors = FALSE)
    }

    nr <- nrow(raw); nc <- ncol(raw)
    if (nr != 2 || nc != 2) stop(sprintf("Need 2x2 table, found %d row(s) x %d col(s).", nr, nc))

    cells <- c(
      as.numeric(raw[1, 1][[1]]), as.numeric(raw[1, 2][[1]]),
      as.numeric(raw[2, 1][[1]]), as.numeric(raw[2, 2][[1]])
    )

    if (any(is.na(cells))) stop("Table contains non-numeric cell values.")
    vals <- as.integer(round(cells))
    if (any(vals < 0)) stop("All cell values must be non-negative.")

    list(s1 = vals[1], r1 = vals[2], s0 = vals[3], r0 = vals[4])
  }

  observeEvent(input$excel_file, {
    req(input$excel_file)
    tryCatch({
      vals <- read_2x2_from_file(input$excel_file$datapath)
      updateNumericInput(session, "s1", value = vals$s1)
      updateNumericInput(session, "r1", value = vals$r1)
      updateNumericInput(session, "s0", value = vals$s0)
      updateNumericInput(session, "r0", value = vals$r0)
      showNotification("Table loaded successfully. Click Calculate to run.", type = "message", duration = 5)
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error", duration = 10)
    })
  })

  resultados_calculados <- eventReactive(input$run, {
    req(input$s1, input$r1, input$s0, input$r0, input$conflev, input$digits)

    a <- input$s1; b <- input$r1; c <- input$s0; d <- input$r0
    is_cross <- (input$target1 == "Cross-sectional")

    txt <- capture.output({
      if (input$target2 == "All") {
        ebdt(s1 = a, r1 = b, s0 = c, r0 = d, study = is_cross, conflev = input$conflev, digits = input$digits)
      } else {
        func_name <- METRICS_ALL[[input$target2]]
        do.call(func_name, list(s1 = a, r1 = b, s0 = c, r0 = d, conflev = input$conflev, digits = input$digits))
      }
    })

    paste(txt, collapse = "\n")
  })

  output$consola <- renderPrint({
    cat(resultados_calculados())
  })

  output$contingency_table_dt <- renderDT({
    req(input$s1, input$r1, input$s0, input$r0)

    s1 <- input$s1; r1 <- input$r1; s0 <- input$s0; r0 <- input$r0
    row_totals <- c(s1 + r1, s0 + r0)
    col_totals <- c(s1 + s0, r1 + r0)
    grand_total <- s1 + r1 + s0 + r0

    final_data <- rbind(
      c(s1, r1, row_totals[1]),
      c(s0, r0, row_totals[2]),
      c(col_totals[1], col_totals[2], grand_total)
    )

    colnames(final_data) <- c("Disease +", "Disease -", "Total")
    rownames(final_data) <- c("Test +", "Test -", "Total")

    datatable(
      final_data,
      options = list(
        dom = 't', paging = FALSE, searching = FALSE, ordering = FALSE, info = FALSE,
        columnDefs = list(list(className = "dt-center", targets = "_all"))
      ),
      rownames = TRUE
    ) %>%
      formatStyle(columns = seq_len(ncol(final_data)), backgroundColor = "#E3F2FD", fontWeight = "bold")
  }, server = FALSE)

  observeEvent(input$run, {
    req(input$s1, input$r1, input$s0, input$r0)
    current_history <- history_data()

    new_row <- data.frame(
      Timestamp  = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      StudyType  = input$target1,
      TP         = input$s1,
      FP         = input$r1,
      FN         = input$s0,
      TN         = input$r0,
      ConfLevel  = input$conflev,
      Digits     = input$digits,
      Parameters = input$target2,
      stringsAsFactors = FALSE
    )

    updated_history <- rbind(new_row, current_history)
    if (nrow(updated_history) > 50) updated_history <- updated_history[1:50, ]

    history_data(updated_history)
  })

  output$history_table <- renderDT({
    hist <- history_data()

    if (nrow(hist) == 0) {
      datatable(
        data.frame("No calculations yet" = ""),
        options = list(dom = 't', paging = FALSE, ordering = FALSE, info = FALSE)
      )
    } else {
      datatable(
        hist,
        options = list(
          pageLength = 10, lengthMenu = c(10, 25, 50), dom = 'ltp',
          columnDefs = list(list(className = "dt-center", targets = "_all"))
        ),
        rownames = FALSE
      ) %>%
        formatStyle(columns = seq_len(ncol(hist)), fontSize = "90%")
    }
  }, server = FALSE)

  observeEvent(input$clear_history, {
    showModal(modalDialog(
      title = "Clear History",
      "Are you sure you want to clear all calculation history?",
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_clear", "Yes, Clear", class = "btn-danger")
      )
    ))
  })

  observeEvent(input$confirm_clear, {
    history_data(data.frame(
      Timestamp  = character(),
      StudyType  = character(),
      TP         = numeric(),
      FP         = numeric(),
      FN         = numeric(),
      TN         = numeric(),
      ConfLevel  = numeric(),
      Digits     = numeric(),
      Parameters = character(),
      stringsAsFactors = FALSE
    ))
    removeModal()
    showNotification("History cleared.", type = "message", duration = 3)
  })

  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("EBDT_result_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
    },
    content = function(file) {
      res <- resultados_calculados()
      header <- sprintf(
        "EBDT - Binary Diagnostic Test Evaluation Report\nTimestamp: %s\nStudy Type: %s\nParameters: %s\nConfidence level: %s\nDecimals: %d\n========================================\n\n",
        format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        input$target1,
        input$target2,
        input$conflev,
        input$digits
      )
      writeLines(paste0(header, res), file)
    }
  )
}

shinyApp(ui, server)
