library(shiny)
library(XML)
library(RCurl)
library(shinyAce)

xmlFunc<-list('xmlGetAttr'=xmlGetAttr, 'xmlValue'=xmlValue)

shinyServer(function(input, output, session) {
  
  output$html_input<-renderUI({
    if(input$htmlSource == 'url'){
      list(aceEditor("url", mode='text', value="https://ju.taobao.com/tg/brand_items.htm?act_sign_id=8115264", height="100px"),
           textInput('wait', 'wait interval', value=0))
    }else{
      fileInput('html_file', 'html', multiple = T)
    }
  })
  
  htmlContent <- eventReactive(input$load, {
    
    getHtmlFromURLs<-function(wait=0){
      urls<-unlist(strsplit(input$url, split='\n'))
      n<-length(urls)
      step_size<-1/n
      html<-lapply(urls, function(url){
        incProgress(step_size, detail = paste0('From URL ', url))
        Sys.sleep(wait)
        getURL(url, .encoding=input$encoding, ssl.verifypeer=F)
      })
      do.call('paste0', html)
    }
    
    getHtmlFromUploads<-function(){
      n<-nrow(input$html_file)
      step_size<-1/n
      
      html<-lapply(input$html_file$datapath, function(filepath){
        incProgress(step_size, detail = paste0('From File ', filepath))
        content<-try(readLines(filepath,
                      encoding=input$encoding))
        paste0(content, collapse = '\n')
      })
      do.call('paste0', html)  
      
    }
    
    withProgress(message = 'Loading Pages',
                 detail= 'Please wait', value=0,
                 {
                   if(input$htmlSource == 'url'){
                     html<-getHtmlFromURLs(wait=input$wait)
                   }else{
                     html<-getHtmlFromUploads()
                   }
                   updateAceEditor(session, 'html_codes', value=html, mode="html", theme='textmate')
                 })
    html
  })
  
  doc <- reactive({
    htmlParse(input$html_codes, asText=TRUE, encoding=input$encoding)
  })
  
  xpath <- reactiveValues(data = list())
  
  observeEvent(input$add, {
    xpath$data[[input$name]] <- xPathContent()
  })
  
  observeEvent(input$remove, {
    xpath$data[[input$name]] <- NULL
  })
  
  observeEvent(input$clear, {
    xpath$data <- list()
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

