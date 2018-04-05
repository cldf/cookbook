
# CLDF and TypeCraft

Several proposals to encode Interlinear Glossed Text (IGT) have been made
over the last 20 years. Among them the 
- [Leipzig Glossing Rules (LGR)](https://www.eva.mpg.de/lingua/resources/glossing-rules.php) - a set of rules to encode IGT in plain text.
- XIGT
- [TypeCraft](https://typecraft.org/tc2wiki/Main_Page) - a repository for IGT data including a custom XML export format.
- CLDF's [Examples component](https://github.com/cldf/cldf/tree/master/components/examples).

This recipe shows how to convert a TypeCraft IGT corpus to a CLDF dataset. Since
there is no CLDF module for text collections yet (although this recipe may serve
as blueprint for one), we create a generic CLDF dataset, introducing a custom
table storing data about *texts*, i.e. collections of related IGT phrases within
a corpus.

In the following, we use the Release 1.0 of thw [Akan Corpus](https://typecraft.org/tc2wiki/The_TypeCraft_Akan_Corpus).


## Requirements

The Python script [to_cldf.py](to_cldf.py) uses
- the [`typecraft_python`](https://pypi.python.org/pypi/typecraft_python) package - to parse TypeCraft XML
- the [`pycldf`](https://pypi.python.org/pypi/pycldf) package to create CLDF datasets.

Both packages can be installed using `pip`.


## Usage

The Python script [to_cldf.py](to_cldf.py) expects the path to a TypeCraft XML file
as parameter, i.e. it must be invoked like
```
python to_cldf.py Akan_release1.xml
```

This will create a directory [`cldf`](cldf) in the current working directory, containing the
files making up the CLDF dataset.

It will also print LGR serializations of the data to the screen.


## Notes

Converting the CLDF data back to TypeCraft XML is possible, but would require some heuristics because TypeCraft distinguishes between *meaning* and *gloss* whereas LGR concatenates meaning and other metalanguage elements.

Now that we have the corpus available as CLDF, off-the-shelf CSV tools like
`csvkit` can be used to analyze the data. E.g. a search for examples containing the gloss element `ANIM` can be done as follows:

```
$ csvgrep -c Gloss -m "ANIM" cldf/examples.csv | csvgrep -c Gloss -m "INANIM" -i | csvcut -c Primary_Text,Gloss
Primary_Text,Gloss
Abɔfra a ɔbɛkyeaa me no kɔ,SG-child.SBJ\\tREL\\tshe--greet-\\tme.1SG\\t3SG.ANIM\\tgo
Kaja dɔ osuani no,SBJ\\tlove\\t3SG-learn-ANIM\\tDEF
Kofi bɛtɔn no ɔkyena,Kofi.SBJ\\tFUT.H-sell\\t3SG.OBJ.ANIM\\ttomorrow
Kofi bɛkyea no,K.SBJ\\tFUT.H-greet\\t3SG.ANIM.OBJ
kofi bɛmoa no,Kofi.SBJ\\tFUT.H-crumple\\t3SG.OBJ.ANIM
kofi bɛsɛe no,Kofi.SBJ\\twill.FUT.H-destroy\\t3SG.OBJ.ANIM
```
