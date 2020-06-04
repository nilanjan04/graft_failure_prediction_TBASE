#!pip install imblearn --proxy=https://user@proxy.charite.de:8080
#!pip install numpy --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas_summary --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip --proxy=https://user@proxy.charite.de:8080
#!pip install t:\git\deepsurv --proxy=https://user@proxy.charite.de:8080
#!pip install scipy --upgrade --proxy=https://user@proxy.charite.de:8080

import pandas as pd
import numpy as np
import sklearn

# =============================================================================
# #Importing the dataset TBASE
# =============================================================================
# Please include SQL export csv file with destination below 
temp_features = pd.read_csv(r'', sep=',')

# =============================================================================
# #Get summary for features and for each individual class labels
# =============================================================================
from pandas_summary import DataFrameSummary
df_summary = DataFrameSummary(temp_features)
temp_features.describe().transpose().join(df_summary.columns_stats.transpose()).to_csv(r'T:\tbase\feature_stats.csv')

# =============================================================================
# #Remove constant features
# =============================================================================
for index, row in df_summary.columns_stats.transpose()[df_summary.columns_stats.transpose()['types'].str.lower().str.contains('constant')].iterrows():
    print('Removed column ' + index + ' (constant)')
    temp_features.drop([index], axis = 1, inplace = True)

print('The shape of our features is:', temp_features.shape)
temp_features.describe()
feature_list = list(temp_features.columns)

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
temp_features_tenure = np.array(pd.DataFrame(temp_features, columns=feature_list)['tenure'])
temp_features_label = np.array(pd.DataFrame(temp_features, columns=feature_list)['Longterm_TransplantOutcome'])

temp_features.drop(['TransplantationID'], axis = 1, inplace = True)
temp_features.drop(['PatientID'], axis = 1, inplace = True)
temp_features.drop(['tenure'], axis = 1, inplace = True)
temp_features.drop(['Longterm_TransplantOutcome'], axis = 1, inplace = True)

feature_list = list(temp_features.columns)

# =============================================================================
# #Normalisation
# =============================================================================
from sklearn import preprocessing
temp_features = temp_features.iloc[:, :].values #returns a numpy array
min_max_scaler = preprocessing.MinMaxScaler()
x_scaled = min_max_scaler.fit_transform(temp_features)
temp_features = pd.DataFrame(x_scaled, columns=feature_list[:])

temp_features = temp_features.join(pd.DataFrame(temp_features_transplantationIDs, columns=['TransplantationID']))
temp_features = temp_features.join(pd.DataFrame(temp_features_patientIDs, columns=['PatientID']))
temp_features = temp_features.join(pd.DataFrame(temp_features_tenure, columns=['tenure']))
temp_features = temp_features.join(pd.DataFrame(temp_features_label, columns=['Longterm_TransplantOutcome']))

feature_list = list(temp_features.columns)

temp_features = np.array(temp_features)

# =============================================================================
# #Spliting datasets into train and test sets
# =============================================================================
from sklearn.model_selection import train_test_split
train_features, test_features  = train_test_split(temp_features, test_size = 0.25, random_state = 42)
print('Training Features Shape:', train_features.shape)
print('Testing Features Shape:', test_features.shape)


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

test_features_outcomes = np.array(test_features['Longterm_TransplantOutcome'])

# =============================================================================
# #SMOTE for upsampling
# =============================================================================
from collections import Counter
from imblearn.over_sampling import SMOTE
#print(sorted(Counter(train_labels).items()))
train_features, train_labels = SMOTE().fit_resample(train_features.loc[:, train_features.columns != 'Longterm_TransplantOutcome'], train_features['Longterm_TransplantOutcome'])
print(sorted(Counter(train_labels).items()))
train_features = train_features.join(pd.DataFrame(train_labels,columns=['Longterm_TransplantOutcome']))


events = train_features['Longterm_TransplantOutcome'].astype(bool)
for col in train_features.columns:
    if (train_features.loc[events, col].var() == 0.0 or train_features.loc[~events, col].var() == 0.0 ) and col != 'Longterm_TransplantOutcome':
        print('Dropped column ' + col + ' (no variance)')
        train_features.drop([col], axis=1, inplace=True)
        test_features.drop([col], axis=1, inplace=True)
        
feature_list = train_features.columns

# Use DeepSurv from the repo
import sys
sys.path.append(r'T:\git\DeepSurv\deepsurv')
import deepsurv

from deepsurv_logger import DeepSurvLogger, TensorboardLogger
import utils
import viz

import numpy as np
import pandas as pd

import lasagne
import matplotlib
import matplotlib.pyplot as plt
%matplotlib inline

# event_col is the header in the df that represents the 'Event / Status' indicator
# time_col is the header in the df that represents the event time
def dataframe_to_deepsurv_ds(df, event_col = 'Event', time_col = 'Time'):
    # Extract the event and time columns as numpy arrays
    e = df[event_col].values.astype(np.int32)
    t = df[time_col].values.astype(np.float32)

    # Extract the patient's covariates as a numpy array
    x_df = df.drop([event_col, time_col], axis = 1)
    x = x_df.values.astype(np.float32)
    
    # Return the deep surv dataframe
    return {
        'x' : x,
        'e' : e,
        't' : t
    }

# If the headers of the csv change, you can replace the values of 
# 'event_col' and 'time_col' with the names of the new headers
# You can also use this function on your training dataset, validation dataset, and testing dataset
train_data = dataframe_to_deepsurv_ds(train_features, event_col = 'Longterm_TransplantOutcome', time_col= 'tenure')
test_data = dataframe_to_deepsurv_ds(test_features, event_col = 'Longterm_TransplantOutcome', time_col= 'tenure')

hyperparams = {
    'L2_reg': 1.0,
    'batch_norm': True,
    'dropout': 0.4,
    'hidden_layers_sizes': [100, 50, 20, 5, 2],
    'learning_rate': 1e-01,
    'lr_decay': 0.05,
    'momentum': 0.5,
    'n_in': train_data['x'].shape[1],
    'standardize': True
}

# Create an instance of DeepSurv using the hyperparams defined above
model = deepsurv.DeepSurv(**hyperparams)

# DeepSurv can now leverage TensorBoard to monitor training and validation
# This section of code is optional. If you don't want to use the tensorboard logger
# Uncomment the below line, and comment out the other three lines: 
# logger = None

experiment_name = 'DeepSurv model'
logdir = r'T:\tbase\logs\\'
logger = TensorboardLogger(experiment_name, logdir=logdir)

# Now we train the model
update_fn=lasagne.updates.nesterov_momentum # The type of optimizer to use. \
                                            # Check out http://lasagne.readthedocs.io/en/latest/modules/updates.html \
                                            # for other optimizers to use
n_epochs = 10

# If you have validation data, you can add it as the second parameter to the function
metrics = model.train(train_data, n_epochs=n_epochs, logger=logger, update_fn=update_fn)

# Print the final metrics
print('Train Concordance Index:', metrics['c-index'][-1])

# Plot the training / validation curves
viz.plot_log(metrics)


predictions = pd.DataFrame(model.predict_risk(test_data['x']), columns=['Prediction score'])
labels = pd.DataFrame(test_features_outcomes, columns=['label'])
df_error_analysis = predictions.join(labels)
df_error_analysis.to_csv(r'T:\tbase\res.csv')

#metrics.save_model("model_1", weights_file ="model_1")
#previous_metrics = load_model_from_json(model_fp = 'model_1' , weights_fp = 'model_1')