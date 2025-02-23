from keras.models import load_model

# Load the trained model
model = load_model('modulation_classifier.h5')

# Use the model to make predictions
predictions = model.predict(X_test)
