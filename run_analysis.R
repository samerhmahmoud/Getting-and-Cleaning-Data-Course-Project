## Here are the data for the project:
## change the working directory below if you needed  
setwd("~/Desktop/Project_GettingandCleaningData")

  purl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  
  destfile<-"prdtfl.zip"
  download.file(purl,destfile,method = "curl")

  
  unzip(destfile)
  
 
 library(tidyverse)
 library(dplyr)
 library(readr)
 library(dtplyr)
 
 ## set path for data  this keeps the data path as it was extracted from the 
 ## link above and when the data was unzipped it goes into the correct folder
 ## thlink below extracts the data correctly.  if the path changes then the paths
## can be changed chanages to tstpat, trnpat, and pat variables myay be needed  
  
 pat<-"./UCI HAR Dataset/"
 
 ## read activity labels and process to a vector 
 actL<-read_tsv(paste(pat,"activity_labels.txt",sep=""),col_names = FALSE)
 actL<-gsub("^[[:digit:]] ","",as.matrix(actL))
 
 # read features and process to remove numbers
 ftr<-read_tsv(paste(pat,"features.txt",sep=""),col_names = FALSE)
 ftr<-as.matrix(ftr)
 ftr<-gsub("^[[:digit:]]+","",ftr)
 ftr<-gsub("^[[:space:]]+","",ftr)
 
 # test data path
  
 tstpat<-paste(pat,"test/",sep = "")
 
 # read with fwf
  clp<-fwf_empty(paste(tstpat,"X_test.txt",sep=""))
  tstX<-read_fwf(paste(tstpat,"X_test.txt",sep=""),clp)
  tstX<-mutate(tstX,Set="train")
  tsty<-read_tsv(paste(tstpat,"y_test.txt",sep=""),col_names = FALSE)
  tstS<-read_tsv(paste(tstpat,"subject_test.txt",sep=""),col_names = FALSE)
  
  
  # training data path 
  trnpat<-paste(pat,"train/",sep = "")
  # read with fwf
  
  clp<-fwf_empty(paste(trnpat,"X_train.txt",sep=""))
  trnX<-read_fwf(paste(trnpat,"X_train.txt",sep=""),clp)
  trnX<-mutate(trnX,Set="train")
  trny<-read_tsv(paste(trnpat,"y_train.txt",sep=""),col_names = FALSE)
  trnS<-read_tsv(paste(trnpat,"subject_train.txt",sep=""),col_names = FALSE)
  
  # merge dat sets for X 
  datX<- merge(trnX,tstX,all=TRUE)
## set names
  colnames(datX)<-append(ftr,"Set")
## select colnames with mean and std only   
  meancol<-grepl("mean",colnames(datX),ignore.case = TRUE)
  stdcol<-grepl("std",colnames(datX),ignore.case = TRUE)
  setcol<-grepl("Set",colnames(datX))
  
  datX<-datX[,stdcol | meancol ]  ## select only certnain columns
  
  # merge dat sets for  y and S
  daty<- append(as.matrix(trny),as.matrix(tsty)) ## merge activities 1:6
  datS<- append(as.matrix(trnS),as.matrix(tstS)) ## merge subject
  
  datX<-mutate(datX,Subject=datS,Activity=daty)
  
  datX<-mutate(datX,Activity=actL[Activity,])  # change activity labels to text label
  
 
  
  
 ## for step 5
  tidy_data <-datX %>%
    group_by(Activity,Subject) %>%
    summarise_all(mean)
 
 
  write.table(tidy_data,"samsung_dat.out" ,row.name=FALSE)   
  
 