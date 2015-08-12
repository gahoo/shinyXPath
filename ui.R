library(shiny)
library(shinyAce)
library(DT)

shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel('Source',
                 radioButtons('htmlSource', 'Source',
                              choice = c('url', 'upload'),
                              selected = 'url'),
                 selectInput('encoding', 'encoding',
                             choice = c('unknown','gbk', 'utf-8'),
                             selected = 'unknown'),
                 uiOutput('html_input'),
                 actionButton('load', 'Load page'),
                 textOutput('debug')
                 ),
        tabPanel('XPath',
                 textInput('name', 'name', value='title'),
                 textInput('xpath', 'xpath', value="//div[@class='item-status']/h3"),
                 selectInput('type', 'value type', 
                             choice = c('xmlGetAttr', 'xmlValue'),
                             selected='xmlValue'),
                 actionButton('add', 'add to table'),
                 actionButton('remove', 'remove from table')
                 )
        )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel('HTML',
                 aceEditor("ace", value="", height="700px")
                 ),
        tabPanel('Table',
                 wellPanel(textOutput('preview')),
                 downloadButton('downloadTable', 'Download'),
                 DT::dataTableOutput('table')
                 )
        )
      )
  )
  
))

