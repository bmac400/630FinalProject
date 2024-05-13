import pandas as pd

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.


df = pd.read_csv("figure15.csv")
removedElements = dict()
for index,row in df.iterrows():
    inst = row['inst']
    name = row['name']
    city = row['city']
    if inst == "EMPTY" and name == "EMPTY" and city == "EMPTY":
        continue
    if inst in removedElements or name in removedElements or city in removedElements:
        continue
    if inst == "EMPTY" and city == "EMPTY":
        removedElements[name] = row['uint']
    if name == "EMPTY" and city == "EMPTY":
        removedElements[inst] = row['uint']
    if name == "EMPTY" and inst == "EMPTY":
        removedElements[city] = row['uint']
first10pairs = {k: removedElements[k] for k in list(removedElements)[:10]}

for l in first10pairs:
    print(l + ": "+str(first10pairs[l]))

