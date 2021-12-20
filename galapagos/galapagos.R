library(dplyr)
library(rvest)
library(glue)

ids <- c(0, 108, 72, 49, 9, 95, 29, 14, 20, 53, 13, 58, 99, 45, 5, 54, 55, 68, 27, 33, 56, 44, 11, 34, 46, 41, 28, 57, 67, 42, 30, 23, 35, 12, 1, 21, 25, 8, 77, 90, 59, 43, 6, 37, 17, 39, 75, 100, 101, 4, 52, 78, 94, 24, 31, 2, 102, 22, 7, 69, 36, 48, 61, 15)
url <- "https://www.darwinfoundation.org/en/datazone/checklist?option=com_ajax&module=checklist&name=&checklist={id}&iucn=0&origin=0&format=raw"

taxa <- c()

for (id in ids) {
  message(id)
  checklist_url <- glue(url)
  html <- read_html(checklist_url)
  res <- html %>% html_elements("em") %>% html_text()
  taxa <- c(taxa, res)  
}

write.table(taxa, file = "galapagos.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)
