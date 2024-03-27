## Residual neural network for binary classification of two fish species from hydroacoustic data.

# Load in the libraries
library(dplyr)
library(tidymodels)
library(vip)
library(keras)
library(rBayesianOptimization)
library(caret)
library(tensorflow)
library(kernelshap)
library(shapviz)
library(str2str)
library(pROC)

# Read in the dataset
raw_data<-readRDS("TSresponse_clean.RDS")

# Data has one row per ping, with the target strength at each 0.5kHz frequency between 45 and 170kHz (except 90 & 90.5). 

# Plot the frequency response for each species, Lake Trout and Smallmouth Bass

# convert to long format to plot
data_long<-gather(raw_data,frequency,TS,F45:F170)
data_long$frequency<-as.numeric(gsub('F','',data_long$frequency))

ggplot(data_long)+
  geom_line(aes(x=frequency,y=TS),alpha=0.1,linewidth=0.5)+
  theme_bw()+
  ylab("Target Strength")+
  facet_wrap(~species)

# For one individual only
data_long%>%
  filter(fishNum=="LT009")%>%
  ggplot()+
  geom_line(aes(x=frequency,y=TS),alpha=0.2,linewidth=0.5)+
  theme_bw()+
  ylab("Target Strength")

data_long%>%
  filter(fishNum=="SMB010")%>%
  ggplot()+
  geom_line(aes(x=frequency,y=TS),alpha=0.2,linewidth=0.5)+
  theme_bw()+
  ylab("Target Strength")

# summarised information
data_long%>%
  group_by(species,frequency)%>%
  summarise(meanTS=mean(TS),upper95=quantile(TS,0.975),lower95=quantile(TS,0.025))%>%
  ggplot()+
  geom_line(aes(x=frequency,y=meanTS,col=species))+
  geom_ribbon(aes(x=frequency,ymin=lower95,ymax=upper95,group=species,fill=species),alpha=0.5)+
  theme_bw()+
  ylab("Target Strength")
  
  
## Split the wide format data into training/validating/testing
set.seed(73)
# first split for training & validating/testing
split<-group_initial_split(raw_data,group=fishNum,strata = species, prop=0.8)
train<-training(split)
val_test<-testing(split)
# second split for validating and testing
split2<-group_initial_split(val_test,group=fishNum,strata = species, prop=0.5)
validate<-training(split2)
test<-testing(split2)

# Look at the number of pings per species in each dataset
train%>%group_by(species)%>%dplyr::count()
validate%>%group_by(species)%>%dplyr::count()
test%>%group_by(species)%>%dplyr::count()

# Select the frequency data, plus region, species and individual length for each dataset. Then, standardise the TS to a fish of length 450mm and transform to acoustic backscatter
train<-train%>%select(F45:F170,Region,species,totalLength)
train[,1:249]<-exp((train[,1:249]+10*log10(450/train$totalLength))/10)

validate<-validate%>%select(F45:F170,Region,species,totalLength)
validate[,1:249]<-exp((validate[,1:249]+10*log10(450/validate$totalLength))/10)

test<-test%>%select(F45:F170,Region,species,totalLength)
test[,1:249]<-exp((test[,1:249]+10*log10(450/test$totalLength))/10)

head(train)
head(validate)
head(test)

# RNNs sre typically used for sequential data or timeseries data. Their input is a sequence of values over time. Our input is going to be a sequence of 5 pings, and the acoustic backscatter value at each frequency (i.e a 5 x 249 matrix).

# Echoview (the software used to process our data) groups temporally and spatially close pings into a fish region. We are going to use these to group our data. 


# Training Data
# Creating a listing variable within each group so that we can split groups longer than 5 into groups of 5
train_grps<-train%>%group_by(Region)%>%mutate(grp=rep(1:ceiling(n()/5), each=5, length.out=n()))%>%ungroup()
head(train_grps)

# splitting into lists 
listgrps_train<-train_grps%>%group_split(Region,grp)

# keeping only lists that are of length 5
listgrps_train<-listgrps_train[sapply(listgrps_train, nrow) >= 5]

# Keeping only the frequency data
listgrps_train2<-map(listgrps_train, ~ (.x %>% select(1:249)))

# each dataframe in the list to a matrix
x_data_train<-lapply(listgrps_train2, as.matrix)

# Flatten into a 3D array
x_data_train<-lm2a(x_data_train,dim.order=c(3,1,2))

# Check dims
dim(x_data_train)


# Selecting the y data
y_data_train<-vector()

for(i in 1:5561){
  a <-listgrps_train[[i]]%>%select(species)
  y_data_train[i]<-a[1,]
}

# Unlist
y_data_train<-unlist(y_data_train)

# Check the number of plings per species
summary(factor(y_data_train))

# Encode as a dummy variable
y_train<-NA
y_train[y_data_train=="LT"]<-0
y_train[y_data_train=="SMB"]<-1
summary(y_train)
dummy_y_train<-to_categorical(y_train, num_classes = 2)
dim(dummy_y_train)

# Nw do the same for the validating and testing datasets.
# Validating Data
# Creating a listing variable within each group so that we can split groups longer than 5 into groups of 5
validate_grps<-validate%>%group_by(Region)%>%mutate(grp=rep(1:ceiling(n()/5), each=5, length.out=n()))%>%ungroup()
head(validate_grps)

# splitting into lists 
listgrps_validate<-validate_grps%>%group_split(Region,grp)

# keeping only lists that are of length 5
listgrps_validate<-listgrps_validate[sapply(listgrps_validate, nrow) >= 5]

# Keep only frequncy data
listgrps_validate2<-map(listgrps_validate, ~ (.x %>% select(1:249)))

# each dataframe in the list to a matrix
x_data_validate<-lapply(listgrps_validate2, as.matrix)

# Flatten into a 3D array
x_data_validate<-lm2a(x_data_validate,dim.order=c(3,1,2))

# Check dims
dim(x_data_validate)

# Selecting the y data
y_data_validate<-vector()

for(i in 1:641){
  a <-listgrps_validate[[i]]%>%select(species)
  y_data_validate[i]<-a[1,]
}

# Unlist
y_data_validate<-unlist(y_data_validate)

# Check the number of pings per species
summary(factor(y_data_validate)) 

# create dummy variable
y_validate<-NA
y_validate[y_data_validate=="LT"]<-0
y_validate[y_data_validate=="SMB"]<-1
summary(y_validate)
dummy_y_validate<-to_categorical(y_validate, num_classes = 2)
dim(dummy_y_validate)

# Testing Data

# Creating a listing variable within each group so that we can split groups longer than 5 into groups of 5
test_grps<-test%>%group_by(Region)%>%mutate(grp=rep(1:ceiling(n()/5), each=5, length.out=n()))%>%ungroup()
head(test_grps)

# splitting into lists 
listgrps_test<-test_grps%>%group_split(Region,grp)

# keeping only lists that are of length 5
listgrps_test<-listgrps_test[sapply(listgrps_test, nrow) >= 5]

# keep only frequency data
listgrps_test2<-map(listgrps_test, ~ (.x %>% select(1:249)))

# each dataframe in the list to a matrix
x_data_test<-lapply(listgrps_test2, as.matrix)

# Flatten into a 3D array
x_data_test<-lm2a(x_data_test,dim.order=c(3,1,2))

# Check dims
dim(x_data_test)

# Selecting the y data
y_data_test<-vector()

for(i in 1:707){
  a <-listgrps_test[[i]]%>%select(species)
  y_data_test[i]<-a[1,]
}

# Unlist
y_data_test<-unlist(y_data_test)

# check the number of pings per species
summary(factor(y_data_test)) 

# Create dummy variable
y_test<-NA
y_test[y_data_test=="LT"]<-0
y_test[y_data_test=="SMB"]<-1
summary(y_test)
dummy_y_test<-to_categorical(y_test, num_classes = 2)
dim(dummy_y_test)

# Finally, we need to shuffle the training and validating datasets
set.seed(250)
x<-sample(1:nrow(x_data_train))
x_data_train_S= x_data_train[x,, ] 
dummy_y_train_S= dummy_y_train[x, ] 

set.seed(250)
x<-sample(1:nrow(x_data_validate))
x_data_validate_S= x_data_validate[x,, ] 
dummy_y_validate_S= dummy_y_validate[x, ] 


# Fit the RNN. Currently, there is no cross validation implemented. 

set_random_seed(15)
rnn = keras_model_sequential() 
rnn %>%
  layer_lstm(input_shape=c(5,249),units = 249) %>%
  layer_activation_leaky_relu()%>%
  layer_batch_normalization()%>%
  layer_dense(units=150,activity_regularizer = regularizer_l2(1e-4))%>%
  layer_activation_leaky_relu()%>%
  layer_dense(units=75,activity_regularizer = regularizer_l2(1e-4))%>%
  layer_activation_leaky_relu()%>%
  layer_dense(units=38,activity_regularizer = regularizer_l2(1e-4))%>%
  layer_activation_leaky_relu()%>%
  layer_dense(units=19,activity_regularizer = regularizer_l2(1e-4))%>%
  layer_activation_leaky_relu()%>%
  layer_dense(units = 2, activation = 'sigmoid')


# look at our model architecture
summary(rnn)

#compile the model
rnn %>% compile(
  loss = loss_binary_crossentropy,
  optimizer = optimizer_adam(3e-4),
  metrics = c('accuracy')
)

# train the model
history <- rnn %>% fit(
  x_data_train_S, dummy_y_train_S,
  batch_size = 500, 
  epochs = 38,
  validation_data = list(x_data_validate_S,dummy_y_validate_S),
  class_weight = list("0"=1,"1"=2))

plot(history)

# evaluate performance on test data
evaluate(rnn, x_data_test, dummy_y_test) 

# extract test data classifications
preds<-predict(rnn, x=x_data_test)

species.predictions<-apply(preds,1,which.max)
species.predictions<-as.factor(ifelse(species.predictions == 1, "LT",
                                      "SMB"))
confusionMatrix(species.predictions,as.factor(y_data_test))

