library(tidyverse)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinycssloaders)
library(lubridate)
library(ggridges)

theme_set(theme_minimal())

data <- read_csv("data.csv")
data$Date <- parse_date_time(data$Date, "%m/%d/%y %H:%M%p") %>% as_date()
data <- data %>% mutate(`Decision` = if_else(Acceptances == "Accept" | `Overall Acceptance` == "Accept", "Accept", "Reject", "Reject"))
data$`Journal Name` <- gsub("Philosophers’ Imprint", "Philosophers' Imprint", data$`Journal Name`)

kosher_dates <- data %>%
  group_by(Date) %>%
  summarize(n = n()) %>% 
  filter(year(Date) != 2009 | n < 10) %>%
  .$Date

journal_names <- data %>%
  group_by(`Journal Name`) %>%
  summarize(n = n()) %>%
  arrange(desc(n)) %>%
  .$`Journal Name`

g10_journal_names <- c("Philosophical Review", "Nous", "Journal of Philosophy", "Mind", "Philosophy and Phenomenological Research", 
                       "Australasian Journal of Philosophy", "Philosophical Studies", "Philosophers' Imprint", "Philosophical Quarterly", "Analysis")

max_months <- data$`Review Time in Months` %>% max(na.rm = TRUE) %>% round(0)
min_date <- data$Date %>% min(na.rm = TRUE)
max_date <- data$Date %>% max(na.rm = TRUE)