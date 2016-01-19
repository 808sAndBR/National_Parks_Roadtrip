library(leaflet)
shinyUI(pageWithSidebar(  
    headerPanel("Example plot"),  
    sidebarPanel(    
        #sliderInput('mu', 'Guess at the mu',value = 70, min = 60, max = 80, step = 0.05,),  
        textInput('trip_start', 'Trip Start', value = 'Acadia'),
        numericInput('park_count', '# of Parks', 10, min = 3, max = 20)
        ),
    mainPanel(    
       # plotOutput('newHist'),
        leafletOutput("mymap"),
        dataTableOutput('testOut')
    )
))