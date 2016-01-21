library(leaflet)
#shinyUI(pageWithSidebar(  
shinyUI(fluidPage(  
    headerPanel("Plan Your National Parks Trip!"),  
    sidebarLayout(
        sidebarPanel(    
            textInput('trip_start', 'Trip Start', value = 'user'),
            #need to look up real max and min
            numericInput('usr_lat', 'My Lat', 37.767019, min = -90, max = 90),
            numericInput('usr_long', 'My Long', -122.421781, min = -140, max = 140),
            numericInput('park_count', '# of Parks', 10, min = 3, max = 60)
            ),
    
        mainPanel(    
            #textOutput("testOut"),
            leafletOutput("mymap")
        )
    ),
    dataTableOutput('testOut')
))