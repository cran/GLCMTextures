#' Quantizes raster to a set number of discrete levels
#'
#' Quantizes raster to a set number of discrete levels starting at 0. There are 2 methods of quantization are available: "equal range" and "equal prob"
#' @param r A single layer SpatRaster, RasterLayer, or matrix.
#' @param n_levels number of levels to quantize to
#' @param quant_method quantization method (either "range" or "prob"). "range" quantization will create bins that cover a range of equal size. "prob" performs equal probability quantization and will use quantiles to create bins with approximately equal number of samples.
#' @param min_val minimum value for equal range quantization (if not supplied, the minimum value of the raster is used)
#' @param max_val maximum value for equal range quantization (if not supplied, the maximum value of the raster is used)
#' @param maxcell positive integer used to take a regular sample of x if "prob" is used as 'quant_method' (default is Inf)
#' @param filename character Output filename.
#' @param overwrite logical. If TRUE, filename is overwritten (default is FALSE).
#' @param method deprecated. Use 'quant_method'
#' @return a single layer SpatRaster or RasterLayer with integer values ranging from 0 to n_levels-1
#' @param wopt list with named options for writing files as in writeRaster
#' @examples
#' r<- rast(volcano, extent= ext(2667400, 2667400 + ncol(volcano)*10,
#' 6478700, 6478700 + nrow(volcano)*10),
#' crs = "EPSG:27200")
#' rq1 <- quantize_raster(r = r, n_levels = 16, quant_method = "prob")
#' rq2 <- quantize_raster(r = r, n_levels = 16, quant_method = "range")
#' @import  terra
#' @importFrom  raster raster
#' @importFrom raster writeRaster
#' @details Equal probability quantization is the method recommended in Haralick et al., 1973. However, equal range may be more desirable if making comparisons across several different rasters where you need the gray levels to correspond in a consistent way to the original data, as you can supply the global max/min or the theoretical max/min values that could occur. When equal probability quantization is used, quantiles are generated using type 8 as recommended by Hyndman and Fan (1996). This method provides estimates that are approximately median-unbiased regardless of the distribution of x.
#' @references
#' Haralick, R.M., Shanmugam, K., Dinstein, I., 1973. Textural features for image classification. IEEE Transactions on Systems, Man, and Cybernetics 610–621. https://doi.org/10.1109/TSMC.1973.4309314
#'
#' Hyndman, R.J., Fan, Y., 1996. Sample Quantiles in Statistical Packages. The American Statistician 50, 361–365. https://doi.org/10.1080/00031305.1996.10473566
#' @export

quantize_raster<- function(r, n_levels, quant_method=NULL, min_val=NULL, max_val=NULL, maxcell=Inf, filename= NULL, overwrite = FALSE, method=NULL, wopt=list()){
  og_class<- class(r)[1]
  if(og_class =="RasterLayer"){
    r<- terra::rast(r) #Convert to SpatRaster
  }
  if(og_class =="matrix"){
    r<- terra::rast(r) #Convert to SpatRaster
  }
  if(terra::nlyr(r)!=1){
    stop("Error: Input raster must be one layer.")
  }
  if(!is.null(method)){
    warning("Use of 'method' is deprecated. Instead use 'quant_method'")
    if(is.null(quant_method)){
      if(method == "equal prob"){quant_method<- "prob"}
      if(method == "equal range"){quant_method<- "range"}
      }
  }
  if(is.null(quant_method)){stop("quant_method is NULL. Specify as 'range' or 'prob'")}
  if(quant_method == "range"){
    if(is.null(min_val)){min_val<- unlist(terra::global(r, fun = min, na.rm=TRUE))}
    if(is.null(max_val)){max_val<- unlist(terra::global(r, fun = max, na.rm=TRUE))}
    qrules<- seq(min_val, max_val, length.out = (n_levels + 1))
  } else if (quant_method == "prob") {
    qrules<- unlist(terra::global(r, fun = quantile, probs= seq(0,1,length.out = n_levels+1), na.rm=TRUE, type=8, maxcell=maxcell))
  } else {
    stop("Error: quant_method must be 'range' or 'prob'")
  }
  qrules[1]<- -Inf
  qrules[length(qrules)]<- Inf #Make edges infinite in case sample is used which doesn't contain min/max value
  rq <- terra::classify(r, rcl = qrules, include.lowest = TRUE, right = FALSE, wopt=wopt)
  rq<- terra::as.int(rq, wopt=wopt)

  if(og_class =="RasterLayer"){
    rq<- raster::raster(rq)
    if(!is.null(filename)){
      return(raster::writeRaster(rq, filename=filename, overwrite=overwrite))
      }
  }

  if(og_class =="matrix"){
    if(!is.null(filename)){
      terra::writeRaster(rq, filename=filename, overwrite=overwrite, wopt=wopt)
    }
    rq<- as.matrix(rq, wide=TRUE)
  }

  if((og_class=="SpatRaster") & (!is.null(filename))){
    return(terra::writeRaster(rq, filename=filename, overwrite=overwrite, wopt=wopt))
  }
  return(rq)
}

