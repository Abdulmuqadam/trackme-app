import json

def extract_locations(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)

    locations = []
    for entry in data:
        location_str = entry.get('location')
        if location_str:
            lat, lng = location_str.split(', ')
            location = {
                'lat': float(lat),
                'lng': float(lng)
            }
            locations.append(location)

    return locations

# Example usage
file_path = 'data/dummy_data.json'
locations = extract_locations(file_path)

# Print locations in the required format
for location in locations:
    print("{ lat: " + str(location['lat']) + ", lng: " + str(location['lng']) + " },")
