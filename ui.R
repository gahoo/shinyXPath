library(shiny)
library(DT)

shinyUI(bootstrapPage(
  conditionalPanel('input.load == 0',
                   selectInput('htmlSource', 'Source',
                               choice = c('url', 'upload'),
                               selected = 'url'),
                   selectInput('encoding', 'encoding',
                               choice = c('gbk', 'utf-8'),
                               selected = 'utf-8'),
                   uiOutput('html_input'),
                   actionButton('load', 'Load page')
                   ),
  
  #textOutput('debug'),
  textInput('name', 'name', value='title'),
  textInput('xpath', 'xpath', value="//div[@class='item-status']/h3"),
  selectInput('type', 'value type', 
              choice = c('xmlGetAttr', 'xmlValue'),
              selected='xmlValue'),
  actionButton('add', 'add to table'),
  actionButton('remove', 'remove from table'),
  wellPanel(textOutput('example')),
  DT::dataTableOutput('table'),
  downloadButton('downloadTable', 'Download')
  
))

