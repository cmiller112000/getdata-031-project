# Coursera - "Getting and Cleaning Data" README.md

By:   Cheryl Miller, cmiller112000@sbcglobal.net
Date: 8/15/2015

# Generated Output Data File:

https://s3.amazonaws.com/coursera-uploads/user-5200f25a9cab0a0a650185b0/975115/asst-3/ca8c6640437d11e58d550517d17fb3f7.txt

# R Libraries Required
Please make sure the following R Packages are installed into your R environment:

* library(httr)
* library(dplyr)
* library(reshape2)

# Run Instructions

1. clone or fork my GITHUB repository from: https://github.com/cmiller112000/getdata-031-project
2. from RStudio or R, run the script: run_analysis.R
3. from the ./data directory, find the output_wide.txt and output_wide.csv output files

# Summary

The purpose of this project is to create a 'tidy' data set from the "Human Activity
Recognition Using Smartphones" dataset, then output a txt data file containing the
mean of the provided mean and standard deviation measurements by testing subject, 
activity and selected measurement.

## Tidy dataset - what is it?

The concept of 'Tidy Data' was discussed in a paper by Hadley Wickham:

http://www.jstatsoft.org/v59/i10/paper 

It is basically a process of cleaning a data set such that it can be used to easily 
"manipulate, model, and visualize" your data.  It is not a full blown data normalization 
process most database modelers may understand.  It is enough 'tidying' to make 
the data usable from an analysis standpoint.  As outlined in the paper above, a
Tidy Data set is one that abides by the following principles:

1. Each variable forms a column
2. Each observation forms a row
3. Each type of observation unit forms a table


## Dataset Background

Human wearable devices, such as the Fit-Bit are big these days.  The authors of 
this data set collected and summarized measurements collected from 30 volunteers
in the 19-48 year age range, wearing a Samsung Galaxy S II smartphone using its
embedded accelerometer and gyroscope.  It was attached to a subject's waist as he
performed 6 activities (standing, sitting, laying, walking, walking upstairs, 
walking downstairs).  This data was aggregated, providing mean and standard 
deviation summaries of numerous acceleration, velocity, magnitude, etc. measurements.
Please see the README.txt and features_info.txt files provided in the source 
dataset for further information on the dataset and the experiments behind them, as
well as a detailed explanation on how the measures were collected and aggregated.

# Required Steps

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Script design/pipeline
<p>
For this project, I automated the process end to end, from downloading the zip file
referenced below, unzipping, cleaning, reshaping and summarizing the required
selected data measures, to creating the output measurement mean summary by subject
and activity.  In addition, I used the final data frame and interim set variables
to automatically generate the data dictionary for the project codebook as well as an
acknowledgement section to include in the project readme file.
</>
<p>
In selecting the measures to include, I followed the instructions to only include
the mean and standard deviation measures.  To identify them, I used a regex
expression to look only for measures with the pattern -mean() or -std() in the name.
While there were other measures with mean in the name (i.e. meanFreq and some angles 
using means), I chose not to use them.  The meanFreq was defined in the features_info.txt 
file as: "Weighted average of the frequency components to obtain a mean frequency".
This is a weighted average and not a mean of a real measurement. Also the other
references dealt with angles using other mean values and not means themselves.
</p>
<p>
In addition to the provided x,y,subject, etc files, there are 'Inertial Signals' 
subdirectories under the train and test subdirectories.  I did not include these
files since the ultimate instructions were to include only the mean and std measures.
They would have been eventually filtered out anyway.
</p>
My process flow was as follows:

1. if the dataset root directory (UCI HAR Dataset) does not exist in the project directory, I create
supporting directories based on R project working directory:
 * downloadDir - ../getdata-031-project-download - zip file downloads and unzips to here
 * dataDir - ./data - output files and generated *.md include files created here
2. download dataset file from source website:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
3. unzip file into non-project level directory (../getdata-031-project-download).
4. read in all the test and training 'x'/'y' data files, as well as the subjects,
features, and activity mapping files. 
 * UCI HAR Dataset/activity_labels.txt
 * UCI HAR Dataset/features.txt
 * UCI HAR Dataset/test
     * subject_test.txt
     * X_test.txt
     * y_test.txt
 * UCI HAR Dataset/train
     * subject_train.txt
     * X_train.txt
     * y_train.txt
5. created descriptive names for the activity performed text - from activity_labels.txt
6. created descriptive column names for all the feature measures - from features.txt
7. combined the all the associated files related to the testing data to create a
combined data frame.  I repeated this with the training data. The purpose in 
combining in this order was to maintain the row number dependencies between the
data files since, with the exception of the activity mapping file, there was no 
'key' data to join them on - from X\_\*.txt , y\_\*.txt , subject\_\*.txt, features.txt
8. Once the testing and training data frames were built, I combined the data from
the testing and training data frames into a single combined data frame
9. renamed the feature columns to have more descriptive names
10. partitioned the data frame to only include the requested '-mean()' and '-std()'
features.
11. replaced the activity id number from the y files with the mapped descriptive
activity name from the activity mapping file.
12. using the dplyr package, created a data.table
13. created a mean summary data frame on the measurements, grouped by subject number
and activity performed.
14. Wrote the resulting data frame to the ./data/output_wide.txt file, I also created
a ./data/output_wide.csv version for those who perfer csv format.

<p>
In addition to tidying and creating a summarized dataset in the steps above, I also
performed the following steps to auto-generate some of the associated documentation.
</p>

1. created a data dictionary from the final output data frame, containing the column
names, data types, and a column description based on the descriptive column names.
2. Wrote this data dictionary to a codebook include file in markdown table syntax.
3. wrote a readme include file containing collected information on the data set(i.e 
download URL, and download date/time), as well as generated acknowledgements from 
the analyzed datasets UCI HAR Dataset/README.txt file.


# Data Reference

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

==================================================================
Human Activity Recognition Using Smartphones Dataset
Version 1.0
==================================================================
Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
Smartlab - Non Linear Complex Systems Laboratory
DITEN - Università degli Studi di Genova.
Via Opera Pia 11A, I-16145, Genoa, Italy.
activityrecognition@smartlab.ws
www.smartlab.ws
==================================================================

# Dataset Source 

* URL: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
* Download Date: Sat Aug 15 13:40:31 2015

# Acknowledgments:

* [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

* Coursera TA - David Hood

 * https://class.coursera.org/getdata-031/forum/thread?thread_id=28

 * and many other posts

* Coursera Student Peers

 * https://class.coursera.org/getdata-031/forum

* Google Search

 * http://www.google.com

* StackOverflow

 * http://www.stackoverflow.com
