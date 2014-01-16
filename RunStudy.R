# Project Name: "Market Segmentation, Luxury Goods (Boats Case)"

rm(list = ls( )) # clean up the workspace
source("R/library.R")
source("R/heatmapOutput.R")
######################################################################

# THESE ARE THE PROJECT PARAMETERS NEEDED TO GENERATE THE REPORT

# When running the case on a local computer, modify this in case you saved the case in a different directory 
# (e.g. local_directory <- "C:/user/MyDocuments" )
# type in the Console below help(getwd) and help(setwd) for more information
local_directory <- getwd()
#local_directory <- "C:/Theos/insead/eLAB/Data_Analytics_Case_MarketSegmentation_LuxuryGoods"

cat("\n *********\n WORKING DIRECTORY IS ", local_directory, "\n PLEASE CHANGE IT IF IT IS NOT CORRECT using setwd(..) - type help(setwd) for more information \n *********")

# Please ENTER the name of the file with the data used. The file should contain a matrix with one row per observation (e.g. person) and one column per attribute. THE NAME OF THIS MATRIX NEEDS TO BE ProjectData (otherwise you will need to replace the name of the ProjectData variable below with whatever your variable name is, which you can see in your Workspace window after you load your file)
datafile_name="Boats"

# this loads the selected data: DO NOT EDIT THIS LINE
ProjectData <- read.csv(paste(paste(local_directory, "data", sep="/"), paste(datafile_name,"csv", sep="."), sep = "/"), sep=";", dec=",") # this contains only the matrix ProjectData
ProjectData=data.matrix(ProjectData) # make sure the data are numeric!!!! check your file!

# Please ENTER a name that describes the data for this project (which will appear on the titles of the plots)
data_name="Boating Company"

#### Factor Analysis parameters

# Please ENTER the number of factors to eventually use for this report
numb_factors_used = 2

# Please ENTER the rotation eventually used (e.g. "none", "varimax", "quatimax", "promax", "oblimin", "simplimax", and "cluster" - see help(principal)). Defauls is "varimax"
rotation_used="varimax"

# Please ENTER the selection criterions for the factors to use. 
# Choices: "eigenvalue", "variance", "manual"
factor_selectionciterion = "variance"

# Please ENTER the desired minumum variance explained (in case "variance" is the factor selection criterion used). 
minimum_variance_explained = 65  # between 1 and 100

# Please ENTER the number of factors to use in case "manual" is the factor selection criterion used
manual_numb_factors_used = 2

# Please ENTER then original raw attributes to use (default is 1:ncol(ProjectData), namely all of them)
factor_attributes_used= (min(ncol(ProjectData),2)):(min(ncol(ProjectData),30))
#factor_attributes_used= which(sapply(colnames(ProjectData), function (s) str_detect(s,"Q1_")))
# Please ENTER the distance metric eventually used for the clustering in case of hierarchical clustering (e.g. "euclidean", "maximum", "manhattan", "canberra", "binary" or "minkowski" - see help(dist)). Defauls is "euclidean"
distance_used="euclidean"

#### Clustering parameters

# Please ENTER the number of clusters to eventually use for this report
numb_clusters_used = 5

# Please ENTER then original raw attributes to use for the segmentation (the "segmentation attributes")
segmentation_attributes_used= (min(ncol(ProjectData),2)):(min(ncol(ProjectData),27))

# Please ENTER then original raw attributes to use for the profiling of the segments (the "profiling attributes")
profile_attributes_used=(min(ncol(ProjectData),28)):(min(ncol(ProjectData),35))

# Please enter the minimum number below which you would like not to print - this makes the readability of the tables easier. Default values are either 10e6 (to print everything) or 0.5. Try both to see the difference.
MIN_VALUE=0.4

###########################
# Would you like to also start a web application on YOUR LOCAL COMPUTER once the report and slides are generated?
# Select start_webapp <- 1 ONLY if you run the case on your local computer
# NOTE: Running the web application on your LOCAL computer will open a new browser tab
# Otherwise, when running on a server the application will be automatically available
# through the ShinyApps directory

# 1: start application on LOCAL computer, 0: do not start it
# SELECT 0 if you are running the application on a server 
# (DEFAULT is 0). 
strat_webapp  <- 0
ProjectDataFactor=ProjectData[,factor_attributes_used]
################################################
# Now run everything




######################################################################
if (1){ 
    unlink( "TMPdirSlides", recursive = TRUE )      
    dir.create( "TMPdirSlides" )
    setwd( "TMPdirSlides" )
    file.copy( "../doc/Slides.Rmd","Slides.Rmd", overwrite = T )
    slidify( "Slides.Rmd" )
    file.copy( 'Slides.html', "../doc/Slides.html", overwrite = T )
    setwd( "../" )
    unlink( "TMPdirSlides", recursive = TRUE )    
}

  unlink( "TMPdirReport", recursive = TRUE )      
  dir.create( "TMPdirReport" )
  setwd( "TMPdirReport" )
  file.copy( "../doc/Report.Rmd","Report.Rmd", overwrite = T )
  knit2html( 'Report.Rmd', quiet = TRUE )
  file.copy( 'Report.html', "../doc/Report.html", overwrite = T )
  setwd( "../" )
  unlink( "TMPdirReport", recursive = TRUE )

  
  if ( strat_webapp )
    runApp( "Web_Application" )   