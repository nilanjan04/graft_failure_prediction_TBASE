#!pip install imblearn --proxy=https://user@proxy.charite.de:8080
#!pip install numpy --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas --upgrade  --proxy=https://user@proxy.charite.de:8080
#!pip install pandas_summary --upgrade  --proxy=https://user@proxy.charite.de:8080
    
import pandas as pd
import numpy as np
import sklearn

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
    print('--------------------------------------------------------------')
    
    # =============================================================================
    # #Keep TransplantationID in test data for error analysis
    # =============================================================================
    temp_labels = np.array(temp_features['Longterm_TransplantOutcome'])    
    temp_features= temp_features.drop('Longterm_TransplantOutcome', axis = 1)
    temp_features= temp_features.drop('tenure', axis = 1)
    temp_features= temp_features.drop('TransplantationID', axis = 1)
    temp_features= temp_features.drop('PatientID', axis = 1)
    if use_cluster_as_feature:
        temp_features = pd.get_dummies(data=temp_features, columns=['cluster'])
        print('Creating model for all clusters with cluster as feature')
    else:
        temp_features= temp_features.drop('cluster', axis = 1)    
        print('Creating model for cluster ' + str(current_cluster))
    
    # =============================================================================
    # #Spliting datasets into train and test sets
    # =============================================================================
    from sklearn.model_selection import train_test_split
    train_features, test_features, train_labels, test_labels = train_test_split(temp_features, temp_labels, test_size = 0.25, random_state = 42)
    
    # =============================================================================
    # #SMOTE for upsampling
    # =============================================================================
    from collections import Counter
    from imblearn.over_sampling import SMOTE
    if len(np.unique(train_labels)) > 1:
        train_features, train_labels = SMOTE().fit_resample(train_features, train_labels)
    
    # =============================================================================
    # #Random forest classifier (baseline model)
    # =============================================================================
    from sklearn.ensemble import RandomForestClassifier
    #rf = RandomForestClassifier(n_estimators = 400, random_state = 42, min_samples_split=2, min_samples_leaf=1, max_features='sqrt', max_depth=None, bootstrap=False)
    rf = RandomForestClassifier(n_estimators = 10000, random_state = 42)
    rf.fit(train_features, train_labels);
    
    predictions = rf.predict(test_features)
    df_predictions = pd.DataFrame(predictions, columns=['prediction']) 
    
    predictions_proba = rf.predict_proba(test_features)
    df_predictions_proba = pd.DataFrame(predictions_proba[:, 1], columns=['prediction_proba']) 
    
    df_predictions.loc[df_predictions_proba['prediction_proba'] >= 0.24, ['prediction']] = 1
    df_predictions.loc[df_predictions_proba['prediction_proba'] < 0.24, ['prediction']] = 0
    
    df_predictions_both = df_predictions.join(df_predictions_proba)
    df_labels = pd.DataFrame(test_labels, columns=['label']) 
    
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
# #Create prediction models for all clusters
# =============================================================================
# Please include SQL export csv file with destination below 
data = pd.read_csv(r'', sep=',')
data = data.drop('Unnamed: 0', axis = 1)

clusters = sorted(data['cluster'].unique())

#Build baseline model 
create_model(data, 'All', False)

#Build seperate models for each cluster
for current_cluster in clusters:
    current_data = data[data['cluster']==current_cluster]
    create_model(current_data, current_cluster, False)

#Build model with cluster as feature
create_model(data, 'All', True)




