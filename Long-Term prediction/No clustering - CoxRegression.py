#!pip install imblearn --proxy=https://user@proxy.charite.de:8080
#!pip install numpy --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas_summary --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install lifelines --proxy=https://user@proxy.charite.de:8080 --upgrade

import pandas as pd
import numpy as np
from lifelines import CoxPHFitter

# =============================================================================
# #Importing the dataset TBASE
# =============================================================================
# Please include SQL export csv file with destination below 
temp_features = pd.read_csv(r'', sep=',')

# =============================================================================
# Visualising the distribution of the dataset 
# =============================================================================
#import seaborn as sns
#import matplotlib.pyplot as plt
#sns.set(rc={'figure.figsize':(15,12)})
#
#df1 = temp_features.select_dtypes([np.int, np.float]).fillna(-5)
#for i, col in enumerate(df1.columns):
#    plt.figure(i)
#    sns_plot = sns.distplot(df1[col])
#    fig = sns_plot.get_figure()
#    fig.savefig(r'T:\\tbase\\plots\\' + col + '_PreImputation.png')
    
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

# =============================================================================
# # Drop features with no variance
# =============================================================================
events = train_features['Longterm_TransplantOutcome'].astype(bool)
for col in train_features.columns:
    if (train_features.loc[events, col].var() == 0.0 or train_features.loc[~events, col].var() == 0.0 ) and col != 'Longterm_TransplantOutcome':
        print('Dropped column ' + col + ' (no variance)')
        train_features.drop([col], axis=1, inplace=True)
        test_features.drop([col], axis=1, inplace=True)
        
feature_list = train_features.columns
# =============================================================================
#Feature importance selection
# =============================================================================
#def fit_and_score_features2(X):

#X = train_features.copy()
#y=X[["Longterm_TransplantOutcome","tenure"]]
#   
#X.drop(["tenure", "Longterm_TransplantOutcome"], axis=1, inplace=True)
#n_features = X.shape[1]
#scores = {'test':0}
#m = CoxPHFitter(penalizer=0.1) 
#
#for j in range(n_features):
#    print('-------------------------------------')
#    print('Feature: ' + feature_list[j])
#    Xj = X.iloc[:, j:j+1]
#    Xj=pd.merge(Xj, y,  how='right', left_index=True, right_index=True)
#    m.fit(Xj, duration_col="tenure", event_col="Longterm_TransplantOutcome", show_progress=True)
#    scores[feature_list[j]] = m.concordance_index_
#    print('Concordance index: ' + str(m.concordance_index_))
#    print('-------------------------------------')
#scores = pd.DataFrame(scores.items())
#
#scores.to_csv(r'T:\tbase\feature_importances.csv', quoting=csv.QUOTE_NONNUMERIC)
    
# =============================================================================
# #Cox Regression Model
# ======================================================    
cph = CoxPHFitter(penalizer=0.1)   ## Instantiate the class to create a cph object
cph.fit(train_features, 'tenure', event_col='Longterm_TransplantOutcome', show_progress=True, step_size=0.1)   ## Fit the data to train the model

cph.summary.to_csv(r'T:\tbase\cph_summary.csv')

print('concordance index: ' + str(cph.concordance_index_))

tr_rows = test_features.loc[:, test_features.columns != 'Longterm_TransplantOutcome'].iloc[:, :]
tr_rows_res = test_features.loc[:, test_features.columns == 'Longterm_TransplantOutcome'].iloc[:, :]

cph.predict_survival_function(tr_rows).plot()
print(tr_rows_res)

predictions = cph.predict_survival_function(tr_rows)

predictions = predictions.transpose()

#pd.DataFrame(predictions.columns).to_clipboard()

# =============================================================================
# #Qualitative error analysis
for col in predictions.columns:
    if float(col) > (365*6):
        col_use = col
        print(col_use)
        break
        
predictions = predictions[col_use]
predictions = predictions.to_frame(name='predictions')
labels = pd.DataFrame(test_features_outcomes, columns=['label'])

df_error_analysis = predictions.join(labels)

df_error_analysis.to_csv(r'T:\tbase\res.csv')
#
# =============================================================================
