#!pip install imblearn --proxy=https://user@proxy.charite.de:8080
#!pip install numpy --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas_summary --upgrade  --proxy=https://user@proxy.charite.de:8080

import pandas as pd
import numpy as np
import sklearn

# =============================================================================
# #Importing the dataset TBASE
# =============================================================================
# Please include SQL export csv file with destination below 
temp_features = pd.read_csv(r'', sep=',')

# =============================================================================
# #Removing Label
# =============================================================================
temp_features.drop(['Shortterm_TransplantOutcome'], axis = 1, inplace = True)

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

##Failure class
#feature_distribution_failure = temp_features.loc[temp_features['Longterm_TransplantOutcome'] == 1]
#df_summary_distribution_failure = DataFrameSummary(feature_distribution_failure)
#feature_distribution_failure.describe().transpose().join(df_summary_distribution_failure.columns_stats.transpose()).to_csv(r'T:\tbase\feature_stats_failure.csv')
##Success class
#feature_distribution_success = temp_features.loc[temp_features['Longterm_TransplantOutcome'] == 0]
#df_summary_distribution_success = DataFrameSummary(feature_distribution_success)
#feature_distribution_success.describe().transpose().join(df_summary_distribution_success.columns_stats.transpose()).to_csv(r'T:\tbase\feature_stats_success.csv')

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
# #Remove features with more than 20% missing data
# =============================================================================
#for index, row in df_summary.columns_stats.transpose().iterrows():
#    if pd.to_numeric(row['missing_perc'].replace('%','')) > 20:
#        print('Removed column ' + index + ' (more than 20 percent missing)')
#        temp_features.drop([index], axis = 1, inplace = True)
#

# =============================================================================
# #Get summary for high entropy features and for each individual class labels
# =============================================================================
#from pandas_summary import DataFrameSummary
#
##Failure class
#feature_distribution_failure = temp_features.loc[temp_features['Longterm_TransplantOutcome'] == 1]
#df_summary_failure = DataFrameSummary(feature_distribution_failure)
#feature_distribution_failure.describe().transpose().join(df_summary_failure.columns_stats.transpose()).to_csv(r'T:\tbase\high_entropy_feature_stats_failure.csv')
##Success class
#feature_distribution_success = temp_features.loc[temp_features['Longterm_TransplantOutcome'] == 0]
#df_summary_success = DataFrameSummary(feature_distribution_success)
#feature_distribution_success.describe().transpose().join(df_summary_success.columns_stats.transpose()).to_csv(r'T:\tbase\high_entropy_feature_stats_success.csv')   
#    
# =============================================================================
# #Remove rows that contain null values    
# =============================================================================
#def nans(df): return df[df.isnull().any(axis=1)]
#    
#temp_features_nans = nans(temp_features)
#
#cond = temp_features['TransplantationID'].isin(temp_features_nans['TransplantationID'])
#temp_features.drop(temp_features[cond].index, inplace = True)

# =============================================================================
# #Split labels  from temp_features
# =============================================================================
temp_labels = np.array(temp_features['Longterm_TransplantOutcome'])
temp_features= temp_features.drop('Longterm_TransplantOutcome', axis = 1)

# =============================================================================
# #One-Hot-Encoding
# =============================================================================
temp_features = pd.get_dummies(temp_features)

# =============================================================================
# #Feature correlation
# =============================================================================
#corr_matrix = temp_features.corr().abs()
#upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(np.bool))
#to_drop = [column for column in upper.columns if any(upper[column] > 0.95)]
#for col in to_drop:
#    temp_features.drop(col, axis = 1, inplace=True)
#    print('Removed column ' + col + ' (correleated with other feature)')

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
# Visualising the distribution of the dataset 
# =============================================================================
#import seaborn as sns
#import matplotlib.pyplot as plt
#sns.set(rc={'figure.figsize':(15,12)})
#
#df1 = pd.DataFrame(train_features, columns=feature_list).select_dtypes([np.int, np.float])
#for i, col in enumerate(df1.columns):
#    plt.figure(i)
#    sns_plot = sns.distplot(df1[col])
#    fig = sns_plot.get_figure()
#    fig.savefig(r'T:\\tbase\\plots\\' + col + '_PostImputation.png')


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
print(train_features.shape)
print(train_labels.shape)

# =============================================================================
# Considering only 80% of training dataset for training the model
# =============================================================================
#train_features = train_features[:3086]
#train_labels = train_labels[:3086]
#print(train_features.shape)
#print(train_labels.shape)

# =============================================================================
# Considering only 60% of training dataset for training the model
# =============================================================================
#train_features = train_features[:2314]
#train_labels = train_labels[:2314]
#print(train_features.shape)
#print(train_labels.shape)

# =============================================================================
# Considering only 40% of training dataset for training the model
# =============================================================================
#train_features = train_features[:1543]
#train_labels = train_labels[:1543]
#print(train_features.shape)
#print(train_labels.shape)

# =============================================================================
# Considering only 20% of training dataset for training the model
# =============================================================================
#train_features = train_features[:771]
#train_labels = train_labels[:771]
#print(train_features.shape)
#print(train_labels.shape)

# =============================================================================
# #Random forest classifier (baseline model)
# =============================================================================
from sklearn.ensemble import RandomForestClassifier
rf = RandomForestClassifier(n_estimators = 100, random_state = 42)
rf.fit(train_features, train_labels);

predictions = rf.predict(test_features)
df_predictions = pd.DataFrame(predictions, columns=['prediction']) 

predictions_proba = rf.predict_proba(test_features)
df_predictions_proba = pd.DataFrame(predictions_proba[:, 1], columns=['prediction_proba']) 

df_predictions.loc[df_predictions_proba['prediction_proba'] >= 0.27, ['prediction']] = 1
df_predictions.loc[df_predictions_proba['prediction_proba'] < 0.27, ['prediction']] = 0

df_predictions_both = df_predictions.join(df_predictions_proba)
df_labels = pd.DataFrame(test_labels, columns=['label']) 


# =============================================================================
# #Qualitative error analysis
# =============================================================================
df_error_analysis = df_predictions_both.join(df_labels).join(pd.DataFrame(test_features_transplantationIDs, columns=['TransplantationID'])).join(pd.DataFrame(test_features_patientIDs, columns=['PatientID']))
df_error_analysis.to_csv(r'T:\tbase\res.csv')

# =============================================================================
#Feature importance selection
# =============================================================================

feats = {} # a dict to hold feature_name: feature_importance
for feature, importance in zip(feature_list, rf.feature_importances_):
    feats[feature] = round(importance,5) #add the name/value pair 

importances = pd.DataFrame.from_dict(feats, orient='index').rename(columns={0: 'Gini-importance'})
import csv
importances.sort_values(by='Gini-importance').to_csv(r'T:\tbase\feature_importances.csv', quoting=csv.QUOTE_NONNUMERIC)


#Results
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