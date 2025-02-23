import sys
import json
from pymongo import MongoClient

# Connect to MongoDB
client = MongoClient("mongodb://192.168.0.100:27017/")
db = client["signal_data"]
collection = db["modulation_features"]

# Get the JSON file path from the command line argument
file_path = sys.argv[1]

# Read the data from the JSON file
with open(file_path, 'r') as file:
    data = json.load(file)

# Insert all the documents into MongoDB using insert_many
collection.insert_many(data)

print(f"{len(data)} documents inserted into MongoDB.")
