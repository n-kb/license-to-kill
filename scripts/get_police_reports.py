import requests, time
from bs4 import BeautifulSoup

base_url = "https://www.berlin.de/polizei/polizeimeldungen/archiv/%d/?page_at_1_0=%d"

for year in range(2014, 2018):
	page = 1
	is_404 = False
	while is_404 == False:
		url = base_url % (year, page)
		time.sleep(1)
		r = requests.get(url)
		if r.status_code == 404:
			is_404 = True
		else:
			page += 1
			soup = BeautifulSoup(r.text, 'html.parser')

			for item in soup.findAll("li", {"class": "row-fluid"}):
				title = item.find("a").text
				link = item.find("a").get("href")
				if ("verstorben" in title):
					print(title, "https://www.berlin.de" + link)