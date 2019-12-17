#!/usr/bin/python3

import os
import sys
import urllib
import tempfile
import WDL
import json

async def read_source(uri, path, importer):
    if uri.startswith("http:") or uri.startswith("https:"):
        fn = os.path.join(tempfile.mkdtemp(prefix="miniwdl_import_uri_"), os.path.basename(uri))
        urllib.request.urlretrieve(uri, filename=fn)
        with open(fn, "r") as infile:
            return WDL.ReadSourceResult(infile.read(), uri)
    elif importer and (
        importer.pos.abspath.startswith("http:") or importer.pos.abspath.startswith("https:")
    ):
        assert not os.path.isabs(uri), "absolute import from downloaded WDL"
        return await read_source(urllib.parse.urljoin(importer.pos.abspath, uri), [], importer)
    return await WDL.read_source_default(uri, path, importer)

url = sys.argv[1]
doc = WDL.load(url, check_quant=True, read_source=read_source)
meta = str(doc.workflow.meta)
meta = meta.replace("'{", "{")
meta = meta.replace("}'", "}")
meta = meta.replace("'", '"')
meta = json.loads(meta.replace("\'", '"'))
with open('meta.json', 'w') as outfile:
    json.dump(meta, outfile)
