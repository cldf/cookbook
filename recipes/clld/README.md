# Serving CLDF data from a `clld` app

Since the CLDF data model was informed by the database schema of the
[clld toolkit](https://github.com/clld/clld), it is not surprising that
`clld` apps are well suited to serve CLDF data on the web (see for example [WALS Online](https://wals.info), which serves the [WALS CLDF StructureDataset](https://doi.org/10.5281/zenodo.3731125), or [Dictionaria](https://dictionaria.clld.org) which serves the [CLDF Dictionaries submitted to the Dictionaria Zenodo Community](https://zenodo.org/communities/dictionaria/)). 

As an example, we'll go through the steps necessary to create an app
serving [Marc Tang's dataset of classifiers and plural markers](https://doi.org/10.5281/zenodo.3889881) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3889881.svg)](https://doi.org/10.5281/zenodo.3889881).


## Bootstrapping a `clld` app

The easiest way to get started with a `clld` app serving a CLDF dataset is
by bootstrapping the codebase running `clld create`:

1. Create a fresh virtual environment for the app project and activate it:
   ```shell script
   python -m virtualenv myenv
   source myenv/bin/activate
   ```
2. Install `clld` in this environment:
   ```shell script
   pip install "clld>=7.1.1"
   ```
3. Install `cookiecutter` (which is needed for creating the app skeleton):
   ```shell script
   pip install cookiecutter
   ```
4. Create the project skeleton (run `clld create -h` for help on command options):
   ```shell script
   clld create myapp cldf_module=StructureDataset
   ```
   We chose `cldf_module=StructureDataset`, because Tang's dataset contains
   typological data of the "standard" questionnaire format, which is best
   encoded as `StructureDataset`.

The project directory you just created should look like this:
```shell script
$ tree myapp/
myapp/
├── CONTRIBUTING.md
├── development.ini
├── MANIFEST.in
├── myapp
│   ├── adapters.py
│   ├── appconf.ini
│   ├── assets.py
│   ├── datatables.py
│   ├── __init__.py
│   ├── interfaces.py
│   ├── locale
│   │   └── myapp.pot
│   ├── maps.py
│   ├── models.py
│   ├── scripts
│   │   ├── initializedb.py
│   │   ├── __init__.py
│   ├── static
│   │   ├── download
│   │   ├── project.css
│   │   └── project.js
│   ├── templates
│   │   ├── dataset
│   │   │   └── detail_html.mako
│   │   ├── myapp.mako
│   │   └── parameter
│   │       └── detail_html.mako
│   ├── tests
│   │   ├── conftest.py
│   │   ├── test_functional.py
│   │   └── test_selenium.py
│   └── views.py
├── requirements.txt
├── setup.cfg
├── setup.py
└── tox.ini
```

A `clld` app (i.e. the code in the "inner" `myapp` directory) is a regular [python package](https://docs.python.org/3/tutorial/modules.html#packages). To make this package known (i.e. accessible/importable in python code), we have to install it. We'll do this as ["editable" install](https://pip.pypa.io/en/stable/reference/pip_install/#editable-installs) and including the development and test dependencies:
```shell script
cd myapp
pip install -r requirements.txt
```


## Loading the CLDF data into the app's database

Loading data into a `clld` app's database is done through code in `scripts/initializedb.py`. This code will be executed when the `clld initdb` command is run. If a skeleton has been created passing a CLDF module for the `cldf_module` variable, exemplary code showing how to iterate over rows in CLDF tables and insert corresponding objects in the database will be inserted into `scripts/initializedb.py`.
Thus, running `clld initdb` right away will already give us a working - if basic - app.

So, we retrieve the data from Zenodo:
```shell script
cd ..
curl -o tangclassifiers.zip "https://zenodo.org/record/3889881/files/cldf-datasets/tangclassifiers-v1.zip?download=1"
unzip tangclassifiers.zip
```
The CLDF dataset is in the `cldf` subdirectory:
```shell script
tree cldf-datasets-tangclassifiers-105b8f2/cldf
cldf-datasets-tangclassifiers-105b8f2/cldf
├── codes.csv
├── languages.csv
├── parameters.csv
├── requirements.txt
├── sources.bib
├── StructureDataset-metadata.json
└── values.csv
```

The code in `scripts/initializedb.py` also expects access to data of the [Glottolog](https://glottolog.org) language catalog to enrich the data in the app, e.g. adding family affiliations for the languages in the sample. Thus we have to clone https://github.com/glottolog/glottolog or download a released version [from Zenodo](https://doi.org/10.5281/zenodo.596479):
```shell script
curl -o glottolog.zip "https://zenodo.org/record/3754591/files/glottolog/glottolog-v4.2.1.zip?download=1"
unzip glottolog.zip
```

Now we are ready to run
```shell script
cd myapp
clld initdb \
--glottolog ../glottog-glottolog-d9da5e2/ \
--cldf ../cldf-datasets-tangclassifiers-105b8f2/cldf/StructureDataset-metadata.json \
development.ini
```
The following line can be used too, in case the previous version does not work for you
```shell script
clld initdb development.ini --cldf ~/cldf-datasets-tangclassifiers-105b8f2/cldf/StructureDataset-metadata.json --glottolog ~/glottolog-glottolog-d9da5e2/
```

and start the app at http://localhost:6543 via
```shell script
pserve development.ini
```

We can also run the test suite, which will be useful for further development of the app:
```shell script
pytest
```
