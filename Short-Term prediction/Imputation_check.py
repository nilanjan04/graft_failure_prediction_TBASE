import pandas as pd
import numpy as np
import sklearn

# =============================================================================
# #Importing the dataset TBASE
# =============================================================================
# PLease provide a csv file with destination below
temp_features = pd.read_csv(r'', sep=',')



# =============================================================================
# #Removing Longterm Label
# =============================================================================
temp_features.drop(['Longterm_TransplantOutcome'], axis = 1, inplace = True)
temp_features.drop(['Shortterm_TransplantOutcome_12months'], axis = 1, inplace = True)

    
# =============================================================================
# #Get summary for features and for each individual class labels
# =============================================================================
from pandas_summary import DataFrameSummary
df_summary = DataFrameSummary(temp_features)
#temp_features.describe().transpose().join(df_summary.columns_stats.transpose()).to_csv(r'T:\tbase\short\feature_stats.csv')

#Failure class
feature_distribution_failure = temp_features.loc[temp_features['Shortterm_TransplantOutcome'] == 1]
df_summary_distribution_failure = DataFrameSummary(feature_distribution_failure)
#feature_distribution_failure.describe().transpose().join(df_summary_distribution_failure.columns_stats.transpose()).to_csv(r'T:\tbase\short\feature_stats_failure.csv')
#Success class
feature_distribution_success = temp_features.loc[temp_features['Shortterm_TransplantOutcome'] == 0]
df_summary_distribution_success = DataFrameSummary(feature_distribution_success)
#feature_distribution_success.describe().transpose().join(df_summary_distribution_success.columns_stats.transpose()).to_csv(r'T:\tbase\short\feature_stats_success.csv')


# =============================================================================
# #Remove features that have missing data
# =============================================================================
for index, row in df_summary.columns_stats.transpose().iterrows():
    if pd.to_numeric(row['missing_perc'].replace('%','')) > 0:
        print('Removed column ' + index + ' (have missing data)')
        temp_features.drop([index], axis = 1, inplace = True)
#
temp_features_original = temp_features
temp_features_original = temp_features_original.head(50)
temp_features = temp_features.head(50)

feature_list = list(temp_features_original.columns)
# =============================================================================
# #Keep TransplantationID and PatientID in test data for error analysis
# =============================================================================
temp_features_transplantationIDs = np.array(pd.DataFrame(temp_features, columns=feature_list)['TransplantationID'])
temp_features_patientIDs = np.array(pd.DataFrame(temp_features, columns=feature_list)['PatientID'])

temp_features.drop(['TransplantationID', 'PatientID'], axis=1)
# =============================================================================
# #One-Hot-Encoding
# =============================================================================
temp_features = pd.get_dummies(temp_features)
temp_features_original = pd.get_dummies(temp_features_original)
# =============================================================================
# Randomly add nulls 30%
# =============================================================================


temp_features = temp_features.mask(np.random.random(temp_features.shape) < .3)





temp_features_nulls = temp_features

# =============================================================================
# #Imputation 
# =============================================================================
from sklearn.experimental import enable_iterative_imputer  
from sklearn.impute import IterativeImputer
imp = IterativeImputer(random_state=0, max_iter = 100, imputation_order='random')
imp.fit(temp_features)
temp_features = imp.transform(temp_features)
temp_features = pd.DataFrame(temp_features)
temp_features = test_features_transplantationIDs, columns=['TransplantationID'])).join(pd.DataFrame(test_features_patientIDs, columns=['PatientID']))
temp_features.columns = feature_list

compare= pd.concat([temp_features_original, temp_features, temp_features_nulls]).sort_index(kind='merge')
compare.to_csv(r'T:\tbase\short\compare_imputation.csv')

#temp_features = pd.DataFrame(temp_features, columns = feature_list)