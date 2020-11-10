library(tidyverse)
library(dplyr)
library(caret)
library(glmnet)

training_model_data = "/scratch/tphung3/SexInference/RNAseq/for_rna_sex_check.tsv"
experiment_data = "/scratch/tphung3/SexInference/RNAseq/data_for_regression.csv"

# -----------------------------------
# Build the model using the GTEx data
# -----------------------------------
# Load the data and remove NAs
data = read.csv(training_model_data, sep="\t")

# Split the data into training and test set
set.seed(123)
training.samples <- data$sex %>% 
  createDataPartition(p = 0.8, list = FALSE)
train.data  <- data[training.samples, ]
test.data <- data[-training.samples, ]

# Dumy code categorical predictor variables
x <- model.matrix(sex~., train.data)[,-1]
# Convert the outcome (class) to a numerical variable
y <- ifelse(train.data$sex == "female", 1, 0)

cv.lasso <- cv.glmnet(x, y, alpha = 1, family = "binomial")
plot(cv.lasso)
cv.lasso$lambda.min

coef(cv.lasso, cv.lasso$lambda.min)
coef(cv.lasso, cv.lasso$lambda.1se)

# Final model with lambda.min
lasso.model <- glmnet(x, y, alpha = 1, family = "binomial",
                      lambda = cv.lasso$lambda.min)
# Make prediction on test data
x.test <- model.matrix(sex ~., test.data)[,-1]
probabilities <- lasso.model %>% predict(newx = x.test)
predicted.classes <- ifelse(probabilities > 0.5, "female", "male")
# Model accuracy
observed.classes <- test.data$sex
mean(predicted.classes == observed.classes)

# ----------------------
# Run on experiment data
# ----------------------
experiment_data = read.csv(experiment_data)

# Make prediction on placenta data
x.experiment <- model.matrix(sex ~., experiment_data)[,-1]
probabilities <- lasso.model %>% predict(newx = x.experiment)
predicted.classes <- ifelse(probabilities > 0.5, "female", "male")
# Model accuracy
observed.classes <- experiment_data$sex
mean(predicted.classes == observed.classes)

df = cbind(as.data.frame(predicted.classes)$s0, experiment_data$sex)
# cor.test(df[,1], df[,2])

which(df[,1]!=df[,2])
