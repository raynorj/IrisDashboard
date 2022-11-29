library(shiny)
library(shinydashboard)
library(DBI)

#data = read.csv("iris.csv", stringsAsFactors = TRUE)
drv <- RPostgres::Postgres()
db <-dbConnect(
  drv,
  host = "localhost",
  port = 55432,
  dbname = "postgres",
  user = "",
  password = ""
)
testquery = dbGetQuery(db, "SELECT variety FROM varieties")

ui <- dashboardPage(
  dashboardHeader(title = "Iris Display"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Averages Boxplot", tabName = "mean"),
      menuItem("X-Y Scatterplot", tabName = "scatterplot")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "mean",
        fluidRow(
          box(plotOutput("plotMean", height = 250)),
          
          box(title = "Data selection", 
              radioButtons("radioMean", 
                           NULL,
                           c("Sepal Length" = "sepal_length", 
                             "Sepal Width" = "sepal_width",
                             "Petal Length" = "petal_length",
                             "Petal Width" = "petal_width")
                          )
              )
        )
      ),
    
      tabItem(tabName = "scatterplot",
        fluidRow(
                box(plotOutput("plotXY", height = 250)),
                
                box(title = NULL, 
                    radioButtons("radioX", 
                                 "Variable X",
                                 c("Sepal Length" = "sepal_length", 
                                   "Sepal Width" = "sepal_width",
                                   "Petal Length" = "petal_length",
                                   "Petal Width" = "petal_width")
                    ),
                    radioButtons("radioY", 
                                 "Variable Y",
                                 c("Sepal Length" = "sepal_length", 
                                   "Sepal Width" = "sepal_width",
                                   "Petal Length" = "petal_length",
                                   "Petal Width" = "petal_width")
                    )
                )
        )
      )
    )
  )
)

server <- function(input, output) {
  #TODO: adjust layout (averages plot is especially weird in fullscreen)
  #TODO: setup cloud server
    #buy droplet
    #harden droplet (update, configure login, firewall?)
    #install R, R packages, Shiny Server, and PostgreSQL
    #upload and run Shiny script + data
  #TODO: setup redirect
  cat(testquery[1,"variety"])
  
  output$plotMean <- renderPlot({
    data = dbGetQuery(db, paste0("SELECT ", input$radioMean[1], ", variety FROM observations JOIN varieties ON (observations.v_id=varieties.id)"))
    boxplot(data[,input$radioMean[1]]~variety, data=data)
  })
  
  #TODO: change to ggplot?
  #TODO: apply variable names to axes?
  output$plotXY <- renderPlot({
    data = dbGetQuery(db, paste0("SELECT ", input$radioX[1], ", ", input$radioY[1], ", variety FROM observations JOIN varieties ON (observations.v_id=varieties.id)"))
    data[,"variety"] = as.factor(data[,"variety"])
    plot(data[,input$radioX[1]], data[,input$radioY[1]], col=data[,"variety"], xlab=input$radioX[1], ylab=input$radioY[1])
  })
}

shinyApp(ui = ui, 
         server = server,
         onStart = function() {
           onStop(function() {
             dbDisconnect(db)
             dbUnloadDriver(drv)
           })
         }
)