library(UsingR)
library(leaflet)
library(geosphere)

shinyServer(  
    function(input, output) {    
        # Read in the park to park distance data
        distances <- read.csv('data/distances.csv', row.names = 1, check.names = FALSE, stringsAsFactors = FALSE)
        parks_data <- read.csv('data/parks.csv', check.names = FALSE, stringsAsFactors = FALSE)
        parks_data$Name <- gsub('(\\s)','_',parks_data$Name)
        
        reac <- reactiveValues()
        
        reac$distances <- reactive({
            usr_distances = distHaversine(c(input$usr_long,input$usr_lat),parks_data[c('long','lat')])
            distances = cbind('user'=usr_distances, distances)
            distances = rbind(distances,'user'=c(0,usr_distances))
            distances
        })
        
        
        
        test_trip <-reactive({ 
            numTest = input$park_count
            trip_parks = reac$distances()[order(reac$distances()["user"]),]["user"]
            #trip_parks = distances[order(distances["Lassen_Volcanic"]),]["Lassen_Volcanic"]
            #names(trip_parks[1:numTest])
            rownames(trip_parks)[1:numTest]
        })
    
        
        nn <- function(trip, start) {
            trip = trip[!trip == start]
            closest = reac$distances()[start,trip][which.min(reac$distances()[start,trip])]
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
        
        #output$testOut <- renderText(as.character(reac$distances()))
        reac$parks_data <- reactive({
            usr_data = c('user','',0,'','','', input$usr_lat, input$usr_long)
            rbind(parks_data, usr_data)
        })
        
        trip_locs <- reactive({
            curr_trip = plan_trip(test_trip(), input$trip_start)
            reac$parks_data()[reac$parks_data()$Name %in% curr_trip,]
        })
        
        
        output$testOut <-renderDataTable(as.data.frame(trip_locs()))
        
        output$mymap <- renderLeaflet({
            leaflet(data = trip_locs()) %>%
                addTiles() %>%
                addMarkers(~long, ~lat, popup = ~Name)
        })
    }      
)