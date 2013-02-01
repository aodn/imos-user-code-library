rm(list=ls())
setwd("SPECIFY THE LOCATION OF YOUR WORKING DIRECTORY ON YOUR MACHINE")
library(ncdf) ## Provides a high-level R interface to Unidata's netCDF data files, which are portable across platforms and include metadata information in addition to the data set
library(DAAG) ## To get the pause function. Otherwise use the Sys.sleep function to pause the loop for a specified amount of time
library(maps) ## To get a world map
library(raster) ## To be able to plot the gridded netCDF file

############################################################################################################################################################
###################################################### OPENING AND PLOTTING A NON-GRIDDED NETCDF FILE ###################################################### 
############################################################################################################################################################
nc<-open.ncdf("argo_float.nc")
x<-get.var.ncdf(nc,"LONGITUDE")
y<-get.var.ncdf(nc,"LATITUDE")
depth<-get.var.ncdf(nc,"PRES")
time<-get.var.ncdf(nc,"JULD")
date<-as.POSIXlt(time*3600*24,origin="1950-01-01",tz="UTC")

temp<-get.var.ncdf(nc,"TEMP")
sal<-get.var.ncdf(nc,"PSAL")

split.screen(c(1,2))
screen(1)
par(mar=c(4.5,4.5,0.5,0.5))
plot(temp,-depth,type="b",pch=19,xlab="Water temperature (°C)",ylab="Depth (m)",cex.lab=1.3,cex.axis=1.1)
screen(2)
par(mar=c(4.5,2.5,0.5,0.5))
plot(sal,-depth,type="b",pch=19,yaxt="n",xlab="Salinity (psu)",ylab="",cex.lab=1.3,cex.axis=1.1)
axis(2,at=seq(-2000,0,500))
close.screen(all=TRUE)

############################################################################################################################################################
######################################################## OPENING AND PLOTTING A GRIDDED NETCDF FILE ######################################################## 
############################################################################################################################################################
nc<-open.ncdf("ACORN_monthly_aggr.nc")
x<-get.var.ncdf(nc,"LONGITUDE")
y<-get.var.ncdf(nc,"LATITUDE")

speed<-get.var.ncdf(nc,"SPEED")
speed[,,][which((speed[,,])==9999)]<-NA

time<-get.var.ncdf(nc,"TIME")
date<-as.POSIXlt(time*3600*24,origin="1950-01-01",tz="UTC")

for (i in 1:length(time)){
	rast<-raster("ACORN_monthly_aggr.nc",varname="SPEED",band=i)
	par(mar=c(4.5,4.5,4.5,4.5))
	plot(rast,col=colorRampPalette(c("blue","yellow","red"))(255),main=date[i],xlim=c(min(x),max(x)),ylim=c(min(y),max(y)),xlab="Longitude",
	ylab="Latitude",cex.lab=1.3,cex.axis=1.1,zlim=c(min(speed[,,],na.rm=TRUE),max(speed[,,],na.rm=TRUE)))
	map('world',fill=TRUE,add=T)
	pause()
	print(i)
}