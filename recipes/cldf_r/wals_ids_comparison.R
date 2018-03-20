# Download the current WALS data set to the cwd:
download.file("https://cdstar.shh.mpg.de/bitstreams/EAEA0-7269-77E5-3E10-0/wals_dataset.cldf.zip",
              destfile = "wals_dataset.cldf.zip")

# Read language and value information from the ZIP file:
languages <- read.csv(unz("wals_dataset.cldf.zip", "languages.csv"),
                      header=TRUE, sep=",")
values <- read.csv(unz("wals_dataset.cldf.zip", "values.csv"),
                   header=TRUE, sep=",")

# Let's lookup the feature "Hand and Arm" that has got two levels:
# Identical and Different, for the same or different lexemes for hand/arm
# in a language, respectively:
feature <- "129A"
values.filtered <- values[values$Parameter_ID == feature,]
values.filtered <- droplevels(values.filtered)

# Naturally, the amount of languages we have information
# concerning this feature is identical to the information available
# in WALS online:
dim(values.filtered)[1] == (228 + 389)

# Make a simple barplot:
barplot(table(values.filtered$Value), ylim = c(0, 400))

# We want some more information about the languages, so let's
# merge the filtered list from above with a list containing language
# information:
languages.filtered <- languages[languages$ID %in% values.filtered$Language_ID,]
colnames(languages.filtered)[1] <- "Language_ID"
merged <- merge(languages.filtered, values[values$Parameter_ID == feature,], by = "Language_ID", all = TRUE)

# Merged now has our feature information list as well as language information, for example
# geographical coordinates for the languages. Let's build a (simple, non-sensical) regression
# model and see whether hand/arm-colexification is connected to spatial information:
glm.analysis <- glm(merged$Value ~ merged$Longitude + merged$Latitude, family = "binomial")

# Having eyeballed the map for about five seconds there is indeed a strong confirmation
# in our model for a specific geographic distribution:
summary(glm.analysis)

# Let's confirm this distrubtion by loading a different data set,
# namely the Intercontinental Dictionary Series:

# Download the current WALS data set to the cwd:
download.file("https://cdstar.shh.mpg.de/bitstreams/EAEA0-9C1A-66E2-D0B3-0/ids_dataset.cldf.zip",
              destfile = "ids_dataset.cldf.zip")

# Read language and value information from the ZIP file:
languages.ids <- read.csv(unz("ids_dataset.cldf.zip", "languages.csv"),
                      header=TRUE, sep=",")
parameters.ids <- read.csv(unz("ids_dataset.cldf.zip", "parameters.csv"),
                   header=TRUE, sep=",")
forms.ids <- read.csv(unz("ids_dataset.cldf.zip", "forms.csv"),
                           header=TRUE, sep=",", encoding="UTF-8")

meaning.hand <- "4-330"
meaning.arm <- "4-310"

hand.filtered <- forms.ids[forms.ids$Parameter_ID == meaning.hand,]
hand.filtered <- droplevels(hand.filtered)

arm.filtered <- forms.ids[forms.ids$Parameter_ID == meaning.arm,]
arm.filtered <- droplevels(arm.filtered)

merged.hand.arm <- merge(hand.filtered, arm.filtered, by = "Language_ID", suffixes = c('.hand', '.arm'))
same.lexeme <- merged.hand.arm[as.character(merged.hand.arm$Form.hand) == as.character(merged.hand.arm$Form.arm), ]
colnames(languages.ids)[1] <- "Language_ID"

# Merge to get easy access to the Glottocode:
merge.for.comparison <- merge(same.lexeme, languages.ids, by = "Language_ID")

# Compare to the WALS feature selection from above:
overlap <- merged[merged$Glottocode %in% merge.for.comparison$Glottocode,]

# There is an overlap of 24 entries for the same/same entries in both databases:
dim(overlap)

# There are 8 languoids that have a "Different" value for the arm/hand colexification
# but have the same lexeme in IDS:
differences <- subset(overlap, Value == "Different")
dim(differences)
