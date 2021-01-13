
# Manipulating CLDF data with `pycldf`

The [`pycldf` package](https://github.com/cldf/pycldf) provides tools and
Python APIs to read and write CLDF datasets.


## Exploring datasets using `pycldf.orm`

Starting with version 1.18, `pycldf` provides a convenient Python API
to interactively (or programmatically) explore CLDF datasets:

```python
from collections import Counter
from tabulate import tabulate
from pycldf import Dataset
```

Now we can instantiate a `pycldf.Dataset` from data on the web:
```python
wals = Dataset.from_metadata('https://raw.githubusercontent.com/cldf-datasets/wals/v2020/cldf/StructureDataset-metadata.json')
```

Note that we use the URL for the raw metadata file of a particular version,
namely the release tagged as `v2020`. For "production" use, e.g. for analyses for
publications, you should use the long-term accessible release on Zenodo
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3731125.svg)](https://doi.org/10.5281/zenodo.3731125), but since the Zenodo deposit contains a zip archive of the
dataset, this would require downloading and unzipping first. So for exploratory
analysis, we enjoy the hassle-free data access by URL, which downloads the data
directly into memory and not to the hard disk.

Now we can look at features we are interested in, using `pycldf`'s ORM (see https://github.com/cldf/pycldf#object-oriented-access-to-cldf-data) ...
```python
feature1 = wals.get_object('ParameterTable', '1A')
```
... count the datapoints by value ...
```python
values = Counter(v.code.name for v in feature1.values)
```
... and look at the result ...
```python
print('\n{}\n\n{}'.format(feature1.name, tabulate(values.most_common())))
```
... which should look as follows:

| value            | #   |
|------------------| ----|
| Average          | 201 |
| Moderately small | 122 |
| Moderately large |  94 |
| Small            |  89 |
| Large            |  57 |


