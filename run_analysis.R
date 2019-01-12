#import files and libraries
library(data.table)
library(dplyr)


#for each data set:
#   read in the data set
#   append the subject id and the activity code
#   add column indicating the data set it is from

activitylabels <- "./data/activity_labels.txt"
activitylabelstable <- fread(activitylabels, col.names = c("activityid", "activitylabel"))


##test set
testdatafile <- "./data/test/X_test.txt"
testdata <- fread(testdatafile) 

testsubjectfile <- "./data/test/subject_test.txt"
testsubject <- fread(testsubjectfile)

testactivityfile <- "./data/test/y_test.txt"
testactivity <- fread(testactivityfile)

#add data from the subject and activity, then add column labeling from test
testdata$subject <- testsubject[1]
testdata$activityid <- testactivity
testdata$set <- "test"


##training
traindatafile <- "./data/train/X_train.txt"
traindata <- fread(traindatafile)

trainsubjectfile <- "./data/train/subject_train.txt"
trainsubject <- fread(trainsubjectfile)

trainactivityfile <- "./data/train/y_train.txt"
trainactivity <- fread(trainactivityfile)

#add data from the subject and activity, then add column labeling from test
traindata$subject <- trainsubject[1]
traindata$activityid <- trainactivity
traindata$set <- "train"


#create new table from the train and test data sets
alldata <- rbind(testdata, traindata)
alldata <- data.frame(alldata)
#add activitylabel

alldata <- left_join(alldata, activitylabelstable)


#remove unneeded tables
rm(testdatafile, 
     testsubjectfile, 
     testsubject, 
     testactivityfile, 
     testactivity, 
     traindatafile, 
     trainsubjectfile,
     trainsubject,
     trainactivityfile,
     trainactivity,
     testdata,
     traindata, 
     activitylabels,
     activitylabelstable)
#use features table to add the the labels to the features
featurestablefile <- "./data/features.txt"
features <- read.table(featurestablefile)
featurenames <- as.character(features$V2)
oldnames <- names(alldata[562:565])
allfeaturesnames <- c(featurenames, oldnames)

#clean up the names
allfeaturesnames <- lapply(allfeaturesnames, function(x){
  a <- gsub("*[^a-zA-z|0-9]*", "", x)
  b <- tolower(a)
  return(b)
  })

#set the for the data columns to the names list we just created.
names(alldata) <- allfeaturesnames
rm(featurestablefile,
   features,
   featurenames, 
   oldnames,
   allfeaturesnames
   )

#dup <- alldata[,duplicated(names(alldata))]


uniquedata <- alldata[,!duplicated(names(alldata))]
meansandstds <- uniquedata %>%
  select(subject, activitylabel,contains("mean"), contains("std"))

meansandstds


#Create second data frame giving mean of each variable for each activity and subject
groupedmeans <- meansandstds %>%
  group_by(activitylabel, subject) %>%
  summarise_all(mean)
 
groupedmeans

