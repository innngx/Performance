# Data Input and Library --------------------------------------------------

library(MASS)
library(rms)
library(ggplot2)
library(plyr)
library(scales)
library(foreign)
library(car)
library(gplots)

rm(list=ls())    #remove all datasets
setwd("C:/Users/Xgao/Desktop/Performance-ATC-NA/Data")    #set path

Panel <- read.csv("reg1214.csv", header = T)
reg1213 <- read.csv("reg1213.csv", header = T)
reg1314 <- read.csv("reg1314.csv", header = T)

# Fix effects -------------------------------------------------------------


coplot(Review ~ Year|Employee_Name, type="l", data=Panel)
coplot(Review ~ Year|Employee_Name, type="b", data=Panel)

scatterplot(Review ~ Year|Employee_Name, boxplots=F, smooth=T, reg.line=T, data=Panel)

plotmeans(Review ~ Employee_Name, data=Panel)

ols <- lm(Review ~ VS, data = Panel)
summary(ols)

yhat <- ols$fitted
plot(Panel$VS, Panel$Review)
abline(lm(Panel$Review ~ Panel$VS))

fixed.dum <- lm(Review ~ VS + factor(Employee_Name) - 1, data = Panel)
summary(fixed.dum)  
  
