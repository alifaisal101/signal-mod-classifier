import numpy as np
import matplotlib.pyplot as plt
from keras.models import load_model
from sklearn.metrics import accuracy_score

model = load_model('modulation_classifier.h5')

datasets = [
    ('X_data_scaled.npy', 'y_labels.npy'),
    ('X_data_scaled_snr_25_30.npy', 'y_labels_snr_25_30.npy'),
    ('X_data_scaled_snr_20_25.npy', 'y_labels_snr_20_25.npy'),
    ('X_data_scaled_snr_15_20.npy', 'y_labels_snr_15_20.npy'),
    ('X_data_scaled_snr_10_15.npy', 'y_labels_snr_10_15.npy'),
    ('X_data_scaled_snr_5_10.npy', 'y_labels_snr_5_10.npy'),
    ('X_data_scaled_snr_0_5.npy', 'y_labels_snr_0_5.npy')
]

modulation_types = {0: 'ASK', 1: 'BPSK', 2: 'QPSK', 3: 'FSK'}

accuracies = []
dataset_names = [
    'No Noise', 'SNR 30-25', 'SNR 25-20', 'SNR 20-15', 'SNR 15-10', 'SNR 10-5', 'SNR 5-0'
]

for data_file, label_file in datasets:
    print(f"\nTesting on {data_file} and {label_file}...")

    X_test = np.load(data_file)
    y_test = np.load(label_file)

    predictions = np.argmax(model.predict(X_test), axis=1)

    accuracy = accuracy_score(y_test, predictions)
    accuracies.append(accuracy)
    print(f"Test Accuracy on {data_file}: {accuracy * 100:.2f}%")

    for i in range(10):
        true_label = modulation_types[y_test[i]]
        predicted_label = modulation_types[predictions[i]]
        print(f"Sample {i+1}: True Label = {true_label}, Predicted Label = {predicted_label}")

plt.figure(figsize=(10, 6))
plt.plot(dataset_names, accuracies, marker='o', linestyle='-', color='b', label='Accuracy')
plt.xlabel('Noise Level')
plt.ylabel('Accuracy')
plt.title('Accuracy vs Noise Level')
plt.xticks(rotation=45)
plt.grid(True)
plt.tight_layout()

plt.show()
