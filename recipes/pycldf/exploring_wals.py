from collections import Counter
from tabulate import tabulate
from pycldf import Dataset

# Retrieve the WALS v2020 data from GitHub.
# (The proper release on Zenodo is zipped and would need to be downloaded first):
wals = Dataset.from_metadata('https://raw.githubusercontent.com/cldf-datasets/wals/v2020/cldf/StructureDataset-metadata.json')
# Get feature 1A ...
feature1 = wals.get_object('ParameterTable', '1A')
# ... and look at its values:
values = Counter(v.code.name for v in feature1.values)
print('\n{}\n\n{}'.format(feature1.name, tabulate(values.most_common(), tablefmt='github')))


