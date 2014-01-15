
ProjectDataFactor=ProjectData[,factor_attributes_used]

######################################################################

if (0){ 
  unlink( "TMPdirSlides", recursive = TRUE )      
  dir.create( "TMPdirSlides" )
  setwd( "TMPdirSlides" )
  file.copy( paste(local_directory,"doc/Slides.Rmd", sep="/"),"Slides.Rmd", overwrite = T )
  slidify( "Slides.Rmd" )
  file.copy( 'Slides.html', paste(local_directory,"doc/Slides.html", sep="/"), overwrite = T )
  setwd( "../" )
  unlink( "TMPdirSlides", recursive = TRUE )      
}

unlink( "TMPdirReport", recursive = TRUE )      
dir.create( "TMPdirReport" )
setwd( "TMPdirReport" )
file.copy( paste(local_directory,"doc/Report.Rmd", sep="/"),"Report.Rmd", overwrite = T )
slidify( "Report.Rmd" )
file.copy( 'Report.html', paste(local_directory,"doc/Report.html", sep="/"), overwrite = T )
setwd( "../" )
unlink( "TMPdirReport", recursive = TRUE )      
