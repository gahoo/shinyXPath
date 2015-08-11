# load packages
library(RCurl)
library(XML)

# download html
url<-"https://ju.taobao.com/tg/brand_items.htm?act_sign_id=8115264"
url<-"https://ju.taobao.com/tg/brand.htm?spm=608.5847457.102202.4.pllQyM"
url<-"http://cos.name/cn/topic/17816/"
html <- getURL(url,.encoding='gbk')
html<-iconv(html, 'gbk', to='utf-8')
txt <- readLines(con=textConnection(html),encoding='gbk') 
html <- readLines("test.html", encoding='utf-8')

# parse html
doc = htmlParse(html, asText=TRUE)
title <- xpathSApply(doc, "//footer", xmlValue)
title <- xpathSApply(doc, "//div[@class='item-status']/h3", xmlGetAttr, name='title')
text <- xpathSApply(doc, "//div[@class='item-status']//span[@class='blanktxt']", xmlValue)
num <- xpathSApply(doc, "//div[@class='item-status']//span[@class='blanktxt']/em[@class='J_soldnum']", xmlValue)

title <- xpathSApply(doc, "//div[@class='status-blank']//h3", xmlGetAttr, name='title')
text <- xpathSApply(doc, "//div[@class='status-blank']//div[@class='sold-num']", xmlValue)
num <- xpathSApply(doc, "//div[@class='status-blank']//div[@class='sold-num']/em[@class='J_soldnum']", xmlValue)

kk<-data.frame(title=title, text=text, num=num)
write.table(kk,'test.txt')
