## ----include=FALSE----------------------------------------------------------------------------------
knitr::opts_chunk$set(eval=TRUE, echo=TRUE, message=FALSE, warnings=FALSE)
solution <- TRUE


## ----map, fig.cap="Study area used by @howeetal", echo=FALSE----------------------------------------
knitr::include_graphics("studyarea-map.png")


## ----encounter, eval=FALSE, echo=FALSE--------------------------------------------------------------
## rate <- 3.27e-4 / 2  # because snapshot duration is 2sec
## #  therefore mean number of detections per second
## hours <- 12
## rate.per.day <- round(rate * hours * 60 * 60)
## print(rate.per.day) # detections per camera per day ?
## # duration <- 90 # days
## # rate.per.3mos <- round(rate.per.day * duration)
## # print(rate.per.3mos)


## ----howmany, eval=TRUE-----------------------------------------------------------------------------
library(dssd)
K0 <- 21
cv.howe <- 0.27
cv.target <- 0.20
K.target <- K0 * cv.howe^2 / cv.target^2


## ----answer, eval=TRUE, echo=FALSE------------------------------------------------------------------
paste("Number of camera stations to achieve CV of 0.20 =", round(K.target))


## ----reasonable, eval=FALSE, echo=FALSE-------------------------------------------------------------
## calculate.effort(21, 40, line.point="point")
## calculate.effort(21, 40, line.point="point", cv.values = .27)
## stations20 <- round(calculate.effort(21, 40, line.point="point", cv.values = .2)$Effort)
## stations10 <- round(calculate.effort(21, 40, line.point="point", cv.values = .1)$Effort)
## stations27 <- round(calculate.effort(21, 40, line.point="point", cv.values = .27)$Effort)


## ----dispersion, eval=TRUE--------------------------------------------------------------------------
dispersion <- 10284*(0.27)^2
calculate.effort(L0=21, n0=10284, q=dispersion, line.point="point")


## ----getshape, eval=TRUE----------------------------------------------------------------------------
library(dssd)
library(sf)
duikers <- "nice.shp"
incoming <- read_sf(duikers)
original.projection <- st_crs(incoming)
proj4string <- "+proj=aea +lat_1=56 +lat_2=62 +lat_0=50 +lon_0=-3 +x_0=0 +y_0=0 +ellps=intl +units=m"
pro <- st_transform(incoming, crs=proj4string)
theduikers <- make.region(region.name="Duikers", units="m",
                          shape=pro)


## ----thedesign, fig.height=5, fig.cap="Systematic design of cameras to achieve CV of 0.20", eval=TRUE----
mydesign <- make.design(region = theduikers,
                        transect.type = "point",
                        design = "systematic",
                        truncation = 15,
                        samplers = K.target)
thepoints <- generate.transects(mydesign)
plot(theduikers, thepoints, covered.area=TRUE)


## ----togpx, eval=TRUE-------------------------------------------------------------------------------
write.transects(thepoints,
                dsn = "camera-locations.gpx",
                layer = "points",
                dataset.options = "GPX_USE_EXTENSIONS=yes",
                proj4string = original.projection)


## ----googleearth, eval=TRUE, fig.cap="Camera station coordinates as gpx file viewed with Google Earth.", echo=FALSE----
knitr::include_graphics("gpxfileEarth.png")


## ----leaflet, fig.cap="Example deployment of cameras necessary to achieve CV of 0.20.", fig.height=6, eval=TRUE----
library(leaflet)
m <- leaflet() %>% addProviderTiles(providers$OpenTopoMap)
m <- m %>% 
  setView(-7.29, 5.76, zoom=9.5) %>%
  addMeasure(
    position = "topright",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "hectares",
    activeColor = "#3D535D",
    completedColor = "#7D4479")
tmp <- st_transform(thepoints@samplers, "+init=epsg:4326")
rawlat.long <- st_coordinates(tmp)
new <- cbind(tmp, rawlat.long)
new$label <-paste(round(new$X,3), round(new$Y,3), sep=", ")
icons <- awesomeIcons(
  icon = 'camera',
  iconColor = 'white',
  markerColor = "blue",
  library = 'fa'
)
m <- addAwesomeMarkers(m, data=new, icon=icons, 
                       label = ~as.character(new$label))
m <- addCircles(m, data=tmp, radius=15,color = 'red', weight = 2)
m

