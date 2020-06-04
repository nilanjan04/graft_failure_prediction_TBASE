#Taken from https://github.com/jaredleekatzman/DeepSurv/blob/master/hyperparam_search/hyperparam_search.py and adapted.
#!pip install optunity --upgrade --proxy=https://user@proxy.charite.de:8080

import sys, os
sys.path.append('T:\git\DeepSurv\deepsurv')
import deepsurv
import utils        
from deepsurv_logger import TensorboardLogger
import uuid
import pickle
import json
import numpy as np
import lasagne
import optunity
import logging
import pandas as pd

def load_logger(logdir):
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)
    format = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    
    # Print to Stdout
    ch = logging.StreamHandler(sys.stdout)
    ch.setFormatter(format)
    logger.addHandler(ch)

    # Print to Log file
    fh = logging.FileHandler(os.path.join(logdir, 'log_' + str(uuid.uuid4())))
    fh.setFormatter(format)
    logger.addHandler(fh)

    return logger

def load_box_constraints(file):
    with open(file, 'rb') as fp:
        return json.loads(fp.read())

def save_call_log(file, call_log):
    with open(file, 'wb') as fp:
        pickle.dump(call_log, fp)

def get_objective_function(num_epochs, logdir, update_fn = lasagne.updates.sgd):
    '''
    Returns the function for Optunity to optimize. The function returned by get_objective_function
    takes the parameters: x_train, y_train, x_test, and y_test, and any additional kwargs to 
    use as hyper-parameters.

    The objective function runs a DeepSurv model on the training data and evaluates it against the
    test set for validation. The result of the function call is the validation concordance index 
    (which Optunity tries to optimize)
    '''
    def format_to_deepsurv(x, y):
        return {
            'x': x,
            'e': y[:,0].astype(np.int32),
            't': y[:,1].astype(np.float32)
        }

    def get_hyperparams(params):
        hyperparams = {
            'batch_norm': False,
            'activation': 'selu',
            'standardize': True
        }
        # @TODO add default parameters and only take necessary args from params
        # protect from params including some other key

        if 'num_layers' in params and 'num_nodes' in params:
            params['hidden_layers_sizes'] = [int(params['num_nodes'])] * int(params['num_layers'])
            del params['num_layers']
            del params['num_nodes']

        if 'learning_rate' in params:
            params['learning_rate'] = 10 ** params['learning_rate']

        hyperparams.update(params)
        return hyperparams

    def train_deepsurv(x_train, y_train, x_test, y_test,
        **kwargs):
        # Standardize the datasets
        train_mean = x_train.mean(axis = 0)
        train_std = x_train.std(axis = 0)

        x_train = (x_train - train_mean) / train_std
        x_test = (x_test - train_mean) / train_std

        train_data = format_to_deepsurv(x_train, y_train)
        valid_data = format_to_deepsurv(x_test, y_test)

        hyperparams = get_hyperparams(kwargs)

        # Set up Tensorboard loggers
        # TODO improve the model_id for Tensorboard to better partition runs
        model_id = str(hash(str(hyperparams)))
        run_id = model_id + '_' + str(uuid.uuid4())
        logger = TensorboardLogger('hyperparam_search', 
            os.path.join(logdir,"tensor_logs", model_id, run_id))

        network = deepsurv.DeepSurv(n_in=x_train.shape[1], **hyperparams)
        metrics = network.train(train_data, n_epochs = num_epochs, logger=logger, 
            update_fn = update_fn, verbose = False)

        result = network.get_concordance_index(**valid_data)
        main_logger.info('Run id: %s | %s | C-Index: %f | Train Loss %f' % (run_id, str(hyperparams), result, metrics['loss'][-1][1]))
        return result

    return train_deepsurv

def dataframe_to_deepsurv_ds(df, event_col = 'Event', time_col = 'Time'):
    # Extract the event and time columns as numpy arrays
    e = df[event_col].values.astype(np.int32)
    t = df[time_col].values.astype(np.float32)

    # Extract the patient's covariates as a numpy array
    x_df = df.drop([event_col, time_col], axis = 1)
    x = x_df.values.astype(np.float32)
    
    # Return the deep surv dataframe
    return  x,{
        'e' : e,
        't' : t
    }
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
# #Imputation 
# =============================================================================
from sklearn.experimental import enable_iterative_imputer  
from sklearn.impute import IterativeImputer
imp = IterativeImputer(random_state=0, max_iter = 100, imputation_order='random')
imp.fit(temp_features)
temp_features = imp.transform(temp_features)




temp_features = pd.DataFrame(temp_features, columns=feature_list)
temp_features.drop(['TransplantationID'], axis = 1, inplace = True)
feature_list.remove('TransplantationID')
temp_features.drop(['PatientID'], axis = 1, inplace = True)
feature_list.remove('PatientID')


# =============================================================================
# #SMOTE for upsampling
# =============================================================================
from collections import Counter
from imblearn.over_sampling import SMOTE
#print(sorted(Counter(temp_labels).items()))
temp_features, temp_labels = SMOTE().fit_resample(temp_features.loc[:, temp_features.columns != 'Longterm_TransplantOutcome'], temp_features['Longterm_TransplantOutcome'])
print(sorted(Counter(temp_labels).items()))
temp_features = temp_features.join(pd.DataFrame(temp_labels,columns=['Longterm_TransplantOutcome']))


events = temp_features['Longterm_TransplantOutcome'].astype(bool)
for col in temp_features.columns:
    if (temp_features.loc[events, col].var() == 0.0 or temp_features.loc[~events, col].var() == 0.0 ) and col != 'Longterm_TransplantOutcome':
        print('Dropped column ' + col + ' (no variance)')
        temp_features.drop([col], axis=1, inplace=True)
       
        
feature_list = temp_features.columns

logdir = r'T:\tbase\logs'
box = r'T:\git\tbase\DeepSurvHyperParamBoxConstraints.json'
num_evals = 5
update_fn = 'sgd'
num_epochs = 10
num_folds = 5


x,ytemp = dataframe_to_deepsurv_ds(temp_features, event_col = 'Longterm_TransplantOutcome', time_col= 'tenure')
strata = None
ya = np.array(ytemp['e'])
yb = np.array(ytemp['t'])

y = np.stack((ya, yb), axis=1)


NUM_EPOCHS = num_epochs
NUM_FOLDS = num_folds

global main_logger
main_logger = load_logger(logdir)
#main_logger.debug('Parameters: ' + str(args))

box_constraints = load_box_constraints(box)
main_logger.debug('Box Constraints: ' + str(box_constraints))

opt_fxn = get_objective_function(NUM_EPOCHS, logdir, 
    utils.get_optimizer_from_str(update_fn))
opt_fxn = optunity.cross_validated(x=x, y=y, num_folds=NUM_FOLDS,
    strata=strata)(opt_fxn)

main_logger.debug('Maximizing C-Index. Num_iterations: %d' % num_evals)
opt_params, call_log, _ = optunity.maximize(opt_fxn, num_evals=num_evals,
    solver_name='sobol',
    **box_constraints)

main_logger.debug('Optimal Parameters: ' + str(opt_params))
main_logger.debug('Saving Call log...')
print(call_log._asdict())
save_call_log(os.path.join(logdir, 'optunity_log_%s.pkl' % (str(uuid.uuid4()))), call_log._asdict())


