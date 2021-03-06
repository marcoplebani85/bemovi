### Modification of F.Pennekamps link_particle function from the bemovi package by Jason Griffiths.

# the parallel package is used to allow multiple cores to be used to simultaneously perform a particle linker executable

#the mcapply function is used and its syntax is very very similar to other apply loops

require(parallel)
n.cores<-detectCores(all.tests = FALSE, logical = TRUE)

link_particles_mc<-function (to.data, particle.data.folder, trajectory.data.folder, 
          linkrange = 1, disp = 10, start_vid = 1, memory = 512) 
{
  PA_output_dir <- paste0(to.data, particle.data.folder)
  traj_out.dir <- paste0(to.data, trajectory.data.folder)
  dir.create(traj_out.dir, showWarnings = F)
  all.files <- dir(PA_output_dir, pattern = ".ijout.txt")
 
  mclapply(start_vid:length(all.files), FUN=function(j){

 
    PA_data <- read.table(paste0(PA_output_dir, "/", all.files[j]), 
                          sep = "\t", header = T)
    if (length(PA_data[, 1]) > 0) {
      dir <- paste0(to.data, gsub(".cxd", "", sub(".ijout.txt", 
                                                  "", all.files[j])))
      dir.create(dir)
      for (i in 1:max(PA_data$Slice)) {
        frame <- subset(PA_data, Slice == i)[, c(6, 7)]
        frame$Z <- rep(0, length(frame[, 1]))
        sink(paste0(dir, "/frame_", sprintf("%04d", i - 
                                              1), ".txt"))
        cat(paste0("frame ", i - 1))
        cat("\n")
        sink()
        write.table(frame, file = paste0(dir, "/frame_", 
                                         sprintf("%04d", i - 1), ".txt"), append = T, 
                    col.names = F, row.names = F)
      }
      if (.Platform$OS.type == "unix") {
        cmd <- paste0("java -Xmx", memory, "m -Dparticle.linkrange=", 
                      linkrange, " -Dparticle.displacement=", disp, 
                      " -jar ", " \"", to.particlelinker, "/ParticleLinker.jar", 
                      "\" ", "'", dir, "'", " \"", traj_out.dir, 
                      "/ParticleLinker_", all.files[j], "\"")
        system(paste0(cmd, " \\&"))
      }
      if (.Platform$OS.type == "windows") {
        cmd <- paste0("C:/Progra~2/java/jre7/bin/javaw.exe -Xmx", 
                      memory, "m -Dparticle.linkrange=", linkrange, 
                      " -Dparticle.displacement=", disp, " -jar", 
                      gsub("/", "\\\\", paste0(" \"", to.particlelinker, 
                                               "/ParticleLinker.jar")), "\" ", gsub("/", 
                                                                                    "\\\\", paste0(" ", "\"", dir, "\"")), gsub("/", 
                                                                                                                                "\\\\", paste0(" ", "\"", traj_out.dir, "/ParticleLinker_", 
                                                                                                                                               all.files[j], "\"")))
        system(cmd)
      }
      unlink(dir, recursive = TRUE)
    }
    if (length(PA_data[, 1]) == 0) {
      print(paste("***** No particles were detected in video", 
                  all.files[j], " -- check the raw video and also threshold values"))
    }
  
  }, mc.cores = n.cores)
  #, mc.cores = getOption("mc.cores", 12))# close mc apply loop
  
  
  data <- organise_link_data(to.data, trajectory.data.folder)
  calculate_mvt(data, to.data, trajectory.data.folder, pixel_to_scale, 
                fps)
}