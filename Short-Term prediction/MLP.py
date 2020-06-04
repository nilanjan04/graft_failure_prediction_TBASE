# =============================================================================
# Please uncomment and execure the following to install the packages below before execution
# =============================================================================

#!pip install imblearn --proxy=https://user@proxy.charite.de:8080
#!pip install numpy --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas_summary --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install --user --upgrade tensorflow --proxy=https://user@proxy.charite.de:8080
#!pip install Keras --proxy=https://user@proxy.charite.de:8080

# =============================================================================
# If the above installation for TensorFlow and Keras does not work then:
# Follow the URL (extracted on: 15/05/2020) for TensorFlow installation
# https://www.tensorflow.org/install/pip
# 
# Requires Python 3.5–3.7 and pip >= 19.0
# Check your python, pip and virtualevn versions from the following:
# !python --version
# !pip --version
# 
# =============================================================================

# =============================================================================
# please restart the kernel after installing the above packages if you are using Spyder (Anaconda)
# =============================================================================


import pandas as pd
import numpy as np
import sklearn

# =============================================================================
# #Importing the dataset TBASE
# =============================================================================
# PLease provide a csv file with destination below
temp_features = pd.read_csv(r'', sep=',')


# =============================================================================
# #Removing Other Label
# =============================================================================
temp_features.drop(['Longterm_TransplantOutcome'], axis = 1, inplace = True)
#temp_features.drop(['Shortterm_TransplantOutcome'], axis = 1, inplace = True)
temp_features.drop(['Shortterm_TransplantOutcome_12months'], axis = 1, inplace = True)


# =============================================================================
# #Remove constant features - uncomment if desired
# =============================================================================
#for index, row in df_summary.columns_stats.transpose()[df_summary.columns_stats.transpose()['types'].str.lower().str.contains('constant')].iterrows():
#    print('Removed column ' + index + ' (constant)')
#    temp_features.drop([index], axis = 1, inplace = True)
#
#print('The shape of our features is:', temp_features.shape)
#temp_features.describe()


# =============================================================================
# Removing all columns that are completely empty
# =============================================================================
temp_features.dropna(axis =1, how="all", inplace = True)
feature_list = list(temp_features.columns)


# =============================================================================
# #Split labels  from temp_features
# =============================================================================
temp_labels = np.array(temp_features['Shortterm_TransplantOutcome'])
temp_features= temp_features.drop('Shortterm_TransplantOutcome', axis = 1)

#temp_labels = np.array(temp_features['Shortterm_TransplantOutcome_12months'])
#temp_features= temp_features.drop('Shortterm_TransplantOutcome_12months', axis = 1)


# =============================================================================
# #One-Hot-Encoding
# =============================================================================
temp_features = pd.get_dummies(temp_features)

feature_list = list(temp_features.columns)

# =============================================================================
# #Keep TransplantationID in test data for error analysis
# =============================================================================
temp_features_transplantationIDs = np.array(pd.DataFrame(temp_features, columns=feature_list)['TransplantationID'])
temp_features_patientIDs = np.array(pd.DataFrame(temp_features, columns=feature_list)['PatientID'])

# =============================================================================
# #Normalisation
# =============================================================================
from sklearn import preprocessing
temp_features = temp_features.iloc[:, 2:].values #returns a numpy array
min_max_scaler = preprocessing.MinMaxScaler()
x_scaled = min_max_scaler.fit_transform(temp_features)
temp_features = pd.DataFrame(x_scaled, columns=feature_list[2:])

temp_features = temp_features.join(pd.DataFrame(temp_features_transplantationIDs, columns=['TransplantationID'])).join(pd.DataFrame(temp_features_patientIDs, columns=['PatientID']))
feature_list = feature_list[2:]
feature_list.append('TransplantationID')
feature_list.append('PatientID')

temp_features = np.array(temp_features)


# =============================================================================
# #Spliting datasets into train and test sets
# =============================================================================
from sklearn.model_selection import train_test_split
train_features, test_features, train_labels, test_labels = train_test_split(temp_features, temp_labels, test_size = 0.25, random_state = 42)
print('Training Features Shape:', train_features.shape)
print('Training Labels Shape:', train_labels.shape)
print('Testing Features Shape:', test_features.shape)
print('Testing Labels Shape:', test_labels.shape)

#Count number of 1 and 0 class labels in test set
from collections import Counter
x = train_labels
Counter(x)
y = test_labels
Counter(y)
# =============================================================================
# #Imputation 
# =============================================================================
from sklearn.experimental import enable_iterative_imputer  
from sklearn.impute import IterativeImputer
imp = IterativeImputer(random_state=0, max_iter = 100, imputation_order='random')
imp.fit(train_features)
train_features = imp.transform(train_features)
test_features = imp.transform(test_features)

# =============================================================================
# #Keep TransplantationID in test data for error analysis later
# =============================================================================
test_features = pd.DataFrame(test_features, columns=feature_list)
train_features = pd.DataFrame(train_features, columns=feature_list)

test_features_transplantationIDs = np.array(test_features['TransplantationID'])
test_features.drop(['TransplantationID'], axis = 1, inplace = True)
train_features.drop(['TransplantationID'], axis = 1, inplace = True)
feature_list.remove('TransplantationID')

test_features_patientIDs = np.array(test_features['PatientID'])
test_features.drop(['PatientID'], axis = 1, inplace = True)
train_features.drop(['PatientID'], axis = 1, inplace = True)
feature_list.remove('PatientID')


# =============================================================================
# #SMOTE for upsampling
# =============================================================================
from collections import Counter
from imblearn.over_sampling import SMOTE
#print(sorted(Counter(train_labels).items()))
train_features, train_labels = SMOTE().fit_resample(train_features, train_labels)
print(sorted(Counter(train_labels).items()))

#Oversampling the test set - uncomment if desired
#test_features, test_labels = SMOTE().fit_resample(test_features, test_labels)
#print(sorted(Counter(train_labels).items()))

print(train_features.shape)
print(train_labels.shape)
print(test_features.shape)
print(test_labels.shape)


# =============================================================================
# Dimensionalty reduction using Principal Component Analysis
# =============================================================================

from sklearn.decomposition import PCA
#You can also check the analysis using None as a parameter
#pca = PCA(n_components = None)
pca = PCA(n_components = 168)
train_features = pd.DataFrame(pca.fit_transform(train_features))
test_features = pd.DataFrame(pca.transform(test_features))
explained_variance = pca.explained_variance_ratio_

pca_stats = pd.DataFrame(explained_variance)
df_feature_list = pd.DataFrame(feature_list, columns= ['feature'] )
pca_stats = pca_stats.join(df_feature_list)
#Please change the path accordingly
pca_stats.to_csv(r'T:\tbase\short_ff\pca_stats.csv')


# =============================================================================
# Considering only 80% of training dataset for training the model - uncomment if desired
# =============================================================================
#train_features = train_features[:3086]
#train_labels = train_labels[:3086]
#print(train_features.shape)
#print(train_labels.shape)

# =============================================================================
# Considering only 60% of training dataset for training the model - uncomment if desired
# =============================================================================
#train_features = train_features[:2314]
#train_labels = train_labels[:2314]
#print(train_features.shape)
#print(train_labels.shape)

# =============================================================================
# Considering only 40% of training dataset for training the model - uncomment if desired
# =============================================================================
#train_features = train_features[:1543]
#train_labels = train_labels[:1543]
#print(train_features.shape)
#print(train_labels.shape)

# =============================================================================
# Considering only 20% of training dataset for training the model - uncomment if desired
# =============================================================================
#train_features = train_features[:771]
#train_labels = train_labels[:771]
#print(train_features.shape)
#print(train_labels.shape)

#Setting number of input and hidden nodes in MLP
import math
units = math.ceil(len(train_features.columns)/2)
input_dim = len(train_features.columns)

# =============================================================================
# Multilayer perceptron
# =============================================================================
import keras
from keras.models import Sequential
from keras.layers import Dense

# Initialising the ANN
classifier_ff = Sequential()

# Adding the input layer and the first hidden layer
#Activation function for hidden layers: Rectifier Activation Function
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign', input_dim = input_dim))

# Adding the 2nd hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))

# Adding the 3rd hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))

# Adding the 4th hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))

# Adding the 5th hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))

##=============================================================================
# Adding the 6th hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))
 
# Adding the 7th hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))
 
# Adding the 8th hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))
 
# Adding the 9th hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))
 
# Adding the 10th hidden layer
classifier_ff.add(Dense(units = units, kernel_initializer = 'glorot_normal', activation = 'softsign'))

#=============================================================================
# Adding the output layer
#Activation function for output layer: Sigmoid Activation Function
classifier_ff.add(Dense(units = 1, kernel_initializer = 'glorot_normal', activation = 'sigmoid'))

# Compiling the ANN
#optimizer: Stochastic Gradient Descent for modifying weights
#loss function: Logarithmic loss
classifier_ff.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = [keras.metrics.Precision()])
classifier_ff.summary()


#Adding weights to deal with class imbalance
weights = {0:1, 1:5}
# Fitting the ANN to the Training set
history = classifier_ff.fit(train_features, train_labels, class_weight=weights, batch_size = 1, epochs = 10)


#Class prediction:
prediction = classifier_ff.predict_classes(test_features)
#df_predictions_class = pd.DataFrame(prediction, columns= ['prediction_class']) 
#df_predictions_class.to_csv(r'T:\tbase\short_ff\prediction_class.csv')


df_predictions = pd.DataFrame(prediction, columns=['prediction']) 
df_labels = pd.DataFrame(test_labels, columns=['label'])
#df_labels.to_csv(r'T:\tbase\short_ff\prediction_labels.csv')

## =============================================================================
## #Qualitative error analysis
df_error_analysis = df_predictions.join(df_labels).join(pd.DataFrame(test_features_transplantationIDs, columns=['TransplantationID'])).join(pd.DataFrame(test_features_patientIDs, columns=['PatientID']))
#Please change the path accordingly
df_error_analysis.to_csv(r'T:\tbase\short_ff\Qualitative_res.csv')

# =============================================================================


#Results

#Plotting the error rate convergence graph
import matplotlib.pyplot as plt
plt.plot(history.history['loss'])
plt.show()
# =============================================================================
# #Confusion matrix
# =============================================================================
from sklearn.metrics import confusion_matrix
conf_mat = confusion_matrix(df_labels, df_predictions)
print(conf_mat)
import seaborn
seaborn.heatmap(conf_mat)

from sklearn.metrics import confusion_matrix

def print_cm(cm, labels1, hide_zeroes=False, hide_diagonal=False, hide_threshold=None):
    """pretty print for confusion matrixes"""
    columnwidth = 6  # 5 is value length
    empty_cell = " " * columnwidth
    # Print header
    print("    " + empty_cell, end=" ")
    for label in labels1:
        print("%{0}s".format(columnwidth) % label, end=" ")
    print()
    # Print rows
    for i, label1 in enumerate(labels1):
        print("    %{0}s".format(columnwidth) % label1, end=" ")
        for j in range(len(labels1)):
            cell = "%{0}.1f".format(columnwidth) % cm[i, j]
            if hide_zeroes:
                cell = cell if float(cm[i, j]) != 0 else empty_cell
            if hide_diagonal:
                cell = cell if i != j else empty_cell
            if hide_threshold:
                cell = cell if cm[i, j] > hide_threshold else empty_cell
            print(cell, end=" ")
        print()

labels = [1,0 ]
cm = confusion_matrix(df_predictions, df_labels, labels)
print_cm(cm, labels)



# =============================================================================
# #Precision, Recall, F1-Score
# =============================================================================
print(sklearn.metrics.classification_report(df_labels, df_predictions, labels=None, target_names=None, sample_weight=None, digits=2, output_dict=False, zero_division='warn'))

# =============================================================================
# #ROC curve
# =============================================================================
import sklearn.metrics as metrics
fpr, tpr, threshold = metrics.roc_curve(df_labels,  df_predictions)
roc_auc = metrics.auc(fpr, tpr)
import matplotlib.pyplot as plt
plt.title('Receiver Operating Characteristic')
plt.plot(fpr, tpr, 'b', label = 'AUC = %0.2f' % roc_auc)
plt.legend(loc = 'lower right')
plt.plot([0, 1], [0, 1],'r--')
plt.xlim([0, 1])
plt.ylim([0, 1])
plt.ylabel('True Positive Rate')
plt.xlabel('False Positive Rate')
plt.show()

print('AUC: ' + str(roc_auc))


# =============================================================================
# Please perform the grid search to identify the best hzperparameters for the current dataset
# =============================================================================
# # =============================================================================
# # Grid search for NN
# # =============================================================================
# #batch size and epochs
# import numpy
# import keras
# from sklearn.model_selection import GridSearchCV
# from keras.models import Sequential
# from keras.layers import Dense
# from keras.wrappers.scikit_learn import KerasClassifier
# # Function to create model, required for KerasClassifier
# def create_model():
# 	# create model
# 	model = Sequential()
# 	model.add(Dense(units = units, kernel_initializer = 'uniform', activation = 'relu', input_dim = input_dim))
# 	model.add(Dense(units = 1, kernel_initializer = 'uniform', activation = 'sigmoid'))
# 	# Compile model
# 	model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
# 	return model
# # fix random seed for reproducibility
# seed = 7
# numpy.random.seed(seed)
# 
# # create model
# model = KerasClassifier(build_fn=create_model, verbose=0)
# # define the grid search parameters
# #Batch size and epochs
# batch_size = [1, 5]
# epochs = [5, 10]
# #params list
# param_grid = dict(batch_size=batch_size, epochs=epochs)
# 
# grid = GridSearchCV(estimator=model, param_grid=param_grid, n_jobs=-1, cv=5)
# grid_result = grid.fit(train_features, train_labels)
# # summarize results
# print("Best: %f using %s" % (grid_result.best_score_, grid_result.best_params_))
# means = grid_result.cv_results_['mean_test_score']
# stds = grid_result.cv_results_['std_test_score']
# params = grid_result.cv_results_['params']
# for mean, stdev, param in zip(means, stds, params):
#     print("%f (%f) with: %r" % (mean, stdev, param))
# 
# 
# #Optimizer algorithm
# # Use scikit-learn to grid search the batch size and epochs
# import numpy
# from sklearn.model_selection import GridSearchCV
# from keras.models import Sequential
# from keras.layers import Dense
# from keras.wrappers.scikit_learn import KerasClassifier
# # Function to create model, required for KerasClassifier
# def create_model(optimizer='adam'):
# 	# create model
# 	model = Sequential()
# 	model.add(Dense(units = units, kernel_initializer = 'uniform', activation = 'relu', input_dim = imput_dim))
# 	model.add(Dense(1, activation='sigmoid'))
# 	# Compile model
# 	model.compile(loss='binary_crossentropy', optimizer=optimizer, metrics=['accuracy'])
# 	return model
# # fix random seed for reproducibility
# seed = 7
# numpy.random.seed(seed)
# 
# # create model
# model = KerasClassifier(build_fn=create_model, epochs=10, batch_size=1, verbose=0)
# # define the grid search parameters
# optimizer = ['SGD', 'RMSprop', 'Adagrad', 'Adadelta', 'Adam', 'Adamax', 'Nadam']
# param_grid = dict(optimizer=optimizer)
# grid = GridSearchCV(estimator=model, param_grid=param_grid, n_jobs=-1, cv=3)
# grid_result = grid.fit(train_features, train_labels)
# # summarize results
# print("Best: %f using %s" % (grid_result.best_score_, grid_result.best_params_))
# means = grid_result.cv_results_['mean_test_score']
# stds = grid_result.cv_results_['std_test_score']
# params = grid_result.cv_results_['params']
# for mean, stdev, param in zip(means, stds, params):
#     print("%f (%f) with: %r" % (mean, stdev, param))
#     
#     
# #Network weights initialization
# # Use scikit-learn to grid search the weight initialization
# import numpy
# from sklearn.model_selection import GridSearchCV
# from keras.models import Sequential
# from keras.layers import Dense
# from keras.wrappers.scikit_learn import KerasClassifier
# # Function to create model, required for KerasClassifier
# def create_model(init_mode='uniform'):
# 	# create model
# 	model = Sequential()
# 	model.add(Dense(units = units, kernel_initializer = 'uniform', activation = 'relu', input_dim = input_dim))
# 	model.add(Dense(1, kernel_initializer=init_mode, activation='sigmoid'))
# 	# Compile model
# 	model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
# 	return model
# # fix random seed for reproducibility
# seed = 7
# numpy.random.seed(seed)
# 
# # create model
# model = KerasClassifier(build_fn=create_model, epochs=10, batch_size=1, verbose=0)
# # define the grid search parameters
# init_mode = ['uniform', 'lecun_uniform', 'normal', 'zero', 'glorot_normal', 'glorot_uniform', 'he_normal', 'he_uniform']
# param_grid = dict(init_mode=init_mode)
# grid = GridSearchCV(estimator=model, param_grid=param_grid, n_jobs=-1, cv=5)
# grid_result = grid.fit(train_features, train_labels)
# # summarize results
# print("Best: %f using %s" % (grid_result.best_score_, grid_result.best_params_))
# means = grid_result.cv_results_['mean_test_score']
# stds = grid_result.cv_results_['std_test_score']
# params = grid_result.cv_results_['params']
# for mean, stdev, param in zip(means, stds, params):
#     print("%f (%f) with: %r" % (mean, stdev, param))
#     
#     
# #Neuron activation function
# # Use scikit-learn to grid search the activation function
# import numpy
# from sklearn.model_selection import GridSearchCV
# from keras.models import Sequential
# from keras.layers import Dense
# from keras.wrappers.scikit_learn import KerasClassifier
# # Function to create model, required for KerasClassifier
# def create_model(activation='relu'):
# 	# create model
# 	model = Sequential()
# 	model.add(Dense(units = units, kernel_initializer = 'uniform', activation = 'relu', input_dim = input_dim))
# 	model.add(Dense(1, kernel_initializer='uniform', activation='sigmoid'))
# 	# Compile model
# 	model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
# 	return model
# # fix random seed for reproducibility
# seed = 7
# numpy.random.seed(seed)
# 
# # create model
# model = KerasClassifier(build_fn=create_model, epochs=10, batch_size=1, verbose=0)
# # define the grid search parameters
# activation = ['softmax', 'softplus', 'softsign', 'relu', 'tanh', 'sigmoid', 'hard_sigmoid', 'linear']
# param_grid = dict(activation=activation)
# grid = GridSearchCV(estimator=model, param_grid=param_grid, n_jobs=-1, cv=5)
# grid_result = grid.fit(train_features, train_labels)
# # summarize results
# print("Best: %f using %s" % (grid_result.best_score_, grid_result.best_params_))
# means = grid_result.cv_results_['mean_test_score']
# stds = grid_result.cv_results_['std_test_score']
# params = grid_result.cv_results_['params']
# for mean, stdev, param in zip(means, stds, params):
#     print("%f (%f) with: %r" % (mean, stdev, param))
#     
#     
# #Number of neurons in the hidden layer
# # Use scikit-learn to grid search the number of neurons
# import numpy
# from sklearn.model_selection import GridSearchCV
# from keras.models import Sequential
# from keras.layers import Dense
# from keras.layers import Dropout
# from keras.wrappers.scikit_learn import KerasClassifier
# from keras.constraints import maxnorm
# # Function to create model, required for KerasClassifier
# def create_model(neurons=1):
# 	# create model
# 	model = Sequential()
# 	model.add(Dense(neurons, input_dim=input_dim, kernel_initializer='uniform', activation='linear', kernel_constraint=maxnorm(4)))
# 	model.add(Dropout(0.2))
# 	model.add(Dense(1, kernel_initializer='uniform', activation='sigmoid'))
# 	# Compile model
# 	model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
# 	return model
# # fix random seed for reproducibility
# seed = 7
# numpy.random.seed(seed)
# 
# # create model
# model = KerasClassifier(build_fn=create_model, epochs=5, batch_size=1, verbose=0)
# # define the grid search parameters
# neurons = [50, 80, 100, 120, 140, 160, 180, 200]
# param_grid = dict(neurons=neurons)
# grid = GridSearchCV(estimator=model, param_grid=param_grid, n_jobs=-1, cv=5)
# grid_result = grid.fit(train_features, train_labels)
# # summarize results
# print("Best: %f using %s" % (grid_result.best_score_, grid_result.best_params_))
# means = grid_result.cv_results_['mean_test_score']
# stds = grid_result.cv_results_['std_test_score']
# params = grid_result.cv_results_['params']
# for mean, stdev, param in zip(means, stds, params):
#     print("%f (%f) with: %r" % (mean, stdev, param))
# =============================================================================
    
# =============================================================================
#Feature importance selection - uncomment if desired
# =============================================================================

#feats = {} # a dict to hold feature_name: feature_importance
#for feature, importance in zip(feature_list, rf.feature_importances_):
#    feats[feature] = round(importance,5) #add the name/value pair 
#
#importances = pd.DataFrame.from_dict(feats, orient='index').rename(columns={0: 'Gini-importance'})
#import csv
#importances.sort_values(by='Gini-importance').to_csv(r'T:\tbase\short\feature_importances.csv', quoting=csv.QUOTE_NONNUMERIC)


