## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  echo = TRUE, warning = FALSE, message = FALSE,
  out.width = "100%")

## ----setup, include=FALSE-----------------------------------------------------
md_fig_dir<- "../man/figures/" #Path relative to this Rmd
R_fig_dir<- "../figures/" #Path relative to child Rmd

## -----------------------------------------------------------------------------
library(GLCMTextures) #Load GLCMTextures package

## ----eval=FALSE---------------------------------------------------------------
#  help(package="GLCMTextures")

## -----------------------------------------------------------------------------
test_matrix<- matrix(data=c(2,0,1,3,0,0,0,3,2), nrow = 3, ncol=3)
print(test_matrix)

## ----echo=FALSE---------------------------------------------------------------
init_glcm<- matrix(data = 0, nrow = 4, ncol = 4)
init_glcm

## ----echo=FALSE---------------------------------------------------------------
init_glcm[3,4]<-1
init_glcm[4,3]<-1
init_glcm

## -----------------------------------------------------------------------------
horizontal_glcm<- make_glcm(test_matrix, n_levels = 4, shift = c(1,0), normalize = FALSE)
horizontal_glcm

## -----------------------------------------------------------------------------
horizontal_glcm<- horizontal_glcm/sum(horizontal_glcm)
horizontal_glcm

## -----------------------------------------------------------------------------
make_glcm(test_matrix, n_levels = 4, shift = c(1,0), normalize = TRUE)

## -----------------------------------------------------------------------------
glcm_metrics(horizontal_glcm)

## ----elevation----------------------------------------------------------------
r<- rast(volcano, extent= ext(2667400, 2667400 + ncol(volcano)*10, 6478700, 6478700 + nrow(volcano)*10), crs = "EPSG:27200") #Use preloaded volcano dataset as a raster
plot(r) #plot values

## ----rq_er--------------------------------------------------------------------
rq_equalrange<- quantize_raster(r = r, n_levels = 16, quant_method = "range")
plot(rq_equalrange, col=grey.colors(16))

## ----echo=FALSE---------------------------------------------------------------
print(paste("Min Val =", unlist(global(rq_equalrange, min))))
print(paste("Max Val =", unlist(global(rq_equalrange, max))))

## ----rq_ep--------------------------------------------------------------------
rq_equalprob<- quantize_raster(r = r, n_levels = 16, quant_method = "prob")
plot(rq_equalprob, col=grey.colors(16))

## ----echo=FALSE---------------------------------------------------------------
print(paste("Min Val =", unlist(global(rq_equalprob, min))))
print(paste("Max Val =", unlist(global(rq_equalprob, max))))

## -----------------------------------------------------------------------------
freq(rq_equalprob)[,c("value", "count")]

## ----textures1----------------------------------------------------------------
textures1<- glcm_textures(rq_equalprob, w = c(3,5), n_levels = 16, quant_method = "none", shift = c(1,0)) 
plot(textures1)

## ----textures2----------------------------------------------------------------
textures2<- glcm_textures(r, w = c(3,5), n_levels = 16, quant_method = "prob", shift=c(1,0)) 
all.equal(values(textures1), values(textures2))

## ----textures3----------------------------------------------------------------
textures3<- glcm_textures(r, w = c(3,5), n_levels = 16, quant_method = "prob", shift = list(c(1, 0), c(1, 1), c(0, 1), c(-1, 1))) 
plot(textures3)

