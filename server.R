library(UsingR)
library(leaflet)
data(galton)

shinyServer(  
    function(input, output) {    
        output$newHist <- renderPlot({  
            hist(galton$child, xlab='child height', col='lightblue',main='Histogram')      
            mu <- input$mu      
            lines(c(mu, mu), c(0, 200),col="red",lwd=5)      
            mse <- mean((galton$child - mu)^2)      
            text(63, 150, paste("mu = ", mu))      
            text(63, 140, paste("MSE = ", round(mse, 2)))   })
        # Read in the park to park distance data
        distances <- read.csv('data/distances.csv', row.names = 1, check.names = FALSE)
        parks_data <- read.csv('data/parks.csv', check.names = FALSE, stringsAsFactors = FALSE)
        parks_data$Name <- gsub('(\\s)','_',parks_data$Name)

        
        
         
        test_trip <-reactive({ 
            numTest = input$park_count
            names(distances[1:numTest])
        })
    
        
        nn <- function(trip, start) {
            trip = trip[!trip == start]
            closest = distances[start,trip][which.min(distances[start,trip])]
            remaining = trip[!trip==names(closest)]
            list(closest= names(closest), remaining = remaining)
        }
       
        plan_trip <- function(trip, start){ 
            parks_remain = trip
            ordered_trip = c(start)
            for(x in 1:(length(trip)-2)){
                added = nn(parks_remain, ordered_trip[length(ordered_trip)])
                parks_remain = unlist(added['remaining'],use.names = FALSE)
                ordered_trip = c(ordered_trip, as.character(added['closest']))
            }
            if(length(parks_remain) == 1){
                ordered_trip = c(ordered_trip, parks_remain)
            }else{
                print('Something wrong')
            }
            ordered_trip
        }
        
        #output$testOut <- renderText(plan_trip(test_trip, input$trip_start))
        
        trip_locs <- reactive({
            curr_trip = plan_trip(test_trip(), input$trip_start)
            parks_data[parks_data$Name %in% curr_trip,]
        })
        
        
        output$testOut <-renderDataTable(as.data.frame(trip_locs()))
        

        
        output$mymap <- renderLeaflet({
            leaflet(data = trip_locs()) %>%
                addTiles() %>%
                addMarkers(~long, ~lat)
        })
    }      
)