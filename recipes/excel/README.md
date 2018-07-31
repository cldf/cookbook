> I am a field linguist with a spreadsheet of words and their meanings that I collected long ago. I would like to make the data available for re-use by adopting the CLDF format. Where do I start?

# Starting Point

For this scenario, let's assume a simple spreadsheet file with the following structure:

|ID |Chinese|English|
|---|-------|----------|
|1  |天      | sky
|2  |太阳     | sun
|3  |月亮     | moon
|4  |星星     |star
|5  |云      |cloud

You can find a corresponding Excel file [here](sample-data/Simple_Wordlist.xlsx). This sample data is taken from the first 5 rows of the [Allen-2007-500 concept list](http://concepticon.clld.org/contributions/Allen-2007-500).

In order to make this simple (singular) spreadsheet into a CLDF-conformant data set, we have to obey the three principle components that make a CLDF data set (see also the [CLDF repository](https://github.com/cldf/cldf)):

- a set of UTF-8 encoded CSV files (our above-mentioned spreadsheet, see also CSV caveats below)
- a JSON file that describes the spreadsheet in detail (a CLDF Metadata file),
  - in particular including a dc:conformsTo property that points to the CLDF module that we're using as a basis for describing our spreadsheet.

## Excel to CSV

Please note that Excel to proper CSV is somewhat tricky, since the delimiter that is being used for the export can only be specified within the regional settings of the machine (see for example [here](https://superuser.com/questions/606272/how-to-get-excel-to-interpret-the-comma-as-a-default-delimiter-in-csv-files)).

Additionally, take special note of the exporting options with respect to the encoding schemes. See [this screenshot](screenshots/01_excel_to_csv.jpeg) for the option that I'm using for this tutorial (macOS High Sierra, Microsoft Excel for Mac 16.15).

The resulting CSV file can be found [here](sample-data/Simple_Wordlist.csv). Opening the file with a simple text editor (Notepad, TextEdit, etc.) reveals the default CSV separator employed by Excel, `;`. We can either change this here in the file (e.g. by using search and replace) or change the delimiter in the JSON file that describes our data for the CLDF framework. For the sake of better understanding the CLDF JSON file, we're going to do the latter.

# Find an Appropriate CLDF Module

In order to satisfy the other two requirements (a JSON file describing our table, a `dc:conformsTo` property) we need to figure out what CLDF modules fit our data (or go the route of creating a custom module, which goes beyond the scope of this basic introduction). 

For this purpose, we can browse the [CLDF ontology](http://cldf.clld.org/v1.0/terms.rdf) and the [modules in the CLDF repository](https://github.com/cldf/cldf/tree/master/modules). Note that the [individual module descriptions](https://github.com/cldf/cldf/tree/master/modules) provide further guidance for finding something that fits your specific use case.

For the purpose of the above-mentioned scenario, the [Wordlist module](https://github.com/cldf/cldf/tree/master/modules/Wordlist) seems appropriate.

## Download/Inspect the Module's JSON

Download and/or inspect the JSON file accompanying the module of your choice. For the purpose of this tutorial, I'm going to download the [Wordlist-metadata.json](https://github.com/cldf/cldf/blob/master/modules/Wordlist/Wordlist-metadata.json) to a `cldf` folder (also in this tutorial's directory) and rename it to `MyData.json`.

### Anatomy of a CLDF Module JSON

Opening the [JSON file](cldf/MyData.json) reveals a simple structure:

- there is supposed to be a single file (look for `"url": "forms.csv"`) called `forms.csv` that ...
- has got one table (analogous to one sheet in Excel) (look for `"tables"`) ...
- that can have certain columns (look for `"tableSchema"`).

Inspecting the `"tableSchema"` more closely reveals that there has to be (look for `"required"`)

- a column `ID`,
- a column `Language_ID`,
- a column `Parameter_ID`,
- and a column `Form`.

Additionally, there can be
 
- a column `Segments`,
- a column `Comment`,
- and a column `Source`, separated by `;`.

### Implementing the Requirements

Note that a data set can be CLDF-conformant without strictly following the default modules (see also [here](https://github.com/cldf/cldf#cldf-modules)). For the purpose of this tutorial, we'll stick to the defaults as closely as possible. However, you're free to customise! This is the CLDF spirit!

First, I move the JSON file and the CSV file into on directory ([cldf](cldf/.) in this tutorial).

Next, I edit [MyData.json](cldf/MyData.json) to fit my data set:

```
"url": "Simple_Wordlist.csv"
```

(Our data set is not in `form.csv` but rather `Simple_Wordlist.csv`.)

```
"dialect": {
    "commentPrefix": null,
    "delimiter": ";"
},
```

(Our data set is not comma-separated, but semicolon-separated.)

```
{
    "name": "Language_ID",
    "virtual": true,
    "propertyUrl": "http://cldf.clld.org/v1.0/terms.rdf#languageReference",
    "valueUrl": "comm1247"
}
```

(Rather than adding a language column that repeats the same Glottocode again and again in each row, I add a [virtual column](https://github.com/cldf/cldf/blob/master/faq.md#all-my-data-is-about-the-same-language-do-i-still-have-to-specify-a-language_id-for-each-row) that specifies one and the same value for all rows. Note that this has to be the very last column in the JSON file. See [MyData.json](cldf/MyData.json) if you're not sure how that's supposed to look like.)

```
{
    "name": "Parameter_ID",
    "required": true,
    "propertyUrl": "http://cldf.clld.org/v1.0/terms.rdf#parameterReference",
    "datatype": "string",
    "titles": "English"
},
```

(The parameter or the concept I'm describing in the table is found in the `English` column. This can be specified by adding `"titles": "English"`.)

```
{
    "name": "Form",
    "required": true,
    "propertyUrl": "http://cldf.clld.org/v1.0/terms.rdf#form",
    "datatype": "string",
    "titles": "Chinese"
},
```

(The form for which I'm providing information for can be found in `Chinese`, thus `"titles": "Chinese"`.)

With these changes, the joint-venture of [MyData.json](cldf/MyData.json) and [Simple_Wordlist.csv](cldf/Simple_Wordlist.csv) comprise a CLDF-conformant data set. This data set can be validated by running (in the directory with `MyData.json`):

```
cldf validate MyData.json
```

(See the [pycldf](https://github.com/cldf/pycldf) repository for more information about the `cldf` command.)
