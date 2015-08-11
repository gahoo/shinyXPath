library(shiny)
library(XML)
library(RCurl)

xmlFunc<-list('xmlGetAttr'=xmlGetAttr, 'xmlValue'=xmlValue)

shinyServer(function(input, output) {
  
  output$html_input<-renderUI({
    if(input$htmlSource == 'url'){
      textInput('url', 'url', value='https://ju.taobao.com/tg/brand_items.htm?act_sign_id=8115264')
    }else{
      fileInput('html_file', 'html')
    }
  })
  
  htmlContent <- eventReactive(input$load, {
    if(input$htmlSource == 'url'){
      getURL(input$url)
    }else{
      readLines(input$html_file$datapath)
    }
  })
  
  doc <- reactive({
    htmlParse(htmlContent(), asText=TRUE)
  })
  
  xpath <- reactiveValues(data = NULL)
  
  observeEvent(input$add, {
    xpath$data[[input$name]] <- example()
  })
  
  observeEvent(input$remove, {
    xpath$data[[input$name]] <- NULL
  })
  
  example <- reactive({
    if(input$type == 'xmlValue'){
      xpathSApply(doc(), input$xpath, xmlFunc[[input$type]])
    }else{
      xpathSApply(doc(), input$xpath, xmlFunc[[input$type]], name=input$name)
    }
  })
  
  output$example <- renderText({
    head(example())
  })
  
  output$debug<-renderText({
    str(input$url)
    xpath$data[[input$name]]
    substr(htmlContent(), 1,100)
  })
  
  output$table<-DT::renderDataTable({
    dt<-as.data.frame(xpath$data)
    datatable(dt,extensions = 'TableTools', options = list(
      dom = 'T<"clear">lfrtip',
      tableTools = list(sSwfPath = copySWF())
    ))
  })
  
  output$downloadTable <- downloadHandler(
    filename = 'table.txt',
    content = function(file) {
      dt<-as.data.frame(xpath$data)
      write.table(dt, file, sep='\t', quote=F, row.names=F)
    }
  )
  
})

