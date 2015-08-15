# Coursera "Getting and Cleaning Data" Project
#
# Author:
#     Cheryl Miller
#     8/15/15
#
# Data Source: 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#
# Data Definition: 
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
# Script:
#   run_analysis.R
#
# Steps:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each
#     measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
#     with the average of each variable for each activity and each subject.
#
#
# load required libraries
#
library(httr)
library(dplyr)
library(reshape2)
#
# Create data download directory outside of project directory so we don't include
# in GIT repository
#
downloadDir = "../getdata-031-project-download"
if (!file.exists(downloadDir)) {
  dir.create(downloadDir);
}

#
# download zip file, and record the download date.  if file exists already
# pick up creation date of zip file
#
localzipfile = paste(downloadDir,"getdata_projectfiles.zip",sep="/")
#
downloadUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists(localzipfile)) {
  download.file(downloadUrl,
                destfile=localzipfile,mode="wb")
  downloadDate = date()
  downloadDate
} else {
  downloadDate = file.info(localzipfile)$mtime
}
#
# unzip the downloaded zip file
#
inputDirRoot = paste(downloadDir,"UCI HAR Dataset",sep="/")
#
if (file.exists(localzipfile) ) {
  if (!file.exists(inputDirRoot)) {
    unzip(localzipfile,overwrite = TRUE,exdir=downloadDir)
  }
} else {
  stop("Cannot find unzip data directory")
}
#
# setup variable reference to root input data directory from zip file
# also create our output data directory to hold final output files
# these will be included in the GIT repository
#
dataDir = "./data"
if (!file.exists(dataDir)) {
  dir.create(dataDir);
}

#
# read testing  and training data files
#
# x files contain the measurements
# y files contain the id number of the activity recorded as defined in the
# activity file
# subj contains the id numbers of the subject performing the activity
#
x_test <- read.table(paste(inputDirRoot,"test/x_test.txt",sep="/"),stringsAsFactors = FALSE)
x_train <- read.table(paste(inputDirRoot,"train/x_train.txt",sep="/"),stringsAsFactors = FALSE)
y_train <- read.table(paste(inputDirRoot,"train/y_train.txt",sep="/"),stringsAsFactors = FALSE)
y_test <- read.table(paste(inputDirRoot,"test/y_test.txt",sep="/"),stringsAsFactors = FALSE)
subj_test <- read.table(paste(inputDirRoot,"test/subject_test.txt",sep="/"),stringsAsFactors = FALSE)
subj_train <- read.table(paste(inputDirRoot,"train/subject_train.txt",sep="/"),stringsAsFactors = FALSE)

# read in the support files:
# activity_labels contains the activity id to text activity performed mapping
# features contains the names of each measurement recorded in the x file
#
# each line in the x,y,subj, and features files are associated with each other by
# line number
#
activity <- read.table(paste0(inputDirRoot,"/activity_labels.txt"),stringsAsFactors = FALSE)
colnames(activity) = c("activityid","activityname")
activity$activityname <- gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", tolower(gsub('_',' ',activity$activityname)), perl=TRUE)

#
# merge test data into a single data frame by row number
#
full_data_test <- merge(subj_test,y_test,by="row.names")
full_data_test <- merge(full_data_test,x_test,by="row.names")

# read in the feature names and make description variable names from them

varnames <- read.table(paste(inputDirRoot,"features.txt",sep="/"),stringsAsFactors = FALSE)
colnames(varnames) <- c("measureid","measurename")
varnames$measuredescname <- sub("^t","time_",
                                sub("^f","frequency_",
                                    gsub("body","body_",
                                         sub("jerk","jerk_",
                                             gsub("gravity","gravity_",
                                                  sub("gyro","gyroscope_",
                                                      sub("acc","acceleration_",
                                                          sub("mag","magnitude_",
                                                              sub("-(x|y|z)$","_\\1_direction",
                                                                  tolower(varnames$measurename))))))))))

# then set the column names in the x_test data frame for later use in 
# combining all this together.  make a list of the measure column names we
# want to keep ( those matching the string 'mean() or std() - project
# requirements are to include the mean and standard deviation feature only)
#
colnames(x_test) <- varnames$measuredescname
keep_cols <- colnames(x_test[grepl("mean\\(\\)|std\\(\\)",colnames(x_test))])

# now merge the training data set as well
full_data_train <- merge(subj_train,y_train,by="row.names")
full_data_train <- merge(full_data_train,x_train,by="row.names")

#
# now that all the line number associations have been made, create a single
# data set with both the training and testing data sets
# this creates duplicate 'row.names' columns that we need to then remove
# finally assign descriptive column names to the combined dataset, including
# the descriptive colunm names we generated and assigned to the x_test
# data frame

full_data <- rbind(full_data_train,full_data_test)
full_data[1] <- NULL
full_data[1] <- NULL
colnames(full_data) <- c("subject_performing_action","activity_performed",colnames(x_test))

# clean up all the interim variables we no longer need
#
x_train <- NULL
x_test <- NULL
y_train <- NULL
y_test <- NULL
subj_train <- NULL
subj_test <- NULL
x <- NULL
y <- NULL
subj <- NULL
varnames <- NULL

# now create a data frame with only the mean and std features as required
# then do the final clean up of the column names to clean up the mean and std
# strings.
# finally, translate the activity id numbers to the descriptive text based ones
# in the activity data frame

part_data <- full_data[,c("subject_performing_action","activity_performed",keep_cols)]
colnames(part_data) <- sub("-mean\\(\\)","mean",sub("-std\\(\\)","std",colnames(part_data)))
part_data$activity_performed <- activity$activityname[part_data$activity_performed]

# burther cleanup of items we don't need any longer
full_data <- NULL
keep_cols <- NULL

# 
# now take the final generated data frame and create the final data set we
# need to summarize by subject, activity and feature, generating the group mean
#
# create a data.table
d1_tbl <- tbl_df(part_data)
#
# now generate the mean for each measure, grouping by subject and activity
# and finally write it the to final output file (and in csv format, some like
# it better (me))
#
d1_tbl_mean <- (d1_tbl %>% group_by(subject_performing_action, activity_performed) %>% summarise_each(funs(mean)))
write.table(d1_tbl_mean, paste(dataDir,"output_wide.dat",sep="/"), quote = FALSE, row.names = FALSE, col.names = TRUE)
write.table(d1_tbl_mean, paste(dataDir,"output_wide.csv",sep="/"), quote = FALSE, row.names = FALSE, col.names = TRUE,sep=",")

# the following code is primarily for the author to auto-generate some required information
# for the codebook and readme files.

# generate a data dictionary of the final output data file, by pulling information 
# from the data table that generated the output, including the column names,
# data types, and a column description by parsing the descriptive measurement
# names.
d1_dict <- data.frame(colnames(d1_tbl),sapply(d1_tbl,typeof),
                    gsub("(\\b[a-z]{1})", "\\U\\1" ,
                      gsub('_',' ',
                           sub("^(time|frequency)","\\1 domain signal for the",
                              sub("(x|y|z)_direction","in the \\1 direction",
                                  sub("std","standard deviation",
                                  colnames(d1_tbl))))), perl=TRUE))

# now add column names to the data dictionary, forcing the last column to include a second underline
# line and formated to generate a table in the markdown syntax
# Then write the generated codebook section to be included into the project's
# final codebook.

colnames(d1_dict) <- c("AttributeName","DataType","Description\n------------- | -------- | -----------")
write.table(d1_dict, paste(dataDir,"codebook_basis.md",sep="/"), quote = FALSE, row.names = FALSE, col.names = TRUE, sep =" | ")

# now generate a readme section in markdown list syntax to include download and
# date information from the data set analyzed and include acknowledgement text 
# required from the dataset readme file as well as some hardcoded acknowlegdements 
# from the class posts and google searches that aided me in completing the assigment.
#
# Yes, I know this latter is an overkill, but what the hey....   Part of the
# purpose of this project is to learn how to use R, so I consider it worthwhile.

sourcereadme <- readLines(paste(inputDirRoot,"README.txt",sep="/"), n = -1)
ack <- sourcereadme[grep("^\\[\\d+\\]",sourcereadme)]

readme <- paste0("# Dataset Source ","\n\n* URL: ",downloadUrl,"\n* Download Date: ",downloadDate,
                "\n\n# Acknowledgments:\n\n* ",ack,
                "\n\n* Coursera TA - David Hood\n\n * ","https://class.coursera.org/getdata-031/forum/thread?thread_id=28","\n\n * and many other posts",
                "\n\n* Coursera Student Peers\n\n * ","https://class.coursera.org/getdata-031/forum",
                "\n\n* Google Search\n\n * ","http://www.google.com",
                "\n\n* StackOverflow\n\n * ","http://www.stackoverflow.com")
write.table(readme, paste(dataDir,"readme_basis.md",sep="/"), quote = FALSE, row.names = FALSE, col.names = FALSE)
