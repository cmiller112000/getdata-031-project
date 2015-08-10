# Coursera "Getting and Cleaning Data" Project
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
#
# Create data directory
#
downloadDir = "../getdata-031-project-download"
if (!file.exists(downloadDir)) {
  dir.create(downloadDir);
}

#
# download zip file
#
localzipfile = paste(downloadDir,"getdata_projectfiles.zip",sep="/")
#
if (!file.exists(localzipfile)) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                destfile=localzipfile,mode="wb")
  dateDownloaded = date()
  dateDownloaded
} else {
  dateDownloaded = file.info(localzipfile)$mtime
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
#
workDir = "../getdata-031-work"
if (!file.exists(workDir)) {
  dir.create(workDir);
}
dataDir = "./data"
if (!file.exists(dataDir)) {
  dir.create(dataDir);
}
