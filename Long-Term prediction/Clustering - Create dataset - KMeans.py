#!pip install imblearn --proxy=https://user@proxy.charite.de:8080
#!pip install numpy --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas_summary --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install seaborn --upgrade  --proxy=https://user@proxy.charite.de:8080

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
temp_features = min_max_scaler.fit_transform(temp_features)

temp_features = pd.DataFrame(temp_features, columns=feature_list)

# =============================================================================
# #Imputation 
# =============================================================================
from sklearn.experimental import enable_iterative_imputer  
from sklearn.impute import IterativeImputer
imp = IterativeImputer(random_state=0, max_iter = 50, imputation_order='random')
imp.fit(temp_features)
features_imp = imp.transform(temp_features)
imp = None
import gc
gc.collect()
features_imp = pd.DataFrame(features_imp,columns=feature_list)
features = features_imp.copy()

features = features.join(pd.DataFrame(temp_features_label, columns=(['Longterm_TransplantOutcome'])))
features = features.join(pd.DataFrame(temp_features_tenure, columns=(['tenure'])))
features = features.join(pd.DataFrame(temp_features_transplantationIDs, columns=(['TransplantationID'])))
features = features.join(pd.DataFrame(temp_features_patientIDs, columns=(['PatientID'])))
features.to_csv(r'T:\\tbase\\tbase_data_imputed.csv')

###################################

import pandas as pd
import numpy as np
import sklearn
import matplotlib.pyplot as plt
from pylab import rcParams
from sklearn.cluster import KMeans 
from sklearn.preprocessing import scale # for scaling the data
import sklearn.metrics as sm # for evaluating the model
from sklearn import datasets
from sklearn.metrics import confusion_matrix,classification_report
import seaborn as sns
import matplotlib.pyplot as plt

features = pd.read_csv(r'T:\tbase\tbase_data_imputed.csv', sep=',')
features = features.drop('Unnamed: 0', axis = 1)
features_imp = features.copy()
feature_list = list(features.columns)

#Use diagnosis data only
columns_to_use = [x for x in features.columns if 'Diag' in x]
features = features[columns_to_use]

#Use all features
features.drop('Longterm_TransplantOutcome', axis = 1, inplace = True)
features.drop('TransplantationID', axis = 1, inplace = True)
features.drop('PatientID', axis = 1, inplace = True)
features.drop('tenure', axis = 1, inplace = True)

# =============================================================================
# # How many clusters? -> Elbow method!
# =============================================================================
sse = {}
for k in range(1, 10):
    kmeans = KMeans(n_clusters=k, max_iter=1000).fit(features)
    features["clusters"] = kmeans.labels_
    sse[k] = kmeans.inertia_ # Inertia: Sum of distances of samples to their closest cluster center
plt.figure()
plt.plot(list(sse.keys()), list(sse.values()))
plt.xlabel("Number of cluster")
plt.ylabel("SSE")
#plt.savefig(r'T:\\tbase\\plots\\elbow.png')

%matplotlib inline 

clustering = KMeans(n_clusters=4,random_state=5)
clustering.fit(features)
clusters = pd.DataFrame(clustering.predict(features),columns=['cluster'])

# Check Silhouette Coefficient
from sklearn import metrics
labels = clustering.labels_
metrics.silhouette_score(features, labels, metric='euclidean')

features = features_imp.join(clusters)

features.to_csv(r'T:\\tbase\\tbase_data_kmeans_4_clusters_diag.csv')

# Visualization 
for col in features.columns:
    df_vis = pd.DataFrame(columns=['Feature', 'Value', 'Cluster'])
    print(col)
    for ind, val in features[col].items():
        df_vis = df_vis.append({'Feature' : col , 'Value' : val, 'Cluster': features['cluster'][ind]} , ignore_index=True)
    sns.set(style="ticks", color_codes=True)    
    sns.set(rc={'figure.figsize':(15,12)})
    plot = sns.catplot(x='Feature', y='Value', hue='Cluster', kind="boxen", data=df_vis);
    plot.savefig(r'T:\tbase\plots\4 clusters (diag features)\clusters_' + col + '.png')
    plt.close('all')
