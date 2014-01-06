# Required R libraries (need to be installed - it can take a few minutes the first time you run the project)

if (require(devtools)==FALSE){install.packages("devtools"); library(devtools)}
if (require(slidifyLibraries)==FALSE){install_github("slidifyLibraries", "ramnathv"); library(slidifyLibraries)}
if (require(slidify)==FALSE){install_github("slidify", "ramnathv")}; library(slidify)
if (require(shiny)==FALSE){install.packages("shiny")}; library(shiny)
if (require(knitr)==FALSE){install.packages("knitr")}; library(knitr)


if (require(ggplot2)==FALSE){install.packages("ggplot2")}; library(ggplot2)
if (require(png)==FALSE){install.packages("png")}; library(png)
if (require(grid)==FALSE){install.packages("xtable")}; library(grid)
if (require(xtable)==FALSE){install.packages("xtable")}; library(xtable)
if (require(colorspace)==FALSE){install.packages("colorspace")}; library(colorspace)


if (require(Hmisc)==FALSE){install.packages("Hmisc")}; library(Hmisc)
if (require(vegan)==FALSE){install.packages("vegan")}; library(vegan)
if (require(fpc)==FALSE){install.packages("fpc")}; library(fpc)
if (require(GPArotation)==FALSE){install.packages("GPArotation")}; library(GPArotation)
if (require(cluster)==FALSE){install.packages("cluster")}; library(cluster)
if (require(FactoMineR)==FALSE){install.packages("FactoMineR")}; library(FactoMineR)
if (require(psych)==FALSE){install.packages("psych")}; library(psych)
if (require(class)==FALSE){install.packages("class")}; library(class)
#############

corstars <- function(x){
  require(Hmisc)
  x <- as.matrix(x)
  R <- rcorr(x)$r
  p <- rcorr(x)$P
  mystars <- ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", "  "))
  R <- format(round(cbind(rep(-1.111, ncol(x)), R), 3))[,-1]
  Rnew <- matrix(paste(R, mystars, sep=""), ncol=ncol(x))
  diag(Rnew) <- paste(diag(R), "", sep = "")
  rownames(Rnew) <- colnames(x)
  colnames(Rnew) <- paste(colnames(x), "", sep = "")
  Rnew <- as.data.frame(Rnew)
  return(Rnew)
}
