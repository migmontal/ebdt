library(shiny)
library(bslib)
library(bsicons)
library(shinydashboard)
library(tidyverse)
library(highcharter)
library(shinyWidgets)
library(DT)
library(shinyalert)
library(ebdt)

HAS_READXL <- requireNamespace("readxl", quietly = TRUE)

METRICS_ALL <- list(
  "Sensibility (Se)" = "ebdt_se",
  "Specificity (Sp)" = "ebdt_sp",
  "Positive Predictive Value (PPV)" = "ebdt_ppv",
  "Negative Predictive Value (NPV)" = "ebdt_npv",
  "Positive Likelihood Ratio (PLR)" = "ebdt_plr",
  "Negative Likelihood Ratio (NLR)" = "ebdt_nlr",
  "Youden Index (You)" = "ebdt_you",
  "Prevalence (Prev)" = "ebdt_prev",
  "Weighted Kappa (Kap)" = "ebdt_kap"
)

METRICS_RETRO <- METRICS_ALL[c(
  "Sensibility (Se)", "Specificity (Sp)", "Positive Likelihood Ratio (PLR)",
  "Negative Likelihood Ratio (NLR)", "Youden Index (You)"
)]

# Tema personalizado moderno (Recomendación 1)
custom_theme <- bs_theme(
  version = 5,
  preset = "flatly",
  primary = "#0D6EFD",
  secondary = "#6C757D",
  success = "#198754",
  info = "#0DCAF0",
  warning = "#FFC107",
  danger = "#DC3545",
  font_scale = 1.0
)

ui <- page_navbar(
  title = "Evaluating Binary Diagnostic Tests - EBDT",
  id = "navbar",
  theme = custom_theme,
  window_title = "EBDT - Diagnostic Test Evaluation",
  
  # Página de información (Recomendación 6)
  nav_panel(
    "Info",
    icon = bs_icon("info-circle"),
    
    layout_column_wrap(
      width = "100%",
      
      card(
        full_screen = TRUE,
        card_header(
          strong(bs_icon("book"), " About EBDT"),
          class = "bg-primary text-white"
        ),
        p(
          "The ",
          tags$code("ebdt"),
          " Shiny app evaluates the quality of a binary diagnostic test under complete verification.
           It computes point estimates and confidence intervals for sensitivity, specificity, Youden index,
           positive and negative predictive values, positive and negative likelihood ratios, weighted kappa coefficient,
           and disease prevalence for both cross-sectional and retrospective study designs using the ",
          tags$code("ebdt"),
          " library."
        )
      )
    ),
    
    layout_column_wrap(
      width = "100%",
      col_widths = c(6, 6),
      
      # Tarjeta de autores
      card(
        card_header(
          strong(bs_icon("people"), " Authors"),
          class = "bg-info text-white"
        ),
        tags$div(
          style = "margin: 15px 0;",
          tags$p(
            tags$b("Miguel Ángel Montero-Alonso"),
            tags$a(
              tags$i("ORCID"),
              href = "https://orcid.org/0000-0002-1214-9035",
              target = "_blank",
              class = "ms-2 badge bg-secondary"
            )
          ),
          tags$p(
            tags$b("Juan de Dios Luna del Castillo"),
            tags$a(
              tags$i("ORCID"),
              href = "https://orcid.org/0000-0002-1854-4968",
              target = "_blank",
              class = "ms-2 badge bg-secondary"
            )
          ),
          tags$p(
            tags$a(
              "Department of Statistics and Operational Research",
              href = "https://estadistica.ugr.es",
              target = "_blank",
              class = "d-block"
            ),
            tags$a(
              "University of Granada",
              href = "https://www.ugr.es/",
              target = "_blank",
              class = "d-block"
            )
          )
        )
      ),
      
      # Tarjeta de versión
      card(
        card_header(
          strong(bs_icon("code-square"), " Technical Info"),
          class = "bg-success text-white"
        ),
        tags$div(
          style = "margin: 15px 0;",
          tags$p(
            tags$b("Package: "),
            tags$code("ebdt"), " v",
            packageVersion("ebdt")
          ),
          tags$p(
            tags$b("Built with: "),
            "R, Shiny, bslib"
          ),
          tags$p(
            tags$b("Last updated: "),
            "2024"
          )
        )
      )
    ),
    
    # Acordeón de referencias
    layout_column_wrap(
      width = "100%",
      accordion(
        accordion_panel(
          title = strong(bs_icon("bookmark"), " Key References"),
          tags$div(
            style = "font-size: 0.95em; line-height: 1.6;",
            tags$ul(
              tags$li("Agresti, A. (2002). Categorical Data Analysis. John Wiley and Sons, New York."),
              tags$li("Agresti, A., Coull, B.A. (1998). Approximate is better than 'exact' for interval estimation of binomial proportions. The American Statistician, 52:119–126."),
              tags$li("Gart, J.J., Nam J. (1988). Approximate interval estimation of the ratio of binomial parameters: a review and corrections for skewness. Biometrics, 44: 323–338."),
              tags$li("Montero-Alonso, M.Á. (2010). Intervalos de confianza y contrastes de hipótesis para parámetros de tests diagnósticos binarios, Doctoral Thesis."),
              tags$li("Simel D.L., Samsa, G.P., Matchar, D.B. (1991). Likelihood ratios with confidence: sample size estimation for diagnostic test studies. J. Clin Epidemiology, 44(8): 763-770."),
              tags$li("Roldán Nofuentes J.A., Luna del Castillo J.D., Montero Alonso, M.A. (2009). Confidence intervals of weighted kappa coefficient of a binary diagnostic test. Communications in Statistics. Simulation and Computation, 38: 1562–1578."),
              tags$li("Pepe, M. S. (2003). The statistical evaluation of medical tests for classification and prediction. Oxford University Press."),
              tags$li("Zhou, X.-H., Obuchowski, N. A., McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2.ª ed.). John Wiley & Sons.")
            )
          )
        )
      )
    )
  ),
  
  # Página de cálculo principal (Recomendación 2, 5, 7)
  nav_panel(
    "Calculate",
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Input Parameters",
        open = "desktop",
        
        # Sección 1: Datos de entrada
        card(
          card_header(
            strong(bs_icon("table"), " Contingency Table Data"),
            class = "bg-primary text-white"
          ),
          
          fileInput(
            "excel_file",
            "Upload Excel file (.xlsx)",
            accept = c(".xlsx", ".xls"),
            class = "form-control"
          ),
          
          tags$small(
            "Or enter data manually:",
            class = "text-muted d-block mb-3"
          ),
          
          numericInput(
            "s1",
            label = tags$span(
              "True Positive (TP)",
              tags$i(
                class = "bi bi-question-circle-fill",
                title = "Number of diseased individuals correctly identified by the test"
              )
            ),
            value = 40
          ),
          
          numericInput(
            "r1",
            label = tags$span(
              "False Positive (FP)",
              tags$i(
                class = "bi bi-question-circle-fill",
                title = "Number of healthy individuals incorrectly identified as diseased"
              )
            ),
            value = 5
          ),
          
          numericInput(
            "s0",
            label = tags$span(
              "False Negative (FN)",
              tags$i(
                class = "bi bi-question-circle-fill",
                title = "Number of diseased individuals missed by the test"
              )
            ),
            value = 10
          ),
          
          numericInput(
            "r0",
            label = tags$span(
              "True Negative (TN)",
              tags$i(
                class = "bi bi-question-circle-fill",
                title = "Number of healthy individuals correctly identified as healthy"
              )
            ),
            value = 45
          ),
          
          # Validación en tiempo real (Recomendación 5)
          tags$div(
            id = "validation_message",
            style = "margin-top: 10px;"
          )
        ),
        
        br(),
        
        # Sección 2: Opciones de análisis
        card(
          card_header(
            strong(bs_icon("gear"), " Analysis Options"),
            class = "bg-info text-white"
          ),
          
          selectInput(
            "target1",
            label = tags$span(
              "Study Type",
              bslib::tooltip(
                bs_icon("question-circle"),
                "Select the type of study design used for data collection"
              )
            ),
            choices = c("Cross-sectional", "Retrospective")
          ),
          
          selectInput(
            "target2",
            label = tags$span(
              "Parameters to Calculate",
              bslib::tooltip(
                bs_icon("question-circle"),
                "Choose which metrics to compute. Available metrics depend on study type."
              )
            ),
            choices = c("All", names(METRICS_ALL))
          )
        ),
        
        br(),
        
        # Sección 3: Exportar resultados
        card(
          card_header(
            strong(bs_icon("download"), " Export Options"),
            class = "bg-success text-white"
          ),
          
          checkboxInput(
            "export_check",
            "Export results to TXT?",
            value = FALSE
          ),
          
          conditionalPanel(
            condition = "input.export_check == true",
            br(),
            downloadButton(
              "downloadData",
              label = "Download result.txt",
              class = "btn-success w-100",
              icon = icon("download")
            )
          )
        ),
        
        br(),
        
        # Botón de cálculo
        actionButton(
          "run",
          label = tags$span(bs_icon("calculator"), " Calculate"),
          class = "btn-primary w-100",
          size = "lg"
        )
      ),
      
      # Panel principal
      navset_card_tab(
        title = "Results",
        
        # Pestaña 1: Tabla de contingencia
        nav_panel(
          "Contingency Table",
          icon = bs_icon("grid-1x2"),
          
          card(
            full_screen = TRUE,
            card_header(strong("2x2 Contingency Table")),
            
            tags$div(
              style = "overflow-x: auto;",
              DTOutput("contingency_table_dt")
            )
          )
        ),
        
        # Pestaña 2: Resultados
        nav_panel(
          "Results",
          icon = bs_icon("bar-chart"),
          
          card(
            full_screen = TRUE,
            card_header(strong("Analysis Results")),
            
            tags$div(
              style = "background-color: #f8f9fa; padding: 15px; border-radius: 5px; 
                       font-family: 'Courier New', monospace; font-size: 0.9em; 
                       max-height: 600px; overflow-y: auto; line-height: 1.6;",
              verbatimTextOutput("consola")
            )
          )
        ),
        
        # Pestaña 3: Historial (Recomendación 9)
        nav_panel(
          "History",
          icon = bs_icon("clock-history"),
          
          card(
            full_screen = TRUE,
            card_header(strong("Calculation History")),
            
            tags$div(
              id = "history_info",
              style = "padding: 20px; text-align: center; color: #6C757D;",
              p("Calculations will appear here. You can compare previous results.")
            ),
            
            tags$div(
              style = "overflow-x: auto;",
              DTOutput("history_table")
            ),
            
            tags$div(
              style = "margin-top: 15px;",
              actionButton(
                "clear_history",
                label = "Clear History",
                class = "btn-warning btn-sm",
                icon = icon("trash")
              )
            )
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Almacenar historial de cálculos (Recomendación 9)
  history_data <- reactiveVal(data.frame(
    Timestamp = character(),
    StudyType = character(),
    TP = numeric(),
    FP = numeric(),
    FN = numeric(),
    TN = numeric(),
    Parameters = character(),
    stringsAsFactors = FALSE
  ))
  
  # Actualizar opciones de parámetros según tipo de estudio
  observeEvent(input$target1, {
    choices <- if (input$target1 == "Retrospective") {
      c("All", names(METRICS_RETRO))
    } else {
      c("All", names(METRICS_ALL))
    }
    updateSelectInput(session, "target2", choices = choices)
  })
  
  # Validación en tiempo real (Recomendación 5)
  observe({
    s1 <- input$s1
    r1 <- input$r1
    s0 <- input$s0
    r0 <- input$r0
    
    validation_html <- ""
    
    if (is.na(s1) || is.na(r1) || is.na(s0) || is.na(r0)) {
      validation_html <- tags$div(
        class = "alert alert-warning",
        icon("exclamation-triangle"),
        " Please fill all fields"
      )
    } else if (s1 < 0 || r1 < 0 || s0 < 0 || r0 < 0) {
      validation_html <- tags$div(
        class = "alert alert-danger",
        icon("times-circle"),
        " All values must be non-negative"
      )
    } else {
      total_diseased <- s1 + s0
      total_healthy <- r1 + r0
      total <- total_diseased + total_healthy
      
      validation_html <- tags$div(
        class = "alert alert-info",
        icon("check-circle"),
        tags$strong(" Data Summary: "),
        sprintf("Total: %d | Diseased: %d | Healthy: %d", total, total_diseased, total_healthy)
      )
    }
    
    output$validation_message <- renderUI({
      validation_html
    })
  })
  
  # Helper: read 2x2 table from file (Excel or CSV)
  read_2x2_from_file <- function(path) {
    ext <- tolower(tools::file_ext(path))
    if (ext %in% c("xlsx", "xls")) {
      if (!HAS_READXL) stop("Package 'readxl' is not installed. Install it or use a CSV file.")
      raw <- readxl::read_excel(path, col_names = FALSE)
    } else {
      raw <- utils::read.csv(path, header = FALSE, stringsAsFactors = FALSE)
    }
    nr <- nrow(raw); nc <- ncol(raw)
    if (nr < 2 || nc < 2) stop(sprintf("Need 2x2 table, found %d row(s) x %d col(s).", nr, nc))
    
    cells <- as.numeric(raw[1, 1]); if (is.na(cells)) stop(sprintf("Cell [1,1] is not numeric: '%s'", raw[1, 1]))
    cells[2] <- as.numeric(raw[1, 2]); if (is.na(cells[2])) stop(sprintf("Cell [1,2] is not numeric: '%s'", raw[1, 2]))
    cells[3] <- as.numeric(raw[2, 1]); if (is.na(cells[3])) stop(sprintf("Cell [2,1] is not numeric: '%s'", raw[2, 1]))
    cells[4] <- as.numeric(raw[2, 2]); if (is.na(cells[4])) stop(sprintf("Cell [2,2] is not numeric: '%s'", raw[2, 2]))
    vals <- as.integer(round(cells))
    if (any(vals < 0)) stop("All cell values must be non-negative.")
    list(s1 = vals[1], r1 = vals[2], s0 = vals[3], r0 = vals[4])
  }
  
  # Auto-populate from file (Excel or CSV)
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
  
  # Centralized computing
  resultados_calculados <- eventReactive(input$run, {
    a <- input$s1; b <- input$r1; c <- input$s0; d <- input$r0
    is_cross <- (input$target1 == "Cross-sectional")
    
    txt <- capture.output({
      if (input$target2 == "All") {
        ebdt(s1 = a, r1 = b, s0 = c, r0 = d, study = is_cross)
      } else {
        func_name <- METRICS_ALL[[input$target2]]
        do.call(func_name, list(s1 = a, r1 = b, s0 = c, r0 = d))
      }
    })
    
    paste(txt, collapse = "\n")
  })
  
  output$consola <- renderPrint({
    cat(resultados_calculados())
  })
  
  # Mostrar tabla de contingencia con DT (Recomendación 3)
  output$contingency_table_dt <- renderDT({
    data <- matrix(
      c(input$s1, input$r1, input$s0, input$r0),
      nrow = 2,
      byrow = TRUE,
      dimnames = list(
        c("Test Positive", "Test Negative"),
        c("Disease Present", "Disease Absent")
      )
    )
    
    datatable(
      data,
      options = list(
        dom = 't',
        paging = FALSE,
        searching = FALSE,
        ordering = FALSE,
        info = FALSE,
        columnDefs = list(
          list(className = "dt-center", targets = "_all")
        )
      ),
      rownames = TRUE
    ) %>%
      formatStyle(columns = 0:2, backgroundColor = "#E3F2FD", fontWeight = "bold") %>%
      formatStyle(rows = 1, backgroundColor = "#FFF9C4")
  }, server = FALSE)
  
  # Agregar a historial cuando se calcula (Recomendación 9)
  observeEvent(input$run, {
    current_history <- history_data()
    
    new_row <- data.frame(
      Timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      StudyType = input$target1,
      TP = input$s1,
      FP = input$r1,
      FN = input$s0,
      TN = input$r0,
      Parameters = input$target2,
      stringsAsFactors = FALSE
    )
    
    updated_history <- rbind(new_row, current_history)
    
    # Mantener solo los últimos 50 registros
    if (nrow(updated_history) > 50) {
      updated_history <- updated_history[1:50, ]
    }
    
    history_data(updated_history)
  })
  
  # Mostrar historial (Recomendación 9)
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
          pageLength = 10,
          lengthMenu = c(10, 25, 50),
          dom = 'ltp',
          columnDefs = list(
            list(className = "dt-center", targets = "_all")
          )
        ),
        rownames = FALSE
      ) %>%
        formatStyle(columns = 0:(ncol(hist)-1), fontSize = "90%")
    }
  }, server = FALSE)
  
  # Limpiar historial (Recomendación 9)
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
      Timestamp = character(),
      StudyType = character(),
      TP = numeric(),
      FP = numeric(),
      FN = numeric(),
      TN = numeric(),
      Parameters = character(),
      stringsAsFactors = FALSE
    ))
    removeModal()
    showNotification("History cleared.", type = "message", duration = 3)
  })
  
  # DOWNLOAD TXT
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("EBDT_result_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
    },
    content = function(file) {
      res <- resultados_calculados()
      header <- sprintf(
        "EBDT - Binary Diagnostic Test Evaluation Report\n%s\n\nStudy Type: %s\nParameters: %s\n\n%s\n",
        format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        input$target1,
        input$target2,
        "="
      )
      writeLines(paste0(header, res), file)
    }
  )
}

shinyApp(ui, server)
