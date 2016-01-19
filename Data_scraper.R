library(rvest)

wiki_parks <- read_html("https://en.wikipedia.org/wiki/List_of_national_parks_of_the_Udata:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAMElEQVR42mNgIAXY2Nj8x8cHC8AwMl9XVxe3QqwKcJmIVwFWhehW4LQSXQCnm3ABAHD6MDrmRgfrAAAAAElFTkSuQmCCnited_States")

# Grab the first table from the wikipedia page
parks_data <- wiki_parks %>%
    html_node(".wikitable") %>%
    html_table()

# Make the col_names easier to work with
names(parks_data) <- gsub(" [\\(]..*|[\\[]..*","",names(parks_data)) %>%
                    gsub(" ","_",.)

# Isolating states
parks_data$state <- gsub("[\\\n]..*","",parks_data$Location)

# Isolating location data then splitting to lat and long
lat_long <- gsub("..*(\\/) |(\\()..*| ","",parks_data$Location)
parks_data$lat <- gsub("(;)..*","", lat_long) %>%
    as.numeric()

# For the life of me I can not understand where the weird
# invisable characters are coming from, this fixes it though
parks_data$long <- gsub("..*;","", lat_long) %>%
    str_conv("ISO-8859-2") %>%
    gsub("ďťż", "", .) %>%
    as.numeric()

# Clean up dates
parks_data$Date_established <- gsub("(-0000)..*|(00000000)","",parks_data$Date_established)

# Clean up area
parks_data$Area <- gsub("..*♠| acres..*|,", "", parks_data$Area)

# Remove unneeded cols
parks_data$Location <- NULL
parks_data$Photo <- NULL

write.csv(parks_data, "data/parks.csv", row.names = FALSE)

#####
clust <- kmeans(data.frame(parks_data$lat, parks_data$long),5)

plotcluster(data.frame(parks_data$lat, parks_data$long), clust$cluster)
    
ggplot(parks_data, aes(lat, long)) +
    geom_point()

leaflet(data = parks_data) %>%
    addTiles() %>%
    addMarkers(~long, ~lat, popup = ~Name)

my_lat <- 38.00
my_long <- -122.00

c("Me", NULL, NULL, NULL, NULL, NULL, my_lat, my_long)

