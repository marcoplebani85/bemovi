#' Function to merge the morphology and data on X- and Y-coordinates into one file for further processing
#' 
#' This function merges the files containing morphology and coordinates (one for each video) into large dataset,
#' and saves it to the directory where the single files are located
#' @param to.data path to the working directory
#' @param particle.data.folder directory to which the data is saved as a text file
#' @export

organise_particle_data <- function(to.data, particle.data.folder) {
  
  IJ_output.dir <- paste(to.data, particle.data.folder, sep = "")
  
  ## the macro file names
  all.files <- dir(path = IJ_output.dir)
  ijout.files <- all.files[grep("ijout", all.files)]
  
  dd <- read.delim(paste(IJ_output.dir, ijout.files[1], sep = "//"))
  dd$file <- rep(gsub(".ijout.txt", "", ijout.files[1]), length(dd[, 1]))
  ## change column names because R is replacing missing header with X causing confusion with real X and Y positions
  colnames(dd) <- c("obs", "Area", "Mean", "Min", "Max", "X", "Y", "Perimeter", "Major", "Minor", "Angle", "Circ.", "Slice", 
                    "AR", "Round", "Solidity", "file")
  
  if (length(ijout.files) > 1) {
    for (i in 2:length(ijout.files)) {
      dd.t <- read.delim(paste(IJ_output.dir, ijout.files[i], sep = "//"))
      dd.t$file <- rep(gsub(".ijout.txt", "", ijout.files[i]), length(dd.t[, 1]))
      ## change column names because R is replacing missing header with X causing confusion with real X and Y positions
      colnames(dd.t) <- c("obs", "Area", "Mean", "Min", "Max", "X", "Y", "Perimeter", "Major", "Minor", "Angle", 
                          "Circ.", "Slice", "AR", "Round", "Solidity", "file")
      dd <- rbind(dd, dd.t)
    }
  }
  
  morphology.data <- dd
  
  # convert morphology to real dimensions
  morphology.data$Area <-   morphology.data$Area*pixel_to_scale
  morphology.data$Perimeter <- morphology.data$Perimeter*pixel_to_scale
  morphology.data$Major <- morphology.data$Major*pixel_to_scale
  morphology.data$Minor <-  morphology.data$Minor*pixel_to_scale
    
  save(morphology.data, file = paste(IJ_output.dir, "particle.RData", sep = "/"))
} 
