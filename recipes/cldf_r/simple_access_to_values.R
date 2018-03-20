# Download the current WALS data set to the cwd:
download.file("https://cdstar.shh.mpg.de/bitstreams/EAEA0-7269-77E5-3E10-0/wals_dataset.cldf.zip",
              destfile = "wals_dataset.cldf.zip")

# Read language and value information from the ZIP file:
languages <- read.csv(unz("wals_dataset.cldf.zip", "languages.csv"),
                      header=TRUE, sep=",")
values <- read.csv(unz("wals_dataset.cldf.zip", "values.csv"),
                   header=TRUE, sep=",")

# Let's have a look at the distribution of velar nasals in
# initial position around the world (Feature 9A in WALS):
feature <- "9A"
values.filtered <- values[values$Parameter_ID == feature,]
values.filtered <- droplevels(values.filtered)

# Check output:
head(values.filtered)

# Make a simple barplot:
barplot(table(values.filtered$Value), ylim = c(0, 300))