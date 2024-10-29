from kafka import KafkaConsumer
from time import sleep
from json import dumps,loads
import json
from s3fs import S3FileSystem
from datetime import datetime


consumer = KafkaConsumer(
    'krupakar',
     bootstrap_servers=['b-1.mskdev.zos4m9.c3.kafka.ap-south-1.amazonaws.com:9092', 'b-2.mskdev.zos4m9.c3.kafka.ap-south-1.amazonaws.com:9092'], #kafka brokers address.
    value_deserializer=lambda x: loads(x.decode('utf-8')))

s3 = S3FileSystem()
for i in consumer:
    # Generate a timestamp in the format YYYYMMDD_HHMMSS
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    # Create a filename using the timestamp
    filename = "s3://kafka-poc-df/movie_ratings_data_{}.json".format(timestamp)
    
    # Write the message to S3
    with s3.open(filename, 'w') as file:
        json.dump(i.value, file)
    
    # Optional: sleep to avoid timestamp collisions (optional based on your use case)
    sleep(1)  # Sleep for 1 sec