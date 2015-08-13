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
                             choice = c('unknown', 'gb2312', 'gbk', 'big5', 'utf-8'),
                             selected = 'unknown'),
                 uiOutput('html_input'),
                 textInput('wait', 'wait interval', value=0),
                 actionButton('load', 'Load page'),
                 textOutput('debug')
                 ),
        tabPanel('XPath',
                 a("What's XPath",href='http://www.w3school.com.cn/xpath/xpath_syntax.asp'),
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
                 aceEditor("html_codes", mode='html', value="", height="700px")
                 ),
        tabPanel('Table',
                 wellPanel(textOutput('preview')),
                 checkboxInput('sameEncodingOnSave', 'same Encoding with source', F),
                 checkboxInput('isWindows', 'windows end of line', T),
                 downloadButton('downloadTable', 'Download'),
                 DT::dataTableOutput('table')
                 )
        )
      )
  )
  
))

