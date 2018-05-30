# Reading and Writing CLDF Wordlist Data with LingPy

Exporting LingPy's wordlist format to CLDF is straightforward:

```
>>> from lingpy import *
>>> from lingpy.tests.util import test_data
>>> from lingpy.convert.cldf import to_cldf, from_cldf
>>> wl = Wordlist(test_data('KSL.qlc'))
>>> to_cldf(wl)
```

Similarly, reading a wordlist, is as straighforward as pointing to the metadata-file.

```
>>> wl = from_cldf('cldf/Wordlist-metadata.json')
```

This makes it also possible to compare quickly from CLDF to Nexus and a couple of other formats:

```
>>> from lingpy.convert.strings import write_nexus
>>> mb = write_nexus(wl, 'mrbayes', filename='ksl-mrbayes.nex')
>>> beast = write_nexus(wl, 'beastwords', filename='ksl-beast.nex')
```

For more information, compare our concise LingPy tutorial ([List et al. forthcoming](http://lingulist.de/documents/papers/list-et-al-2018-lingpy-tutorial.pdf)), or the official [LingPy reference](http://lingpy.org/news.html#adding-support-to-read-cldf).
