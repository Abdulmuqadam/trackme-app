import json
import requests
import time

# url = 'http://127.0.0.1:3000/api/facilitators/signup'
url = 'https://backend.prometheansempiremedia.com/api/facilitators/signup'

def post_data(url, data):
    headers = {'Content-Type': 'application/json'}
    response = requests.post(url, data=json.dumps(data), headers=headers)
    return response

with open('data/dummy_data.json', 'r') as file:
    data = json.load(file)

for i in range(len(data)):        
    if i % 2 == 0:
        response = post_data(url, data[i])        
    else:
        response = post_data(url, data[-(i + 1)])        
    if response.status_code == 200:
        print("Data posted successfully:", data[i])
    else:
        print("Failed to post data:", data[i])
    time.sleep(1)