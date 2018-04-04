source("visualisation_helper.R")

# Set to feature ID that you're interested in.
# See: http://wals.info/feature
# For example: "3A" for consonant-vowel ratio
feature <- "3A"

# Set to WALS CLDF dump URL:
wals.dump <- "https://cdstar.shh.mpg.de/bitstreams/EAEA0-7269-77E5-3E10-0/wals_dataset.cldf.zip"

# Set to buffer width for buffering coordinate points:
buffer.width <- 200000

# Download data to cwd():
wals.data <- load.wals.data(wals.dump)

# Build/JOIN data sets:
feature.set <- build.feature.set(wals.data, feature)

# Build spatial point matrix:
spatial.points.df <- build.spatial.points.df(feature.set)

# Reproject data:
reprojected.df.x <- reproject.df(spatial.points.df)

# Buffer data with respect to the specific buffer width: 
buffered.features.x <- buffer.features(reprojected.df.x, width=buffer.width)

# Compute Voronoi tessellation: 
voronoi.data <- make.voronoi(reprojected.df.x)

# Clip shared features/points:
clipped.features <- clip.features(buffered.features.x, voronoi.data)

# Calculate distribution accross the globe:
geo.information <- intersect.geo.information(clipped.features, reprojected.df.x)

# Prepare plot:
plot <- make.plot(geo.information)

# Plot:
plot