## Set up
rm(list = ls())

library(vegan)
library(ellmer)
library(tidyverse)
library(rlang)
library(languageserver)
library(dplyr)
library(ggplot2)
library(readr)
library(httpgd)

## API key
openrouter_api_key <- Sys.getenv("YOURKEY")

## Import data
dat <- read_csv(url("https://raw.githubusercontent.com/cbrown5/example-ecological-data/refs/heads/main/data/benthic-reefs-and-fish/fish-coral-cover-sites.csv"))

## Inspect data
dim(dat)
names(dat)
head(dat)
summary(dat)


############ workshop demonstration ###############

## basic ggplot2 scatter plot
ggplot(dat, aes(x = cb_cover, y = secchi)) +
  geom_point() +
  theme_classic()

## Add linear regression line
ggplot(dat, aes(x = cb_cover, y = secchi)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "orange") +  # Add this line
  theme_classic()

## color by "logged"
ggplot(dat, aes(x = cb_cover, y = secchi, color = logged)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "orange") +  # Add this line
  theme_classic()


################ ShinyApp #################

library(shiny)

## create a shiny app
ui <- fluidPage(
  titlePanel("Interactive Scatter Plot"),
  sidebarLayout(
    sidebarPanel(
      selectInput("xvar", "Select X-axis variable:", choices = names(dat)),
      selectInput("yvar", "Select Y-axis variable:", choices = names(dat), selected = names(dat)[[2]])
    ),
    mainPanel(
      plotOutput("scatterPlot")
    )
  )
)     

## Define server logic
server <- function(input, output) {
  output$scatterPlot <- renderPlot({
    ggplot(dat, aes_string(x = input$xvar, y = input$yvar)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE, color = "pink") +  # Trend line is now pink
      theme_classic()
  })
}

## Run the application
shinyApp(ui = ui, server = server)
