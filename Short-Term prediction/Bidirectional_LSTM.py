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
z, y = train_labels, test_labels
Counter(y)
Counter(z)
# =============================================================================
# #Imputation 
# =============================================================================
from sklearn.experimental import enable_iterative_imputer  
from sklearn.impute import IterativeImputer
imp = IterativeImputer(random_state=0, max_iter = 100, imputation_order='random')
imp.fit(train_features)
train_features = imp.transform(train_features)
test_features = imp.transform(test_features)

# You can check the outcomes of imputation by executing the lines below
# Please change the path accordingly
#train_features.to_csv(r'T:\tbase\short\train_feature_imputation.csv')
#test_features.to_csv(r'T:\tbase\short\test_feature_imputation.csv')

# =============================================================================
# #Keep TransplantationID in test data for error analysis
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

#Oversampling the test set - uncomment if required 
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
pca = PCA(n_components = 168)
train_features = pd.DataFrame(pca.fit_transform(train_features))
test_features = pd.DataFrame(pca.transform(test_features))
explained_variance = pca.explained_variance_ratio_

pca_stats = pd.DataFrame(explained_variance)
df_feature_list = pd.DataFrame(feature_list, columns= ['feature'] )
pca_stats = pca_stats.join(df_feature_list)
#Change the path accordingly
#pca_stats.to_csv(r'T:\tbase\short_lstm\pca_stats.csv')

# =============================================================================
# Reshaping the dataframes into 3 dimensional vectors for LSTM input
# =============================================================================

train_features = np.array(train_features)
train_features = train_features.reshape((4310, 1, 168)) 
train_labels = np.array(train_labels)
train_labels = train_labels.reshape((4310, 1, 1)) 
test_features = np.array(test_features)
#Change to 1438 when oversampled
test_features = test_features.reshape((730, 1, 168)) 
test_labels = np.array(test_labels)
test_labels = test_labels.reshape((730, 1, 1)) 



# =============================================================================
# BI-LSTM 
# =============================================================================
import keras
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, LSTM, Bidirectional

model = Sequential()
model.add(Bidirectional(LSTM(100, input_shape=(train_features.shape[1:]), activation='softsign', return_sequences=True)))
model.add(Dropout(0.2))
model.add(Bidirectional(LSTM(100, activation='softsign'))) 
model.add(Dropout(0.2))
model.add(Dense(32, activation='softsign'))
model.add(Dropout(0.2))

# activation = ['softmax', 'softplus', 'softsign', 'relu', 'tanh', 'sigmoid', 'hard_sigmoid', 'linear']
model.add(Dense(1, activation='sigmoid'))
# optimizer = ['SGD', 'RMSprop', 'Adagrad', 'Adadelta', 'Adam', 'Adamax', 'Nadam']
model.compile(loss='binary_crossentropy', optimizer = 'adam', metrics = [keras.metrics.Precision()] )
#history = model.fit(train_features, train_labels, epochs = 10, validation_data =(test_features, test_labels))

history = model.fit(train_features, train_labels, epochs = 10, verbose=0)
predictions = model.predict_classes(test_features)
#predictions = model.predict(test_features)

prediction = predictions.reshape(730,1)
df_predictions = pd.DataFrame(prediction, columns=['prediction']) 

test_labels = test_labels.reshape((730,1))
df_labels = pd.DataFrame(test_labels, columns=['label'])


### =============================================================================
## #Qualitative error analysis
df_error_analysis = df_predictions.join(df_labels).join(pd.DataFrame(test_features_transplantationIDs, columns=['TransplantationID'])).join(pd.DataFrame(test_features_patientIDs, columns=['PatientID']))
df_error_analysis.to_csv(r'T:\tbase\short_ff\Qualitative_res.csv') #Please change the path accordingly
##
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
#print(conf_mat)
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

