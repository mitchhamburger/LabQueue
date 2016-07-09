import requests
from bs4 import BeautifulSoup

url = "http://www.yellowpages.com/search?search_terms=coffee&geo_location_terms=Grand+Island%2C+NY"
r = requests.get(url)

soup = BeautifulSoup(r.content)

links = soup.find_all("a")

g_data = soup.find_all("div", {"class": "info"})

for item in g_data:
    print item
