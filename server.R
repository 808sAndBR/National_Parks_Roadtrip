library(leaflet)
library(geosphere)
library(ggmap)

shinyServer(  
    function(input, output) {    
        # Read in the park to park distance data created by Data_scraper.R
        distances <- read.csv('data/distances.csv', row.names = 1,
                              check.names = FALSE, stringsAsFactors = FALSE)
        
        # Read in the park information data created by Data_scraper.R
        parks_data <- read.csv('data/parks.csv', check.names = FALSE,
                               stringsAsFactors = FALSE)
        # Make names usable
        parks_data$Name <- gsub('(\\s)','_', parks_data$Name)
        
        # Setup to append reactive values to it
        reac <- reactiveValues()
         
        # API call to geocode user input. Returns data frame.
        reac$usr_location <- eventReactive(input$set_start,{
            reac$usr_loc <- geocode(input$usr_location)
        })
        
        # Finds user distance to all parks and adds them to distances
        reac$distances <- reactive({
            usr_distances = distHaversine(
                            c(reac$usr_location()$lon,
                            reac$usr_location()$lat),
                            parks_data[c('long','lat')])
            distances = cbind('user'=usr_distances, distances)
            distances = rbind(distances,'user'=c(0,usr_distances))
            distances
        })
        
        # Returns the closest parks to the user, amount based on user input.
        closest_parks <-reactive({ 
            trip_parks = reac$distances()[order(reac$distances()["user"]),]["user"]
            rownames(trip_parks)[1:(input$park_count + 1)]
        })
    
        # Return list of the closest location and the trip values not yet used.
        nn <- function(trip, start) {
            trip = trip[!trip == start]
            closest = reac$distances()[start,trip][which.min(reac$distances()[start,trip])]
            remaining = trip[!trip==names(closest)]
            list(closest = names(closest), remaining = remaining)
        }

        # Return locations in order of nearest neightbor 
        # that has not been visited yet.
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

        # Add the start location to parks_data for plotting 
        reac$parks_data <- reactive({
            usr_data = c('user','',0,'','','',
                         reac$usr_location()$lat,
                         reac$usr_location()$lon)
            rbind(parks_data, usr_data)
        })

        # Create data frame of parks on the trip in order
        trip_locs <- reactive({
            curr_trip = plan_trip(closest_parks(), "user")
            trip = data.frame('Order' = 0:(length(curr_trip)-1),
                              'Name' = curr_trip)
            merge(trip, reac$parks_data(), by = 'Name', sort = FALSE)
        })

        output$parksTable <-renderDataTable(
            as.data.frame(trip_locs()) %>%
            subset(Name != 'user', 
                   select = c(Order, Name, Description, state))
            )

        # Create map of the trip
        output$mymap <- renderLeaflet({
            leaflet(data = trip_locs()) %>%
                addTiles() %>%
                addMarkers(~long, ~lat, popup = ~Name) %>%
                # Reactive data breaks auto-centering so fitBounds needs set
                fitBounds(lng1 = max(trip_locs()$long),
                          lat1 = max(trip_locs()$lat),
                          lng2 = min(trip_locs()$long),
                          lat2 = min(trip_locs()$lat)) %>%
                # Plot the route
                addPolylines(lng = as.numeric(trip_locs()$long),
                             lat = as.numeric(trip_locs()$lat),
                             fill = F, weight = 2, color = "#000000")
                
        })
    }      
)