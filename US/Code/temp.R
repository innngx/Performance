library(corrgram)
corrgram(mydata1, order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie, text.panel=panel.txt,
         main="test")

corrgram(mydata, order=TRUE, lower.panel=panel.ellipse,
         upper.panel=panel.pts, text.panel=panel.txt,
         diag.panel=panel.minmax, 
         main="test1")

Child <- as.numeric(mydata$Children != 0)
ggplot(mydata, aes(x=factor(Child), fill=Review)) +
  geom_bar(position="fill") + labs(x = "Child Status: 1 = Married",y = "")

# difference in means between Married or not
ddply(mydata,.(Child),summarise,median=median(R),mean=mean(R),count=sum(!is.na(Review)))
wilcox.test(R~Child, alternative="less") #Nonparametric one side test
t.test(R~Child, var.equal = TRUE, alternative="less") #one side equal var.

mydata1 <- data.frame(mydata[3:9],Child)
library(Hmisc)
rcorr(as.matrix(mydata1))

#######################################################################################################
info <- subset(info,Age>=10)
ggplot(info, aes(x=Age)) + 
  geom_histogram(aes(y=..density..), fill = "steelblue", colour = "white") + 
  geom_density(colour = "black") + 
  annotate("text", label = paste ("Average Age =",round(mean(info$Age),1)), x = 60, y = 0.04, family="serif", fontface="italic", colour="darkred", size=10) + 
  annotate("text", label = paste ("Median Age =",round(median(info$Age),1)), x = 60, y = 0.037, family="serif", fontface="italic", colour="darkred", size=10)
ggplot(info, aes(x=Age, fill=Gender)) +
  geom_histogram(alpha=.6, position="identity") + 
  theme(legend.title=element_blank()) # this line revome the legend title

# VS Hist
ggplot(info, aes(x=VSm/12)) + 
  geom_histogram(aes(y=..density..), binwidth = 1, fill = "steelblue", colour = "white") + 
  geom_density(colour = "black") + 
  annotate("text", label = paste ("Average VS =",round(mean(info$VSm)/12,1)), x = 200/12, y = 0.1, family="serif", fontface="italic", colour="darkred", size=10) + 
  annotate("text", label = paste ("Median VS =",round(median(info$VSm)/12,1)), x = 200/12, y = 0.08, family="serif", fontface="italic", colour="darkred", size=10)
ggplot(info, aes(x=VSm/12, fill=Gender)) +
  geom_histogram(alpha=.6, position="identity", binwidth = 1) + 
  theme(legend.title=element_blank()) # this line revome the legend title

ggplot(mydata, aes(x=matched$Gender)) + labs(x = "Gender",y = "") +
  geom_histogram(aes(), fill = "steelblue", colour = "white") + 
  annotate("text", label = paste ("Female:",percent((1-mean(Gender)))), 
           x = 1, y = 200, family="serif", fontface="italic", colour="darkred", size=8)

ggplot(mydata, aes(x=Review, fill=matched$Gender)) + 
  geom_bar() + labs(y = "") + 
  theme(legend.title=element_blank()) # this line revome the legend title

ggplot(mydata, aes(matched$Gender, fill=matched$Gender)) + geom_bar() +
  facet_grid(. ~ Review) + labs(y = "") + 
  theme(legend.title=element_blank())  # this line revome the legend title

ggplot(mydata, aes(matched$Gender, fill=Review)) + geom_bar() + labs(x = "Gender", y = "") + 
  annotate("text", label = paste ("Female:",percent((1-mean(Gender)))), 
           x = 1, y = 200, family="serif", fontface="italic", colour="darkred", size=8)

# Hist with Review and average
ggplot(mydata, aes(x=VSm,fill=Review)) + geom_bar() + labs(y = "") +
  annotate("text", label = paste ("Average VS =",round(mean(mydata$VSm),1)), 
           x = 300, y = 80, family="serif", fontface="italic", colour="darkred", size=8) +
  annotate("text", label = paste ("Median VS =",round(median(mydata$VSm),1)), 
           x = 300, y = 75, family="serif", fontface="italic", colour="darkred", size=8)

# Only Hist with density
ggplot(mydata, aes(x=VSm)) + 
  geom_histogram(aes(y=..density..), fill = "steelblue", colour = "white") + 
  geom_density(colour = "black") + labs(y = "")

ggplot(mydata, aes(x=Children, fill=Review)) + geom_bar(binwidth = 1) + labs(y = "") +
  annotate("text", label = paste ("Average Children =",round(mean(mydata$Children),1)), 
           x = 4, y = 150, family="serif", fontface="italic", colour="darkred", size=8)
