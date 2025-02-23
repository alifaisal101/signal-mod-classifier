import pymongo
import numpy as np
from sklearn.preprocessing import StandardScaler

# Connect to MongoDB
client = pymongo.MongoClient("mongodb://192.168.0.100:27017/")
db = client["signal_data"]
collection = db["modulation_features"]

# Extract data from MongoDB
cursor = collection.find()

# Prepare the data
X = []  # Features
y = []  # Labels (Modulation Type)

# Define fixed length for arrays
psd_max_len = 81920  # Adjust this based on your data
harmonics_max_len = 400  # Based on the example you gave

# Iterate over all documents and process the features
for doc in cursor:
    features = doc['features']
    
    # Flatten the features into a single 1D list/vector
    feature_vector = []
    
    # Add scalar values to the feature vector
    feature_vector.append(features['duration'])
    feature_vector.append(features['mean'])
    feature_vector.append(features['rms'])
    feature_vector.append(features['peakToPeak'])
    feature_vector.append(features['crestFactor'])
    feature_vector.append(features['peakFrequency'])
    feature_vector.append(features['bandwidth'])
    feature_vector.append(features['meanAbsDev'])
    feature_vector.append(features['skewness'])
    feature_vector.append(features['kurtosis'])
    feature_vector.append(features['entropy'])
    feature_vector.append(features['autocorrPeak'])
    
    # Pad the psd array to a fixed length
    psd = features['psd']
    if len(psd) < psd_max_len:
        psd = psd + [0] * (psd_max_len - len(psd))  # Pad with zeros
    else:
        psd = psd[:psd_max_len]  # Truncate if necessary
    feature_vector.extend(psd)
    
    # Pad the harmonics array to a fixed length
    harmonics = features['harmonics']
    if len(harmonics) < harmonics_max_len:
        harmonics = harmonics + [0] * (harmonics_max_len - len(harmonics))  # Pad with zeros
    else:
        harmonics = harmonics[:harmonics_max_len]  # Truncate if necessary
    feature_vector.extend(harmonics)
    
    # Append the flattened feature vector to X
    X.append(feature_vector)
    
    # Map modulation types to numerical labels
    if doc['type'] == 'ask':
        y.append(0)
    elif doc['type'] == 'bpsk':
        y.append(1)
    elif doc['type'] == 'qpsk':
        y.append(2)
    elif doc['type'] == 'fsk':
        y.append(3)

# Convert lists to numpy arrays
X = np.array(X)
y = np.array(y)

# Normalize the features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Save X and y to disk for later use
np.save('X_data_scaled.npy', X_scaled)
np.save('y_labels.npy', y)

print(f"Data loaded and processed: {X.shape[0]} samples")
