National Parks Trip
========================================================
author: Scott Brenstuhl
date: 1/26/16

Why I made this
========================================================

I went to Yosemite a while ago and have been day dreaming
of taking a road trip to more National Parks. So I wanted 
something to:

- Tell me the closest parks to a given point
- Suggest the order to visit them in
- Tell me information about the parks

How it works
========================================================
I scraped <a href =https://en.wikipedia.org/wiki/List_of_national_parks_of_the_United_States>this Wikipedia article</a> for the data needed (Data_scraper.R).

Then the app uses the Google maps API to convert the user's 
input to latitude and longitude. Then finds closest parks
to them and orders them by nearest neighbor.

Finally I use <a href = https://rstudio.github.io/leaflet/>Leaflet.js</a> to map the results and a data table to give the user more information about the parks.

Challenges 
========================================================
When I had the idea for this, I thought it would be fairly simple to
do optimal routes. However it turns out this is a well known unsolved 
problem called the traveling salesman problem. Todd W. Schneider has a really 
good Shiny site illustrating the problem on <a href = http://toddwschneider.com/posts/traveling-salesman-with-simulated-annealing-r-and-shiny/> his blog</a>. 

Because of this I decided to settle for making routes using nearest neighbor
instead, but would like to come back and do something more sophisticated later.

Similarly, I would like to eventually add real driving routes distances and
times instead of using straight as the crow flies. 

Try my app to get your map like this!
========================================================


```r
map <- leaflet(data = example.data) %>%
                addTiles() %>%
                addMarkers(~long, ~lat, popup = ~Name) %>%
                addPolylines(lng = ~long,lat = ~lat, fill = F, weight = 2, color = "#000000")
saveWidget(map, 'example_map.html')
```
<div align="center">
    <iframe  title="My Map" width="600" height="300" src=example_map.html frameborder="0" allowfullscreen></iframe>
</div>
