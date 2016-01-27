library(leaflet)

shinyUI(fluidPage(  
    headerPanel("Plan Your National Parks Trip!"),  
    fluidRow(
            column(4,
                   tabsetPanel(
                        tabPanel("Input",
                            br(),
                            wellPanel(
                                textInput('usr_location',
                                       'Where do you want to start your trip?',
                                       value = '101 Forest Ave., Palo Alto, CA'),
                                actionButton('set_start', 'Set Start',
                                             icon("map-marker")),
                                br(),
                                br(),
                                numericInput('park_count', 'Number of Parks',
                                            10, min = 2, max = 59)
                            )
                        ),
                        tabPanel("Documentation",
                            br(),
                            wellPanel(
                                p('Just enter the address or city where you
                                  would like to start your trip and the number 
                                  of parks you want to vist. Then click 
                                  "Set Start".'),
                                
                                p('It will then show you the closest National 
                                  Parks to your start location, plot the order 
                                  to visit them with a nearest neighbor 
                                  algorithm, and show information about 
                                  the parks.')
                            )
                        ),
                        tabPanel("Notes",
                             br(),
                             wellPanel(
                                 p('This currently plans your trip order based 
                                    on the nearest location that you have not
                                    vissited yet. This can lead to inefficient 
                                    routes.'),
                                   
                                 p('This uses straight distance currently, not
                                   driving distance.')
                             )
                        )
                )
            ),
            column(8,
                leafletOutput('mymap')
            )
        ),
        fluidRow(
            column(12,
                dataTableOutput('parksTable')
            )
        )
        
    )
)