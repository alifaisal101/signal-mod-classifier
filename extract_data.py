import pymongo
import numpy as np
from sklearn.preprocessing import StandardScaler
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Process modulation feature data.")
parser.add_argument('--verbose', action='store_true', help="Enable verbose output.")
args = parser.parse_args()

# Connect to MongoDB
client = pymongo.MongoClient("mongodb://192.168.0.100:27017/")
db = client["signal_data_snr_25_30"]
collection = db["modulation_features"]

# Extract data from MongoDB
cursor = collection.find()

# Prepare the data
X = []  # Features
y = []  # Labels (Modulation Type) bpsk fsk psk qpsk

for doc in cursor:
    if args.verbose:
        print(f"Processing document with _id: {doc['_id']}")
    
    features = doc['features']
    
    feature_vector = []
    
    feature_vector.append(features['duration'])
    feature_vector.append(features['mean'])
    feature_vector.append(features['rms'])
    feature_vector.append(features['peakToPeak'])
    feature_vector.append(features['crestFactor'])
    feature_vector.append(features['peakFrequency'])
    
    # Some data has bandwidth as an empty array, therefor, it's substituted for 0 if it doesn't have a value
    bandwidth = features['bandwidth']
    if isinstance(bandwidth, list) and len(bandwidth) == 0:
        bandwidth = 0 
    elif isinstance(bandwidth, (float, int)):
        pass
    else:
        bandwidth = 0
    
    feature_vector.append(bandwidth)
    
    feature_vector.append(features['meanAbsDev'])
    feature_vector.append(features['skewness'])
    feature_vector.append(features['kurtosis'])
    feature_vector.append(features['entropy'])
    feature_vector.append(features['autocorrPeak'])
    
    if args.verbose:
        print(f"Feature vector content: {feature_vector}")
        for idx, val in enumerate(feature_vector):
            print(f"Index {idx}: Type = {type(val)}, Value = {val}")
    
    if len(feature_vector) != 12:
        if args.verbose:
            print(f"Error: Feature vector has an incorrect length ({len(feature_vector)}). Document ID: {doc['_id']}")
    else:
        X.append(feature_vector)
    
    if doc['type'] == 'ask':
        y.append(0)
    elif doc['type'] == 'bpsk':
        y.append(1)
    elif doc['type'] == 'qpsk':
        y.append(2)
    elif doc['type'] == 'fsk':
        y.append(3)

for idx, feature_vector in enumerate(X):
    if len(feature_vector) != 12:
        print(f"Warning: Feature vector at index {idx} has incorrect length: {len(feature_vector)}")

if args.verbose:
    print(f"X type: {type(X)}")
    print(f"First element of X: {X[0]}")
    print(f"Number of elements in X: {len(X)}")

try:
    X = np.array(X)
    y = np.array(y)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    np.save('X_data_scaled_snr_25_30.npy', X_scaled)
    np.save('y_labels_snr_25_30.npy', y)

    if args.verbose:
        print(f"Data loaded and processed: {X.shape[0]} samples")
except Exception as e:
    print(f"Error converting X to numpy array: {e}")
