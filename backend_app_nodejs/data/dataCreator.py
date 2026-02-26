import json
from faker import Faker
import random
import hashlib
import datetime

fake = Faker()

data = []

for i in range(1, 101):
    firstname = fake.first_name()
    lastname = fake.last_name()
    location = f"{random.uniform(31.5, 31.6):.7f}, {random.uniform(74.3, 74.4):.7f}"
    gender = random.choice(["Male", "Female"])
    email = fake.email()
    password = fake.password()
    number = fake.phone_number()
    role = random.choice(["Rescue", "Police", "Ambulance", "Road Assistance"])
    profilepic = {"type": "Buffer", "data": []}  # assuming you'll populate this later
    created_at = fake.date_time_between(start_date="-1y", end_date="now").strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    updated_at = fake.date_time_between(start_date="-1y", end_date="now").strftime("%Y-%m-%dT%H:%M:%S.%fZ")

    entry = {
        "id": i,
        "firstname": firstname,
        "lastname": lastname,
        "location": location,
        "gender": gender,
        "email": email,
        "password": password,
        "number": number,
        "role": role,
        "profilepic": profilepic,
        "createdAt": created_at,
        "updatedAt": updated_at
    }

    data.append(entry)

with open('dummy_data.json', 'w') as f:
    json.dump(data, f, indent=4)
