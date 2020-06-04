#!pip install imblearn --proxy=https://user@proxy.charite.de:8080
#!pip install numpy --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install lifelines --proxy=https://user@proxy.charite.de:8080 --upgrade

import pandas as pd
import numpy as np
import sklearn
from lifelines import CoxPHFitter
    
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
        
   

def create_model(temp_features, current_cluster, use_cluster_as_feature):
    print('----------------------------------------------------------------------------------------------------------------------------')
    print('----------------------------------------------------------------------------------------------------------------------------')
    print('----------------------------------------------------------------------------------------------------------------------------')
    print('----------------------------------------------------------------------------------------------------------------------------')
    print('----------------------------------------------------------------------------------------------------------------------------')
    
    # =============================================================================
    # #Keep TransplantationID in test data for error analysis
    # =============================================================================
    temp_labels = np.array(temp_features['Longterm_TransplantOutcome'])    
    temp_features= temp_features.drop('TransplantationID', axis = 1)
    temp_features= temp_features.drop('PatientID', axis = 1)
    if use_cluster_as_feature:
        temp_features = pd.get_dummies(data=temp_features, columns=['cluster'])
        print('Creating model for all clusters with cluster as feature')
    else:
        temp_features= temp_features.drop('cluster', axis = 1)    
        print('Creating model for cluster ' + str(current_cluster))
    #for col in temp_features.columns:
    #    print(col)
    # =============================================================================
    # #Spliting datasets into train and test sets
    # =============================================================================
    from sklearn.model_selection import train_test_split
    train_features, test_features, train_labels, test_labels = train_test_split(temp_features, temp_labels, test_size = 0.25, random_state = 42)
    
    # =============================================================================
    # #SMOTE for upsampling
    # =============================================================================
    from imblearn.over_sampling import SMOTE
    train_features, train_labels = SMOTE().fit_resample(train_features, train_labels)
    
    
    # =============================================================================
    # # Drop features with no variance
    # =============================================================================
    events = train_labels.astype(bool)
    for col in train_features.columns:
        if (train_features.loc[events, col].var() == 0.0 or train_features.loc[~events, col].var() == 0.0 ) and col != 'Longterm_TransplantOutcome':
            #print('Dropped column ' + col + ' (no variance)')
            train_features.drop([col], axis=1, inplace=True)
            test_features.drop([col], axis=1, inplace=True)

    # =============================================================================
    # #Cox Regression model
    # =============================================================================
    
    cph = CoxPHFitter(penalizer=0.1)   ## Instantiate the class to create a cph object
    cph.fit(train_features, 'tenure', event_col='Longterm_TransplantOutcome', show_progress=False, step_size=0.1)   ## Fit the data to train the model
    
    print('concordance index: ' + str(cph.concordance_index_))
    
    tr_rows = test_features.loc[:, test_features.columns != 'Longterm_TransplantOutcome'].iloc[:, :]    
    predictions = cph.predict_survival_function(tr_rows)
    predictions = predictions.transpose()
    
    # =============================================================================
    # #Error analysis
    # =============================================================================
    for col in predictions.columns:
        if float(col) > (365*6):
            col_use = col
            print(col_use)
            break
            
    predictions = predictions[col_use]
    predictions = predictions.to_frame(name='prediction')
    
    predictions.loc[predictions['prediction'] > 0.5, ['prediction']] = 1
    predictions.loc[predictions['prediction'] <= 0.5, ['prediction']] = 0
    predictions=(~predictions.astype(bool)).astype(int)
    
    labels = pd.DataFrame(test_labels, columns=['label'])
    
    predictions.reset_index(drop=True, inplace=True)
    labels.reset_index(drop=True, inplace=True)

    # =============================================================================
    # #Confusion matrix
    # =============================================================================
    from sklearn.metrics import confusion_matrix
    conf_mat = confusion_matrix(labels, predictions)
    print(conf_mat)
    import seaborn
    seaborn.heatmap(conf_mat)
    
    labels_desc = [1,0 ]
    cm = confusion_matrix(predictions, labels, labels_desc)
    print_cm(cm, labels_desc)
    
    # =============================================================================
    # #Precision, Recall, F1-Score
    # =============================================================================
    print(sklearn.metrics.classification_report(labels, predictions, labels=None, target_names=None, sample_weight=None, digits=2, output_dict=False, zero_division='warn'))
    
    # =============================================================================
    # #ROC curve
    # =============================================================================
    import sklearn.metrics as metrics
    fpr, tpr, threshold = metrics.roc_curve(labels,  predictions)
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
    

# =============================================================================
# #Create prediction models for all clusters
# =============================================================================
# Please include SQL export csv file with destination below 
data = pd.read_csv(r'', sep=',')
data = data.drop('Unnamed: 0', axis = 1)

clusters = sorted(data['cluster'].unique())

#Build baseline model 
create_model(data, 'All (baseline)', False)

#Build seperate models for each cluster
for current_cluster in clusters:
    current_data = data[data['cluster']==current_cluster]
    create_model(current_data, current_cluster, False)

#Build model with cluster as feature
create_model(data, 'All (cluster as feature)', True)