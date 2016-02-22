##### Data Input and Library #####
library(MASS)
library(rms)
library(ggplot2)
library(plyr)
library(scales)

rm(list=ls())    #remove all datasets
setwd("C:/Users/Xgao/Documents/GitHub/Performance/US/Data")    #set path

matched <- read.csv("matched.csv", header = T)
# matched <- subset(matched, Business_Unit != "US Feeds") # delete US Feeds
# matched <- subset(matched, EEO_Category == "Operatives") # department check with gender
unmatched <- read.csv("unmatched.csv", header = T)
reg <- read.csv("reg.csv", header = T)
info <- read.csv("info.csv", header = T)
info <- subset(info, Age >= 10)  # Age less than 10 not normal

# dev.off()
# # if "Error in .Call.graphics(C_palette2, .Call(C_palette2, NULL)) : 
# # invalid graphics state"

##### Overall info analysis #####

names(info)
summary(info[,c(3,5:8,10,17:18,20)])

# Age Hist
info <- subset(info,Age>=10)
ggplot(info, aes(x=Age)) + 
  geom_histogram(aes(y=..density..), fill = "steelblue", colour = "white") + 
  geom_density(colour = "black") + 
  annotate("text", label = paste ("Average Age =",round(mean(info$Age),1)), x = 60, y = 0.04, family="serif", fontface="italic", colour="darkred") + 
  annotate("text", label = paste ("Median Age =",round(median(info$Age),1)), x = 60, y = 0.037, family="serif", fontface="italic", colour="darkred")
ggplot(info, aes(x=Age, fill=Gender)) +
  geom_histogram(alpha=.6, position="identity") + 
  theme(legend.title=element_blank()) # this line revome the legend title

# VS Hist
ggplot(info, aes(x=VS)) + 
  geom_histogram(aes(y=..density..), binwidth = 1, fill = "steelblue", colour = "white") + 
  geom_density(colour = "black") + 
  annotate("text", label = paste ("Average VS =",round(mean(info$VS),1)), x = 30, y = 0.25, family="serif", fontface="italic", colour="darkred") + 
  annotate("text", label = paste ("Median VS =",round(median(info$VS),1)), x = 30, y = 0.23, family="serif", fontface="italic", colour="darkred")
ggplot(info, aes(x=VS, fill=Gender)) +
  geom_histogram(alpha=.6, position="identity", binwidth = 1) + 
  theme(legend.title=element_blank()) # this line revome the legend title

# # # Review shows the function of screen performance # # #

# # TE glm [1548 employees - no retired]
# (no strong patten between Active and Termed)
info <- subset(info, Employee_Status_Type != "Retired")
info$Married <- as.numeric(info$Marital_Status == "Married")
info.glm <- glm(info$Employee_Status_Type ~ info$Gender+info$Age+info$Married+info$Children+info$VSm, family = binomial)
summary(info.glm)

# Married more likely to be active
ggplot(info, aes(x=factor(info$Married), fill=Employee_Status_Type)) + 
  geom_bar(position="fill") + labs(x = "Marital Status",y = "") + 
  theme(legend.title=element_blank()) # this line revome the legend title
# more children more likely to be active
ggplot(info, aes(x=factor(info$Children), fill=Employee_Status_Type)) + 
  geom_bar(position="fill") + labs(x = "Children",y = "") + 
  theme(legend.title=element_blank()) # this line revome the legend title
# more VS more likely to be active
ggplot(info, aes(VS, ..count..)) + labs(y = "") +
  geom_density(position = "fill", aes(fill = Employee_Status_Type, colour = Employee_Status_Type)) + 
  theme(legend.title=element_blank()) # this line revome the legend title
# Age vs Active
ggplot(info, aes(Age, ..count..)) + labs(y = "") +
  geom_density(position = "fill", aes(fill = Employee_Status_Type, colour = Employee_Status_Type)) + 
  theme(legend.title=element_blank()) # this line revome the legend title

# # TE glm (Review added) [416 employees - no retired]
# (Only Review shows significant: lower review -> TE)
TE <- subset(matched, Employee_Status_Type != "Retired")
TE$Married <- as.numeric(TE$Marital_Status == "Married")
glm <- glm(TE$Employee_Status_Type ~ TE$Gender+TE$Age+TE$Married+TE$Children+TE$VSm+TE$Review, family = binomial)
summary(glm)

# The termed have lower scores (Strong)
ggplot(TE, aes(x=factor(Review), fill=Employee_Status_Type)) + 
  geom_bar(position="fill") + labs(x = "Review",y = "") + 
  theme(legend.title=element_blank()) # this line revome the legend title

##### Performance analysis #####

# creat variables
Gender <- as.numeric(matched$Gender == "M") #dummy Gender
M_Status <- as.numeric(matched$Marital_Status == "Married")  #dummy Married
Active <- as.numeric(matched$Employee_Status_Type == "Active") #dummy Active
R <- as.numeric(matched$Review)
Review <- as.factor(matched$Review)

# # ordered logit - Review ~ Gender + Age + M_Status + Children + VSm + Active
# (Significant: Gender, M_Status, VSm, Active; Age, Children are not)
var <- c("Payroll_Name","Age","Children","VSm","VS")
mydata <- data.frame(Review,matched[var],Gender,M_Status,Active,R)
attach(mydata)

Y <- cbind(Review)
X <- cbind(Gender,Age,M_Status,Children,VSm,Active)
Xvar <- c("Gender","Age","M_Status","Children","VSm","Active")
table(Y)
summary(X)

ddist <- datadist(Xvar)
options(datadist = 'ddist')
ologit <- lrm(Y ~ X, data=mydata)
print(ologit)

#test direction with regular reg (verified)
fit <- lm(Y~X) 
summary(fit)

# fitted <- predict(ologit,mydata,type='fitted.ind')
# mydata <- data.frame(fitted,mydata)

# # plots
# Overall Review Plot for matched only
qplot(Review, data=mydata, geom="bar", 
      fill=Review) + labs(x = "Review", y = "")
# Yearly changes summary: all reviews = matched + unmatched
ddply(reg,.(Year),summarize,median=median(Review,na.rm=T),mean=mean(Review,na.rm=T),count=sum(!is.na(Review)))

# Review vs Age
ggplot(mydata, aes(Age, ..count..)) + labs(y = "") +
  geom_density(position = "fill", aes(fill = Review, colour = Review)) 
# Age: Hist and mean label
ggplot(mydata, aes(x=Age, fill=Review)) + geom_histogram(binwidth = 5) + labs(y = "") +
  annotate("text", label = paste ("Average Age =",round(mean(mydata$Age),1)), 
           x = 55, y = 81, family="serif", fontface="italic", colour="darkred", size=6) +
  annotate("text", label = paste ("Median Age =",round(median(mydata$Age),1)), 
           x = 55, y = 75, family="serif", fontface="italic", colour="darkred", size=6)

# Review vs Children
ggplot(mydata, aes(Children, ..count..)) + labs(y = "") +
  geom_density(position = "fill", aes(fill = Review, colour = Review))
ggplot(mydata, aes(x=factor(Children), fill=Review)) + 
  geom_bar(position="fill") + labs(x = "Children",y = "")
# Children: Hist and mean label
ggplot(mydata, aes(x=Children, fill=Review)) + geom_histogram(binwidth = 1) + labs(y = "") +
  annotate("text", label = paste ("Average Children =",round(mean(mydata$Children),1)), 
           x = 4.8, y = 150, family="serif", fontface="italic", colour="darkred", size=6)

# Review vs VS
mydatavs <- subset(mydata, VS != "32.17") #to keep consistent: remove the only VS 30 - Review 2 point
ggplot(mydatavs, aes(VS, ..count..)) + labs(y = "") +
  geom_density(position = "fill", aes(fill = Review, colour = Review)) 
# VS: Hist and Mean, median label
ggplot(mydata, aes(x=VS,fill=Review)) + geom_histogram() + labs(y = "") +
  annotate("text", label = paste ("Average VS =",round(mean(mydata$VS),1)), 
           x = 30, y = 85, family="serif", fontface="italic", colour="darkred", size=6) +
  annotate("text", label = paste ("Median VS =",round(median(mydata$VS),1)), 
           x = 30, y = 75, family="serif", fontface="italic", colour="darkred", size=6)

# Review vs all marital status
ggplot(mydata, aes(x=matched$Marital_Status, fill=Review)) + 
  geom_bar(position="fill") + labs(x = "Marital Status",y = "")
ggplot(mydata, aes(x=factor(M_Status), fill=Review)) +
  geom_bar(position="fill") + labs(x = "Marital Status: 1 = Married",y = "")
# marital status: Hist and Mean label
ggplot(mydata, aes(x=matched$Marital_Status,fill=Review)) + geom_bar() + labs(x = "Marital Status",y = "") +
  annotate("text", label = paste ("Marriage Rate:",percent(mean(mydata$M_Status))), 
           x = 3, y = 300, family="serif", fontface="italic", colour="darkred", size=6)
# difference in means between Married or not
ddply(mydata,.(M_Status),summarise,median=median(R),mean=mean(R),count=sum(!is.na(Review)))
wilcox.test(R~M_Status, alternative="less") #Nonparametric one side test
t.test(R~M_Status, var.equal = TRUE, alternative="less") #one side equal var.

# Gender F has higher Review
ggplot(mydata, aes(x=Review, fill=matched$Gender)) + 
  geom_bar(position="fill") + labs(y = "") + 
  theme(legend.title=element_blank()) # this line revome the legend title
ggplot(mydata, aes(x=matched$Gender, fill=Review)) +
  geom_bar(position="fill") + labs(x = "Gender", y = "")
# Gender: Hist and Mean label
ggplot(mydata, aes(matched$Gender, fill=Review)) + geom_bar() + labs(x = "Gender", y = "") + 
  annotate("text", label = paste ("Female:",percent((1-mean(Gender)))), 
           x = 1, y = 130, family="serif", fontface="italic", colour="darkred", size=6)
# difference in means between Gender
ddply(mydata,.(Gender),summarise,median=median(R),mean=mean(R),count=sum(!is.na(Review)))
wilcox.test(R~Gender, alternative="greater") #Nonparametric one side test
t.test(R~Gender, var.equal = TRUE, alternative="greater") #one side equal var.

# Active has higher Review (No Retired)
ggplot(TE, aes(x=Employee_Status_Type, fill=factor(Review))) + 
  geom_bar(position="fill") + labs(x = "Review", y = "") + 
  scale_fill_discrete(guide = guide_legend(title = "Review")) # title text
# Active: Hist and Mean label
ddply(matched,.(Employee_Status_Type),summarise,median=median(Review),mean=mean(Review),count=sum(!is.na(Review)))
ggplot(matched, aes(matched$Employee_Status_Type, fill=factor(Review))) + geom_bar() + labs(x = "", y = "") + 
  annotate("text", label = paste ("Active:",percent((mean(Active)))), 
           x = 1, y = 310, family="serif", fontface="italic", colour="darkred", size=6) + 
  scale_fill_discrete(guide = guide_legend(title = "Review")) # title text
# difference in means between Active or not (No retired)
ddply(TE,.(Employee_Status_Type),summarise,median=median(Review),mean=mean(Review),count=sum(!is.na(Review)))
wilcox.test(TE$Review~TE$Employee_Status_Type, alternative="greater") #Nonparametric one side test
t.test(TE$Review~TE$Employee_Status_Type, var.equal = TRUE, alternative="greater") #one side equal var.

ggplot(mydata, aes(x=Review, fill=matched$Employee_Status_Type)) + 
  geom_bar(position="fill") + labs(y = "") + 
  theme(legend.title=element_blank()) # this line revome the legend title

##### Termination analysis #####

# TEd vs ~.
TEd <- matched[which(matched$Employee_Status_Type == "Terminated"),]
names(TEd)
summary(TEd[,c(2,4:6,8,16,20:26)])

# TEd Overall Review Plot for matched only
qplot(factor(TEd$Review), data=TEd, geom="bar", 
      fill=factor(TEd$Review)) + labs(x = "Review", y = "") + 
  scale_fill_discrete(guide = guide_legend(title = "Review")) # title text
# TEd Yearly changes summary: all
ddply(reg[which(reg$Employee_Status_Type == "Terminated"),],.(Year),summarize,median=median(Review,na.rm=T),mean=mean(Review,na.rm=T),count=sum(!is.na(Review)))

# Voluntary or InVoluntary vs VS (Over 300 from US Feed, InV)
ggplot(TEd, aes(VS, ..count..)) + labs(x = "VS in TE", y = "") +
  geom_density(position = "fill", aes(fill = Employee_Status_Classification, colour = Employee_Status_Classification)) + 
  theme(legend.title=element_blank()) # this line revome the legend title
# Voluntary or InVoluntary vs Review
ggplot(TEd, aes(x=factor(Review), fill=Employee_Status_Classification)) + 
  geom_bar(position="fill") + labs(x = "Review", y = "") + 
  theme(legend.title=element_blank()) # this line revome the legend title
