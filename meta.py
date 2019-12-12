import WDL
doc = WDL.load(sys.argv[1])
meta = str(doc.workflow.meta)
meta = meta.replace("'{", "{")
meta = meta.replace("}'", "}")
meta = meta.replace("'", '"')
with open('meta.json', 'w') as outfile:
    json.dump(meta, outfile)