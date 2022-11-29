library(shiny)
library(shinydashboard)
library(DBI)

table1 = read.csv("table1.csv", stringsAsFactors = TRUE)
table2 = read.csv("table2.csv", stringsAsFactors = TRUE)

drv <- RPostgres::Postgres()
db <-dbConnect(
  drv,
  host = "localhost",
  port = 55432,
  dbname = "postgres",
  user = "AAA",
  password = "rawr"
)

dbWriteTable(db, "observations", table1)
dbWriteTable(db, "varieties", table2)

dbDisconnect(db)
dbUnloadDriver(drv)
