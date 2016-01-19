library(rvest)
library(geosphere)

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

###
parks_data<- read.csv('data/parks.csv')
dist_tb <- NULL

for (park in parks_data$Name){
    start = subset(parks_data, Name == park)[c('long','lat')]
    distances = distHaversine(start, parks_data[c('long','lat')])
    dist_tb <- rbind(dist_tb, distances)
}

park_names <- gsub('(\\s)','_',parks_data$Name)
colnames(dist_tb) <- park_names
rownames(dist_tb) <- park_names
dist_tb <- data.frame(dist_tb,check.names = FALSE)

write.csv(dist_tb, 'data/distances.csv')
