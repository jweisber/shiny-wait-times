function(input, output) {
  
  # Shared Stuff ----
  selected_journals_d <- reactive(input$selected_journals) %>% debounce(1200)
  n_journals_d <- reactive(length(input$selected_journals)) %>% debounce(1200)
  
  selected_data <- reactive({
    data <- data %>% filter(!is.na(Date), !is.na(`Review Time in Months`))
    
    kosher_dates <- kosher_dates[kosher_dates >= as.Date(input$dateRange[1]) & kosher_dates <= as.Date(input$dateRange[2])]
    data <- data %>% filter(Date %in% kosher_dates)
    
    data$`Review Time in Months`[data$`Review Time in Months` > input$maxMonths] <- input$maxMonths
    
    data <- data %>% filter(`Journal Name` %in% selected_journals_d())
    
    if (input$decisionFilter == "Accepted Papers Only") {
      data <- data %>% filter(Decision == "Accept")
    } else if (input$decisionFilter == "Rejected Papers Only") {
      data <- data %>% filter(Decision == "Reject")
    }
    
    data$Decision <- factor(data$Decision, levels = c("Reject", "Accept"))
    
    jrnl_levels <- data %>%
      group_by(`Journal Name`) %>%
      summarise(avg_wait = mean(`Review Time in Months`, na.rm = TRUE)) %>%
      arrange(desc(avg_wait)) %>%
      .$`Journal Name`
    
    data$`Journal Name` <- factor(data$`Journal Name`, levels = jrnl_levels)
    
    return(data)
  })
  
  # ScatterPlot ----
  
  scatter_box_width_d <- reactive(input$scatterBoxWidth) %>% debounce(500)  
  n_columns_d <- reactive(input$scatterBoxWidth %/% 250) %>% debounce(500)
  
  scatterplot_height <- function() {
    if (n_journals_d() == 1) {
      return(scatter_box_width_d() / 1.5)
    } else {
      return((n_journals_d() / n_columns_d() + 1) * 200)
    }
  }
  
  output$scatterBox <- renderUI({
    box(
      title = "", status = "primary", solidHeader = FALSE, width = 12, height = scatterplot_height() + 70,
      plotOutput("scatterPlot") %>% withSpinner()
    )
  })
  
  output$scatterPlot <- renderPlot({
    
    p <- ggplot(selected_data(), aes(Date, `Review Time in Months`)) +
      ylim(0, NA) +
      facet_wrap(~ `Journal Name`, ncol = n_columns_d()) + 
      xlab(NULL) +
      theme(legend.position = "bottom", legend.title = element_blank())
    
    if (input$decisionFilter == "Include All") {
      p <- p + geom_point(aes(colour = `Decision`))
    } else if (input$decisionFilter == "Accepted Papers Only") {
      p <- p +  geom_point(colour = "#00bfc4")
    } else {
      p <- p +  geom_point(colour = "#f8766d")
    }
    
    if (input$fitCurve) {
      p + geom_smooth(method = "auto")
    } else {
      p
    }
  }, height = scatterplot_height)
  
  # RidgePlot ----
  
  ridgeplot_height <- function() {
    return(400 + n_journals_d() * 25)
  }
  
  output$ridgeBox <- renderUI({
    box(
      title = "", status = "primary", solidHeader = FALSE, width = 12, height = ridgeplot_height() + 70,
      plotOutput("ridgePlot") %>% withSpinner()
    )
  })
  
  output$ridgePlot <- renderPlot({
    p <- ggplot(selected_data(), aes(x = `Review Time in Months`, y = `Journal Name`, fill = `Journal Name`)) +
      scale_x_continuous(limits = c(0, input$maxMonths + .5)) +
      xlab("Months") + ylab("") + 
      theme(plot.title = element_text(hjust = 0.5), 
            axis.title.x = element_text(hjust = 0.5),
            axis.text.y = element_text(size = rel(1.25), vjust = 0),
            legend.position = "none")
    
    if (input$ridgeRawData) {
      p + geom_density_ridges(scale = 2, jittered_points = TRUE)
    } else {
      p + geom_density_ridges(scale = 2)
    }
  }, height = ridgeplot_height)
}

