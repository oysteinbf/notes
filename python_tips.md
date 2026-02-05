Async
---

```python
import asyncio
import aiohttp
import json


async def get_data(session, ssn_chunk):
    url = "https://example.com/api/v1/check_membership"
    headers = {'content-type': 'application/json'}
    auth = aiohttp.BasicAuth('user', 'XXX')
    data = {"ssn_list": ssn_chunk, 'date': '2023-06-07'}
    async with session.get(url, headers=headers, auth=auth, params=data) as resp:
        return await resp.json()

async def main():
    ssn_list = ['1','2','3','4','5','6','7','8','9','10','11','12']
    
    chunk_size = 20
    ssn_chunks = [ssn_list[i:i + chunk_size] for i in range(0, len(ssn_list), chunk_size)]
    
    async with aiohttp.ClientSession() as session:
        tasks = []
        for ssn_chunk in ssn_chunks:
            ssn_chunk = ','.join(ssn_chunk)
            task = asyncio.ensure_future(get_data(session, ssn_chunk))
            tasks.append(task)
        responses = await asyncio.gather(*tasks)  # This collects all the responses

    for response in responses:
        # result = json.loads(response)
        # Now process 'result'...
        print(response)

# Run the async main function:
asyncio.run(main())
```

Kjører koden med chunk_size = 20, som gir følgende logg for kallet:
ip_addr - user [07/Jun/2023:12:50:41 +0200] "GET /api/v1/check_membership?ssn_list=1,2,3,4,5,6,7,8,9,10,11,12&date=2023-06-07 HTTP/1.1" 200 568 0.017

Endrer så til chunk_size = 5, som gir følgende logg:
ip_addr - user [07/Jun/2023:12:52:03 +0200] "GET /api/v1/check_membership?ssn_list=11,12&date=2023-06-07 HTTP/1.1" 200 127 0.005
ip_addr - user [07/Jun/2023:12:52:03 +0200] "GET /api/v1/check_membership?ssn_list=6,7,8,9,10&date=2023-06-07 HTTP/1.1" 200 258 0.011
ip_addr - user [07/Jun/2023:12:52:03 +0200] "GET /api/v1/check_membership?ssn_list=1,2,3,4,5&date=2023-06-07 HTTP/1.1" 200 257 0.012

XML
---

```python
import pandas as pd
import xml.etree.ElementTree as ET

# Hent f.eks. fra database og inn i en dataframe
df = pd.DataFrame({
        "STUDENTNUMMER": ["123456", "789012"],
        "NAVN": ["Ola Nordmann", "Kari Nordmann"],
        "KURS_A": ["Bestått", "Ikke bestått"],
        "KURS_B": ["Bestått", "Bestått"],
        "KURS_C": [None, "Ikke bestått"]})

root = ET.Element("Studentfil")
for i, row in df.iterrows():
    student = ET.SubElement(root, "student")
    ET.SubElement(student, "studentnummer").text = row["STUDENTNUMMER"]
    ET.SubElement(student, "navn").text = row["NAVN"]

    if row["KURS_A"] is not None:
        Kurs = ET.SubElement(student, "Kurs")
        ET.SubElement(Kurs, "Kursnavn").text = "A"
        ET.SubElement(Kurs, "Status").text = row["KURS_A"]

    if row["KURS_B"] is not None:
        Kurs = ET.SubElement(student, "Kurs")
        ET.SubElement(Kurs, "Kursnavn").text = "B"
        ET.SubElement(Kurs, "Status").text = row["KURS_B"]

    if row["KURS_C"] is not None:
        Kurs = ET.SubElement(student, "Kurs")
        ET.SubElement(Kurs, "Kursnavn").text = "C"
        ET.SubElement(Kurs, "Status").text = row["KURS_C"]

tree = ET.ElementTree(root)
tree.write("studentfil.xml", encoding='utf-8')
```

XML-validering

```python
# NB! Egen pakke som må lastes ned med pip
# https://lxml.de/validation.html#xmlschema
from lxml import etree

lxml_tree = etree.parse('myfile.xml')
xmlschema = etree.XMLSchema(file='myschema.xsd')
print(xmlschema.validate(lxml_tree))
```

Pitfalls
---

Default arguments in Python are evaluated once when the function is defined, not each time the function is called.

```python
def func(arg=[]):
	arg.append(1)
	print(arg)
func()
func()
func()
```
Gives

[1]
[1, 1]
[1, 1, 1]


Python packages
---


Check for vulnerabilities with [pip-audit](https://pypi.org/project/pip-audit/)
