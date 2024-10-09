import requests
import pandas as pd
from kafka import KafkaProducer
from time import sleep
from json import dumps

# API endpoint and parameters
# this api endpoint is themoviedb which consists of movie details which is public.
url = 'https://api.themoviedb.org/3/movie/top_rated'
# you can keep apikey as a secret by replacing hardcoded values with environment variables
# as this is demo, i have hardcoded values
params = {
    'api_key': 'aaa7de53dcab3a19afed86880f364e54', 
    'language': 'en-US',
    'page': 1
}

# Fetch data from TMDb API
response = requests.get(url, params=params)
data = response.json()
movies = data['results']

# Convert to DataFrame and save to CSV
df = pd.DataFrame(movies)
# df.to_csv('top_rated_movies.csv', index=False) #to create the output in csv file uncomment this line

# Initialize Kafka producer
producer = KafkaProducer(
    bootstrap_servers=['13.201.51.216:9092'],  # Replace 'localhost' with your Kafka broker's IP
    value_serializer=lambda x: dumps(x).encode('utf-8')
)

# Send a test message to the Kafka topic 'krupakar'
producer.send('krupakar', value={'key': 'value'})

# Continuously sample and print data
while True:
    dict_stock = df.sample(1).to_dict(orient="records")[0]
    producer.send('krupakar', value=dict_stock)
    print(dict_stock)  # Print the sampled data
    sleep(1)

# Flush the producer to ensure all messages are sent
producer.flush()

