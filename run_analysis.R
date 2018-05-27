setwd('C:/Users/sankalp/Documents/Coursera/Getting & Cleaning Data/Week 4/project/UCI HAR Dataset');

features <- read.table('./features.txt',header=FALSE);
activityLabels <- read.table('./activity_labels.txt',header=FALSE); 
colnames(activityLabels) <- c("activityId","activityType");
subjectTrain <- read.table('./train/subject_train.txt',header=FALSE); 
colnames(subjectTrain) <- "subjectId";
xTrain <- read.table('./train/x_train.txt',header=FALSE); colnames(xTrain) <- 
  features[,2];
yTrain <- read.table('./train/y_train.txt',header=FALSE); colnames(yTrain) <- 
  "activityId";


trainingSet = cbind(yTrain,subjectTrain,xTrain);


subjectTest <- read.table('./test/subject_test.txt',header=FALSE); 
colnames(subjectTest) <- "subjectId";
xTest <- read.table('./test/x_test.txt',header=FALSE); colnames(xTest) <- 
  features[,2];
yTest <- read.table('./test/y_test.txt',header=FALSE); colnames(yTest) <- 
  "activityId";

testSet = cbind(yTest,subjectTest,xTest);

MergedDataSet = rbind(trainingSet,testSet);


columns <- colnames(MergedDataSet);

vector <- (grepl("activity..",columns) | grepl("subject..",columns) | grepl("-mean..",columns) &
             !grepl("-meanFreq..",columns) & !grepl("mean..-",columns) | 
             grepl("-std..",columns) & !grepl("-std()..-",columns));

MergedDataSet <- MergedDataSet[vector==TRUE];

MergedDataSet <- merge(MergedDataSet,activityLabels,by='activityId',all.x=TRUE);
MergedDataSet$activityId <-activityLabels[,2][match(MergedDataSet$activityId, activityLabels[,1])] 


columns <- colnames(MergedDataSet);


for (i in 1:length(columns)) 
{
  columns[i] <- gsub("\\()","",columns[i])
  columns[i] <- gsub("-std$","StdDev",columns[i])
  columns[i] <- gsub("-mean","Mean",columns[i])
  columns[i] <- gsub("^(t)","time",columns[i])
  columns[i] <- gsub("^(f)","freq",columns[i])
  columns[i] <- gsub("([Gg]ravity)","Gravity",columns[i])
  columns[i] <- gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",columns[i])
  columns[i] <- gsub("[Gg]yro","Gyro",columns[i])
  columns[i] <- gsub("AccMag","AccMagnitude",columns[i])
  columns[i] <- gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",columns[i])
  columns[i] <- gsub("JerkMag","JerkMagnitude",columns[i])
  columns[i] <- gsub("GyroMag","GyroMagnitude",columns[i])
};


# Update MergedDataSet with new descriptive column names
colnames(MergedDataSet) <- columns;

# Remove activityType column
MergedDataSet <- MergedDataSet[,names(MergedDataSet) != 'activityType'];

###### 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Averaging each activity and each subject as Tidy Data
tidyData <- aggregate(MergedDataSet[,names(MergedDataSet) 
                                    != c('activityId','subjectId')],by=list
                      (activityId=MergedDataSet$activityId,
                        subjectId=MergedDataSet$subjectId),mean);

# Export tidyData set 
write.table(tidyData, './FinalTidyData.txt',row.names=FALSE,sep='\t')
