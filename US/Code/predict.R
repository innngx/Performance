rm(list=ls())    #remove all datasets


mydata <- read.csv("../Data/mydata2015.csv", header = T)


R <- as.numeric(mydata$R_2015)
Review <- as.factor(mydata$R_2015)
lnpay <- log(mydata$Pay)

attach(mydata)

Y <- cbind(Review)
X <- cbind(Gender,Age,M_Status,Children,Edu,Pay)
Xvar <- c("Gender","Age","M_Status","Children","Edu","Pay")
table(Review)
summary(cbind(X,R))

ddist <- datadist(Xvar)
options(datadist = 'ddist')
ologit <- lrm(Y ~ X, data=mydata)
print(ologit)

lm <- lm(R ~ X)
summary(lm)

lmp <- lm(lnpay ~ R+Gender+Age+M_Status+Children+Edu)
summary(lmp)


# pay by department
ddply(mydata,.(Department),summarise,
      median=median(Pay),mean=mean(Pay),count=sum(!is.na(Pay)),percent=percent(sum(!is.na(Pay))/nrow(mydata)))

ggplot(mydata, aes(Pay, fill=Department))+geom_histogram(binwidth = 5000)

ggplot(mydata, aes(Pay, fill=Review))+geom_histogram(binwidth = 5000)

ggplot(mydata, aes(Pay, ..count..)) + labs(y = "") + geom_density(position = "fill", aes(fill = Review, colour = Review))
