dashboardPage(
  
  dashboardHeader(title = "Waiting for the Editor"),
  
  dashboardSidebar(
    
    tags$head(
      tags$script(src = "width.js"),
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
    sliderInput(inputId = "maxMonths", label = "Review Time Cap (Months)", 1, max_months, 18),
    
    sliderInput(inputId = "dateRange", label = "Date Range", ticks = FALSE, min = min_date, max = max_date,
                value = c(as.Date("2009-01-01"), as.Date("2017-01-01")), timeFormat = "%b %Y"),
    
    selectInput(inputId = "decisionFilter", label = "Decisions", choices = c("Include All", "Accepted Papers Only", "Rejected Papers Only")),
    
    checkboxGroupInput("selected_journals", "Journals", journal_names, selected = g10_journal_names)
  ),
  
  dashboardBody(
    tabsetPanel(type = "tabs", selected = "Scatterplot",
                tabPanel("About", icon = icon("info-circle"),
                  box(title = "", status = "primary", solidHeader = FALSE, width = 12,
                      includeHTML("www/about.html")
                  )
                ),
                
                tabPanel("Scatterplot", icon = icon("braille"),
                         uiOutput("scatterBox"),
                         box(title = "Fitted Curve", status = "warning", solidHeader = FALSE, align = "center",
                             switchInput(inputId = "fitCurve", label = NULL, value = TRUE)
                         )
                ),
                
                tabPanel("Ridgeplot", icon = icon("image"),
                         uiOutput("ridgeBox"),
                         box(title = "Show Raw Data", status = "warning", solidHeader = FALSE, align = "center",
                             switchInput(inputId = "ridgeRawData", label = NULL, value = FALSE)
                         )
                )
                
    ),
    
    includeHTML("www/statcounter.html")
  )
)