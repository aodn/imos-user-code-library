ncParse <- function( inputFileName, parserOption, variables){
#
# ncParse {ncdf4}
#
# 
# Description
#
# Retrieves all information stored in a NetCDF file.
#
#
# Usage
#
# ncParse( inputFileName, parserOption = NA, variables = NA)
#
# 
# Arguments
#
# inputFileName : OPeNDAP URL or local address of the NetCDF file.
# parserOption : Character string indicating whether to retrieve the entire content of the NetCDF file or 
# only the metadata. If parserOption = 'all' or NA or is omitted (default) then the parser retrieves the entire file, 
# if parserOption = 'metadata' then the parser retrieves metadata only.
# variables :  Character string indicating whether to parse metadata (and data if parserOption = 'all' or NA or omitted) 
# for all variables (if variables = NA or is omitted, default) or only a specified set of variables (e.g. c('TEMP','PSAL')). 
#
#
# Details
#
# The ncParse function is the core of the "IMOS user code library". This function parses a NetCDF file from a 
# local address or an OPeNDAP URL, and harvests its entire 
# content into the workspace.
#
#
# Value
# 
# Returns a list of three sub-lists containing all the information stored in the original NetCDF file. 
# The 'metadata' sub-list stores all the global attributes of the NetCDF file, the 'dimensions' sub-list stores all the 
# information regarding the different dimensions of the NetCDF file, the 'variables' sub-list stores all the 
# data and attributes information of the NetCDF file. 
#
#
# Author
#
# Dr. Xavier Hoenner, IMOS/eMII
# email: xavier.hoenner@utas.edu.au
# Website: http://imos.org.au/  
# Apr 2013; Last revision: 24-Apr-2013
# Copyright 2013 IMOS
# The script is distributed under the terms of the GNU General Public License
#
# 
# References
# 
# The R software is freely available for all operating systems at: http://cran.r-project.org
# The 'ncdf4' package required to run the ncParse function can be downloaded at: http://cirrus.ucsd.edu/~pierce/ncdf/
#
#
# See also
# 
# Additional information about the procedures used to create this NetCDF parser can be found at: 
# https://github.com/aodn/imos_user_code_library/blob/master/IMOS_user_code_library.pdf
#
#
# Example
#
# Parse all data and metadata
# dataset <- ncParse ( '/path/to/netcdfFile.nc' , parserOption = 'all')
#
# Parse data and metadata for both PSAL and TEMP only
# dataset <- ncParse ( '/path/to/netcdfFile.nc', variables = c( 'PSAL', 'TEMP'))
#    
# Parse metadata only for PSAL.
# dataset <- ncParse ( '/path/to/netcdfFile.nc', parserOption = 'metadata', variables = 'PSAL')

ncdf <- nc_open( inputFileName, write=FALSE, readunlim=TRUE, verbose=FALSE)
stopifnot( class( ncdf) == "ncdf4")
if ( missing( parserOption) == TRUE) parserOption <- "all"
if ( is.na( parserOption) == TRUE) parserOption <- "all"
if ( missing( variables) == TRUE) variables <- NA

##### Extract dimension names
varinfos <- list()
for ( i in 1:ncdf$ndims){
	varinfos[[ncdf$dim[[i]]$name]] <- list( id = ncdf$dim[[i]]$id)
}
dimnames <- data.frame( names( varinfos), rep( "Dimension", length( names( varinfos))))
colnames(dimnames) <- c( "Name", "Type")

##### Extract variable names
nvars <- ncdf$nvars
for ( i in 1:ncdf$nvars){
	varinfos[[ncdf$var[[i]]$name]] <- list( natts = ncdf$var[[i]]$natts, dimids = ncdf$var[[i]]$dimids)
}
qcvars <- c( grep( "_quality_control", names( varinfos)), grep( "_QC", names( varinfos)))
histqc <- which( ( names( varinfos)) == "HISTORY_QCTEST")
if ( length( histqc) > 0) qcvars <- qcvars[-which(( qcvars) == histqc)]
vars <- c( 1:nvars)[-qcvars]
varnames <- data.frame( names( varinfos), rep( "Variable", length( names( varinfos))))
varnames[, 2] <- as.character( varnames[, 2])
if( length( qcvars) > 0) varnames[qcvars, 2] <- "QC_Variable"
colnames( varnames) <- c( "Name", "Type")

dimvarqcnames <- rbind( dimnames, varnames)
if ( length( which(( duplicated( dimvarqcnames[, 1])) == TRUE)) > 0) dimvarqcnames <- dimvarqcnames[-which(( duplicated( dimvarqcnames[, 1])) == TRUE),]
dimvar <- if( length( which(( dimvarqcnames[, 2]) == "QC_Variable")) == 0) dimvar <- dimvarqcnames else dimvar <- dimvarqcnames[-which(( dimvarqcnames[, 2]) == "QC_Variable"),]
dimvarqcnames <- as.character( dimvarqcnames[, 1])
dimvarnames <- as.character( dimvar$Name)
dimvartype <- as.character( dimvar$Type)

## Determine which variables to parse
if ( is.na( variables[1]) == FALSE){
    if( is.character( variables) == FALSE) stop( "variables value invalid, variables must be a character string")
	for ( i in 1:length( variables)){
		if( length( which(( dimvarnames) == variables[i])) == 0) stop( paste( "Variable ", variables[i], " is not listed as a variable of this NetCDF file"))
		if( dimvartype[which(( dimvarnames) == variables[i])] == "Dimension") stop( paste( "Variable ", variables[i], " is a dimension but not a variable of this NetCDF file"))
		}
	varsel <- which(( dimvarnames) == variables[1])
	if ( length( variables) > 1) {
		for ( i in 2:length( variables)){
			varsel <- c( varsel, which(( dimvarnames) == variables[i]))
		}
	}
	dimid <- varinfos[[ which(( names( varinfos)) == dimvarnames[ varsel[1]])]]$dimids
	dimid <- dimid[order( dimid)]
	dimsel <- ncdf$dim[dimid[1]+1][[1]]$name
	for ( i in 1:length( varsel)){
	dimid <- varinfos[[which(( names( varinfos)) == dimvarnames[varsel[i]])]]$dimids
	dimid <- dimid[order( dimid)]
	dimsel <- c( dimsel, ncdf$dim[dimid[1]+1][[1]]$name)
		if( length( dimid)>1) {
			for ( j in 2:length( dimid)){
				dimsel <- c( dimsel, ncdf$dim[dimid[j]+1][[1]]$name)
			}
		}
	}
	dimsel <- dimsel[-which(( duplicated( dimsel)) == TRUE)]
	dimselid <- which(( dimvarnames) == dimsel[1])
	if ( length( dimsel)>1) {
		for ( i in 2:length( dimsel)){
			dimselid <- c( dimselid, which(( dimvarnames) == dimsel[i]))
		}
	}
	dimvarnames <- dimvarnames[c( dimselid, varsel)]
	dimvartype <- dimvartype[c( dimselid, varsel)]
}

dataset <- list()
##### Extract global attributes
dataset$metadata <- list( netcdf_filename = ncdf$filename)
if ( ncdf$natts > 0) {
	for ( i in 1:ncdf$natts){
		dataset$metadata[[names( summary( ncatt_get( ncdf, 0))[, 1])[i]]] <- ncatt_get( ncdf, 0)[[i]]
	}
	}

for ( v in 1:length( dimvarnames)){
	if( length( ncatt_get( ncdf, dimvarnames[v]))>0) {
	data <- ncvar_get( ncdf, dimvarnames[v])
	natts <- varinfos[[which(( names( varinfos)) == dimvarnames[v])]]$natts
	dimid <- varinfos[[which(( names( varinfos)) == dimvarnames[v])]]$dimids
	if( length( dimid) > 0){
	dimid <- dimid[order( dimid)]
	dimension <- ncdf$dim[dimid[1]+1][[1]]$name
	if( length( dimid) > 1) {
		for ( j in 2:length( dimid)){
			dimension <- c( dimension, ncdf$dim[dimid[j]+1][[1]]$name)
		}
	}}} else {
		natts <- 0
		data <- ncdf$dim[[v]]$len
		}

	##### Convert time values into dates
	if ( ( dimvarnames[v] == "TIME" | dimvarnames[v] == "time" | dimvarnames[v] == "JULD" | dimvarnames[v] == "JULD_LOCATION") == TRUE && (length( grep( "days", ncatt_get( ncdf, dimvarnames[v], "units"))) == 1) == TRUE) unit <- 3600*24 else
	if ( (dimvarnames[v] == "TIME" | dimvarnames[v] == "time" | dimvarnames[v] == "JULD" | dimvarnames[v] == "JULD_LOCATION") == TRUE && (length( grep( "hours", ncatt_get( ncdf, dimvarnames[v], "units"))) == 1) == TRUE) unit <- 3600 else unit <- 1
	if ( dimvarnames[v] == "TIME" | dimvarnames[v] == "time" | dimvarnames[v] == "JULD" | dimvarnames[v] == "JULD_LOCATION" ) data <- as.POSIXlt( data*unit, origin=strsplit(ncatt_get( ncdf, dimvarnames[v], "units")$value,split=' ')[[1]][3], tz="UTC")
	##### Extract data from dimensions and variables
	if ( parserOption != "metadata" && parserOption != "all") stop( "parserOption value invalid")
	if ( parserOption == "metadata" && dimvartype[v] == "Dimension") dataset$dimensions[[dimvarnames[v]]] <- list()
	if ( parserOption == "metadata" && dimvartype[v] == "Variable") dataset$variables[[dimvarnames[v]]] <- list( dimensions = dimension)
	if ( parserOption == "all" && dimvartype[v] == "Dimension") dataset$dimensions[[dimvarnames[v]]] <- list( data = data)
	if ( parserOption == "all" && dimvartype[v] == "Variable") dataset$variables[[dimvarnames[v]]] <- list(dimensions = dimension, data = data)
	if ( length( ncatt_get( ncdf, dimvarnames[v])) > 0) { for ( j in 1:length( ncatt_get( ncdf, dimvarnames[v]))){
		if ( dimvartype[v] == "Dimension") dataset$dimensions[[dimvarnames[v]]][[dimnames( summary( ncatt_get( ncdf, dimvarnames[v])))[[1]][j]]] <- ncatt_get( ncdf, dimvarnames[v])[[j]]
		if ( dimvartype[v] == "Variable") dataset$variables[[dimvarnames[v]]][[dimnames( summary( ncatt_get( ncdf, dimvarnames[v])))[[1]][j]]] <- ncatt_get( ncdf, dimvarnames[v])[[j]]
	}}
	
	##### Extract QC data from dimensions and variables
	qcvar_id <- c( which(( dimvarqcnames) == paste( dimvarnames[v], "_quality_control", sep="")), which(( dimvarqcnames) == paste( dimvarnames[v], "_QC", sep="")))
	if ( length( qcvar_id) > 0) {
		qcdata <- ncvar_get( ncdf, dimvarqcnames[qcvar_id])
		nqcatts <- varinfos[[which(( names( varinfos)) == dimvarqcnames[qcvar_id])]]$natts
		if ( parserOption == "all" && dimvartype[v] == "Dimension") dataset$dimensions[[dimvarnames[v]]][[paste( "flags", sep="")]] <- qcdata
		if ( parserOption == "all" && dimvartype[v] == "Variable") dataset$variables[[dimvarnames[v]]][[paste( "flags", sep="")]] <- qcdata
		for ( j in 1:nqcatts){
			if ( dimvartype[v] == "Dimension") dataset$dimensions[[dimvarnames[v]]][[paste( "flags", "_", dimnames( summary( ncatt_get( ncdf, dimvarqcnames[qcvar_id])))[[1]][j], sep="")]] <- ncatt_get( ncdf, dimvarqcnames[qcvar_id])[[j]]
			if ( dimvartype[v] == "Variable") dataset$variables[[dimvarnames[v]]][[paste( "flags", "_", dimnames( summary( ncatt_get( ncdf, dimvarqcnames[qcvar_id])))[[1]][j], sep="")]] <- ncatt_get( ncdf, dimvarqcnames[qcvar_id])[[j]]
		}}

}
return( dataset)
if ( length( grep( "http", inputFileName)) == 1) nc_close( ncdf)
}
