# Data Input and Library --------------------------------------------------

library(MASS)
library(rms)
library(ggplot2)
library(plyr)
library(scales)

rm(list=ls())    #remove all datasets
setwd("C:/Users/Xgao/Documents/GitHub/Performance/US/Data")    #set path

info <- read.csv("info.csv", header = T)
# info <- subset(info, Age >= 10)  # Age less than 10 not normal
infoF <- subset(info, Gender == "F")
infoM <- subset(info, Gender == "M")
infoMA <- subset(infoM, Employee_Status_Type == "Active")
infoFA <- subset(infoF, Employee_Status_Type == "Active")
infoA <- subset(info, Employee_Status_Type == "Active")
infoT <- subset(info, Employee_Status_Type == "Terminated")
infoR <- subset(info, Employee_Status_Type == "Retired")

M <- as.numeric(info$Gender == "M") #dummy Gender
MA <- as.numeric(infoA$Gender == "M")
MT <- as.numeric(infoT$Gender == "M")
MR <- as.numeric(infoR$Gender == "M")

MS <- as.numeric(info$Marital_Status == "Married") #dummy Marital_Status
MSA <- as.numeric(infoA$Marital_Status == "Married")
MST <- as.numeric(infoT$Marital_Status == "Married")
MSR <- as.numeric(infoR$Marital_Status == "Married")
# Overall info analysis ---------------------------------------------------

names(info)
summary(info[,c(2,4:8,13:16,19,20)])

# Status Hist
ggplot(info,aes(Employee_Status_Type)) + geom_bar() + labs(x = "", y = "") + 
  annotate("text", label = paste ("Active: ",nrow(infoA)," (",round(100*nrow(infoA)/nrow(info),2),"%)",sep=""), 
           x = 1, y = 800, family="serif", fontface="italic", colour="darkred") + 
  annotate("text", label = paste ("Retired: ",nrow(infoR)," (",round(100*nrow(infoR)/nrow(info),2),"%)",sep=""), 
           x = 2, y = 50, family="serif", fontface="italic", colour="darkred") + 
  annotate("text", label = paste ("Terminated: ",nrow(infoT)," (",round(100*nrow(infoT)/nrow(info),2),"%)",sep=""), 
           x = 3, y = 840, family="serif", fontface="italic", colour="darkred")

# Status Hist Gender
ggplot(info, aes(Employee_Status_Type, fill=Gender)) + geom_bar() + labs(x = "Gender", y = "") + theme(legend.title=element_blank()) + # this line revome the legend title
  annotate("text", label = paste ("Female in all:",round((1-mean(M))*100,2),"%"), 
           x = 2, y = 840, family="serif", fontface="italic", colour="darkred") + 
  annotate("text", label = paste (round((1-mean(MA))*100,2),"%"), 
           x = 1, y = 240, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste (round((1-mean(MT))*100,2),"%"), 
           x = 3, y = 280, family="serif", fontface="italic", colour="darkred") + 
  annotate("text", label = paste (round((1-mean(MR))*100,2),"%"), 
           x = 2, y = 50, family="serif", fontface="italic", colour="darkred")

# Status Hist Marriage
ggplot(info, aes(Employee_Status_Type, fill=Marital_Status)) + geom_bar() + labs(x = "Gender", y = "") + theme(legend.title=element_blank()) + # this line revome the legend title
  annotate("text", label = paste ("Marriage Rate in all:",round((mean(MS))*100,2),"%"), 
           x = 2, y = 840, family="serif", fontface="italic", colour="darkred") + 
  annotate("text", label = paste (round((mean(MSA))*100,2),"%"), 
           x = 1, y = 260, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste (round((mean(MST))*100,2),"%"), 
           x = 3, y = 200, family="serif", fontface="italic", colour="darkred") + 
  annotate("text", label = paste (round((mean(MSR))*100,2),"%"), 
           x = 2, y = 50, family="serif", fontface="italic", colour="darkred")

# Age Hist Gender
ggplot(info, aes(x=Age, fill=Gender)) + geom_histogram(alpha=.8, binwidth = 3) + labs(y = "") +
  annotate("text", label = paste ("Average Age =",round(mean(info$Age),1)), 
           x = 60, y = 165, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Median Age =",round(median(info$Age),1)), 
           x = 60, y = 155, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg F =",round(mean(infoF$Age),1)), 
           x = 60, y = 140, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg M =",round(mean(infoM$Age),1)), 
           x = 60, y = 130, family="serif", fontface="italic", colour="darkred")

# Age Hist TE
ggplot(info, aes(x=Age, fill=Employee_Status_Type)) + geom_histogram(alpha=.8, binwidth = 3) + labs(y = "") + theme(legend.title=element_blank()) + # this line revome the legend title
  annotate("text", label = paste ("Avg Active =",round(mean(infoA$Age),1)), 
           x = 60, y = 160, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg Terminated =",round(mean(infoT$Age),1)), 
           x = 60, y = 150, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg Retired =",round(mean(infoR$Age),1)), 
           x = 60, y = 140, family="serif", fontface="italic", colour="darkred")

# Age Hist Gender Active
ggplot(infoA, aes(x=Age, fill=Gender)) + geom_histogram(alpha=.8, binwidth = 3) + labs(y = "", title = "Active") +
  annotate("text", label = paste ("Average Age =",round(mean(infoA$Age),1)), 
           x = 60, y = 95, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Median Age =",round(median(infoA$Age),1)), 
           x = 60, y = 90, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg F =",round(mean(infoFA$Age),1)), 
           x = 60, y = 80, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg M =",round(mean(infoMA$Age),1)), 
           x = 60, y = 75, family="serif", fontface="italic", colour="darkred")

# Children Hist Gender
ggplot(info, aes(x=Children, fill=Gender)) + geom_histogram(alpha=.8, binwidth = 1) + labs(y = "") +
  annotate("text", label = paste ("Average Children =",round(mean(info$Children),1)), 
           x = 4, y = 760, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg F =",round(mean(infoF$Children),1)), 
           x = 4, y = 710, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg M =",round(mean(infoM$Children),1)), 
           x = 4, y = 670, family="serif", fontface="italic", colour="darkred")

# Children Hist TE
ggplot(info, aes(x=Children, fill=Employee_Status_Type)) + geom_histogram(alpha=.8, binwidth = 1) + labs(y = "") + theme(legend.title=element_blank()) + # this line revome the legend title
  annotate("text", label = paste ("Avg Active =",round(mean(infoA$Children),1)), 
           x = 4, y = 750, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg Terminated =",round(mean(infoT$Children),1)), 
           x = 4, y = 700, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg Retired =",round(mean(infoR$Children),1)), 
           x = 4, y = 650, family="serif", fontface="italic", colour="darkred")

# Children Hist Gender Active
ggplot(infoA, aes(x=Children, fill=Gender)) + geom_histogram(alpha=.8, binwidth = 1) + labs(y = "", title = "Active") +
  annotate("text", label = paste ("Average Children =",round(mean(infoA$Children),1)), 
           x = 4, y = 360, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg F =",round(mean(infoFA$Children),1)), 
           x = 4, y = 335, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg M =",round(mean(infoMA$Children),1)), 
           x = 4, y = 315, family="serif", fontface="italic", colour="darkred")

# VS Hist Gender
ggplot(info, aes(x=VS, fill=Gender)) + geom_histogram(alpha=.8, binwidth = 1) + labs(y = "") +
  annotate("text", label = paste ("Average VS =",round(mean(info$VS),1)), 
           x = 20, y = 460, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Median VS =",round(median(info$VS),1)), 
           x = 20, y = 430, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg F =",round(mean(infoF$VS),1)), 
           x = 20, y = 390, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg M =",round(mean(infoM$VS),1)), 
           x = 20, y = 360, family="serif", fontface="italic", colour="darkred")

# VS Hist TE
ggplot(info, aes(x=VS, fill=Employee_Status_Type)) + geom_histogram(alpha=.8, binwidth = 1) + labs(y = "") + theme(legend.title=element_blank()) + # this line revome the legend title
  annotate("text", label = paste ("Avg Active =",round(mean(infoA$VS),1)), 
           x = 20, y = 460, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg Terminated =",round(mean(infoT$VS),1)), 
           x = 20, y = 430, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg Retired =",round(mean(infoR$VS),1)), 
           x = 20, y = 400, family="serif", fontface="italic", colour="darkred")

# VS Hist Gender Active
ggplot(infoA, aes(x=VS, fill=Gender)) + geom_histogram(alpha=.8, binwidth = 1) + labs(y = "", title = "Active") +
  annotate("text", label = paste ("Average VS =",round(mean(infoA$VS),1)), 
           x = 20, y = 140, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Median VS =",round(median(infoA$VS),1)), 
           x = 20, y = 130, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg F =",round(mean(infoFA$VS),1)), 
           x = 20, y = 115, family="serif", fontface="italic", colour="darkred") +
  annotate("text", label = paste ("Avg M =",round(mean(infoMA$VS),1)), 
           x = 20, y = 105, family="serif", fontface="italic", colour="darkred")
