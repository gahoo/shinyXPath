library(shiny)
library(XML)
library(RCurl)
library(shinyAce)

xmlFunc<-list('xmlGetAttr'=xmlGetAttr, 'xmlValue'=xmlValue)

shinyServer(function(input, output, session) {
  
  output$html_input<-renderUI({
    if(input$htmlSource == 'url'){
      textInput('url', 'url', value='https://ju.taobao.com/tg/brand_items.htm?act_sign_id=8115264')
    }else{
      fileInput('html_file', 'html', multiple = F)
    }
  })
  
  htmlContent <- eventReactive(input$load, {
    withProgress(message = 'Loading Pages',
                 detail= 'Please wait', value=0,
                 {
                   if(input$htmlSource == 'url'){
                     incProgress(1/3, detail = 'From URL')
                     html<-getURL(input$url, .encoding=input$encoding)
                   }else{
                     incProgress(1/3, detail = 'From File Upload')
                     html<-try(readLines(input$html_file$datapath, encoding=input$encoding))
                     html<-paste0(html, collapse = '\n')
                   }
                   updateAceEditor(session, 'html_codes', value=html, mode="html", theme='textmate')
                 })
    html
  })
  
  doc <- reactive({
    htmlParse(input$html_codes, asText=TRUE, encoding=input$encoding)
  })
  
  xpath <- reactiveValues(data = NULL)
  
  observeEvent(input$add, {
    xpath$data[[input$name]] <- xPathContent()
  })
  
  observeEvent(input$remove, {
    xpath$data[[input$name]] <- NULL
  })
  
  xPathContent <- reactive({
    if(input$type == 'xmlValue'){
      xpathSApply(doc(), input$xpath, xmlFunc[[input$type]])
    }else{
      xpathSApply(doc(), input$xpath, xmlFunc[[input$type]], name=input$name)
    }
  })
  
  output$preview <- renderText({
    head(xPathContent())
  })
  
  output$debug<-renderText({
    #str(input$url)
    #xpath$data[[input$name]]
    substr(htmlContent(),1,0)
  })
  
  output$table<-DT::renderDataTable({
    dt<-as.data.frame(xpath$data)
    dt
  })
  
  output$downloadTable <- downloadHandler(
    filename = 'table.txt',
    content = function(file) {
      dt<-as.data.frame(xpath$data)
      fileEncode<-ifelse(input$sameEncodingOnSave, input$encoding, '')
      eol<-ifelse(input$isWindows, '\r\n', '\n')
      write.table(dt, file, sep='\t', eol=eol, quote=F, row.names=F, fileEncoding=fileEncode)
    }
  )
  
})

