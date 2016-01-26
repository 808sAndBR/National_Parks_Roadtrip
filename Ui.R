library(leaflet)
#shinyUI(pageWithSidebar(  
shinyUI(fluidPage(  
    headerPanel("Plan Your National Parks Trip!"),  
#    sidebarLayout(
fluidRow(
#        sidebarPanel(
        column(4,
               wellPanel(
                    textInput('usr_location', 'Where do you want to start your trip?', value = '101 Forest Ave., Palo Alto, CA'),
                    actionButton('set_start', 'Set Start', icon("refresh")),
                    #numericInput('usr_lat', 'My Lat', 37.767019, min = -90, max = 90),
                    #numericInput('usr_long', 'My Long', -122.421781, min = -180, max = 180),
                    br(),
                    br(),
                    numericInput('park_count', '# of Parks', 10, min = 3, max = 60)
               )
            ),
    
        #mainPanel(
        column(8,
            #textOutput("testOut"),
            leafletOutput("mymap")
        )
    ),
    fluidRow(
        column(12,
        dataTableOutput('testOut')
        #tableOutput('testOut')
    ))
    
))