import pandas as pd

df = pd.read_csv("figure2.csv")

removedElements = dict()
for index,row in df.iterrows():
    inst = row['inst']
    name = row['name']
    if inst == "EMPTY" and name == "EMPTY":
        continue
    if inst in removedElements or name in removedElements:
        continue
    if inst == "EMPTY":
        removedElements[name] = row['uint']
    if name == "EMPTY":
        removedElements[inst] = row['uint']

first10pairs = {k: removedElements[k] for k in list(removedElements)[:10]}

for l in first10pairs:
    print(l + ": "+str(first10pairs[l]))

