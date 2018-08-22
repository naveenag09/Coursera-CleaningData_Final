## Initialise required packages

library(dplyr)
library(tidyverse)
library(data.table)
library(readxl)

filename <- "getdata_dataset.zip"

## Download zip data 
  filelocation <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(filelocation, filename, method="curl")

## extract file from zip files    
  unzip(filename) 
 
  ## Onboard activity labels file
  activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")
  activitylabels[,2] <- as.character(activitylabels[,2])
  
  ## Onboard features file
  features <- read.table("UCI HAR Dataset/features.txt")
  features[,2] <- as.character(features[,2])
  
  # Determine variables which need to be extrated  
  required_features <- grep(".*mean.*|.*std.*", features[,2])
  required_features_names <- features[required_features,2]
  required_features_names = gsub('-mean', 'Mean', required_features_names)
  required_features_names = gsub('-std', 'Std', required_features_names)
  required_features_names <- gsub('[-()]', '', required_features_names)
  
   
#1. Merges the training and the test sets to create one data set.
  {
  ## Load test and train dataset and combine
  train <- read.table("UCI HAR Dataset/train/X_train.txt")
  train <-train[required_features]
  train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
  train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
  train_combined <- bind_cols(train_subjects,train_activities,train)
  
  test <- read.table("UCI HAR Dataset/test/X_test.txt")
  test <- test[required_features]
  test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
  test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
  test_combined <- bind_cols(test_subjects,test_activities,test)
  
  ## Combine test and train and rename columns
  combined_data <- bind_rows(train_combined, test_combined)
  colnames(combined_data) <- c("subject", "activity", required_features_names)
  }
  
  ## convert activities & subjects into factors
  combined_data$activity <- factor(combined_data$activity, levels = activitylabels[,1], 
                                   labels = activitylabels[,2])
  combined_data$subject <- as.factor(combined_data$subject)
  
  combined_data_melted <- melt(combined_data, id = c("subject", "activity"))
  combined_data_mean <- dcast(combined_data_melted, subject + activity ~ variable, mean)
  
  write.table(combined_data_mean, "tidy.txt", quote = FALSE,row.names = FALSE)  