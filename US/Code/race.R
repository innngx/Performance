rm(list=ls())    #remove all datasets
mydata <- read.csv("../Data/datarace.csv", header = T)
RaceW <- as.numeric(mydata$Race == "W")

matched <- subset(mydata, !is.na(mydata$Review))
ggplot(matched, aes(x=matched$Race,fill=factor(matched$Review))) + geom_bar() + labs(x = "Race",y = "") + theme(legend.title=element_blank()) # this line revome the legend title
ggplot(matched, aes(x=matched$Race,fill=factor(matched$Review))) + geom_bar(position = "fill") + labs(x = "Race",y = "") + theme(legend.title=element_blank()) # this line revome the legend title
