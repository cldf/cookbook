# Working with CLDF data in R

These scripts illustrate how to use basic R (i.e. without any external dependencies, packages, etc.) to work with CLDF data sets. `merge()` and the `df[filter$condition %in% filter2$condition,]` construct are used to combine the different data sources and perform basic queries and filtering tasks.

**Note:** While accessing CLDF data using standard data analysis tools as shown here is easy, this approach should be combined with consultation of the [JSON metadata](https://github.com/cldf/cldf/blob/master/README.md#cldf-metadata-file) supplied with a CLDF dataset, to verify assumptions regarding syntax (e.g. the [CSV dialect](https://www.w3.org/TR/2015/REC-tabular-metadata-20151217/#dialect-descriptions)) and semantics (e.g. the mapping of column names to [CLDF properties](http://cldf.clld.org/v1.0/terms.rdf)) of the data files. Such issues can be circumvented by loading the CLDF data into a SQLite using [pycldf's `cldf createdb` command](https://github.com/cldf/pycldf#converting-a-cldf-dataset-to-an-sqlite-database) and then accessing the data as shown [below](#working-with-cldf-via-sqlite)

- [simple_access_to_values.R](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/simple_access_to_values.R) (or its [notebook version](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/simple_access_to_values.ipynb)) illustrates a very basic analysis on the basis of the WALS CLDF dump.

- [wals_ids_comparison.R](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/wals_ids_comparison.R) (or its [notebook version](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/wals_ids_comparison.ipynb)) illustrates, in a more involved fashion, how to filter and analyse different CLDF dumps together (WALS and IDS, in this case).

- [typology_visualisation.R](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/typology_visualisation.R), a more involved example, outlining how to access, merge, filter, and post-process data for visualisation purposes. See also the associated [helper file](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/visualisation_helper.R) with all the functions that are being used in the example. This is based on coded provided by @bambooforest, [here](https://github.com/bambooforest/visualizing-typology-data/blob/master/procedure.R).


## Working with CLDF via SQLite

As an example, we'll poke around in the [Glottolog CLDF data](https://github.com/glottolog/glottolog-cldf). Let's download release v4.6:

```shell
$ curl -LO https://github.com/glottolog/glottolog-cldf/archive/refs/tags/v4.6.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 7622k    0 7622k    0     0   262k      0 --:--:--  0:00:28 --:--:--  255k
$ unzip v4.6.zip 
Archive:  v4.6.zip
c8eefe82b4c87f3c566a8e5181bacf714661e18e
   creating: glottolog-cldf-4.6/
...
```

Now we need to install [pycldf](https://gihub.com/cldf/pycldf) and load the CLDF into SQLite:
```shell
$ pip install pycldf
$ cldf createdb glottolog-cldf-4.6/cldf/cldf-metadata.json glottolog.sqlite
INFO    <cldf:v1.0:StructureDataset at glottolog-cldf-4.6/cldf> loaded in glottolog.sqlite
```

Let's connect to the database via RSQLite:
```r
> library(RSQLite)
> conn <- dbConnect(RSQLite::SQLite(), "glottolog.sqlite")
> dbListTables(conn)
[1] "CodeTable"              "LanguageTable"          "ParameterTable"        
[4] "SourceTable"            "ValueTable"             "ValueTable_SourceTable"
```

The database schema (in particular table and column names) follows the rules described [here](https://github.com/cldf/pycldf/blob/de850772a72dbaa3350fd005b474cdd601278b1b/src/pycldf/db.py#L4-L39).

Now we can let [dplyr](https://db.rstudio.com/r-packages/dplyr/) loose on the data:
```r
> library(dplyr)
> languages <- tbl(conn, "languagetable")
> values <- tbl(conn, "valuetable")
> aes <- values %>% filter(cldf_parameterReference == "aes")

> inner_join(aes, languages, by=c("cldf_languageReference" = "cldf_id")) %>% group_by(cldf_codeReference) %>% summarise(langs = count(cldf_languageReference))
# Source:   lazy query [?? x 2]
# Database: sqlite 3.38.5
#   [glottolog.sqlite]
  cldf_codeReference langs
  <chr>              <int>
1 aes-extinct         1250
2 aes-moribund         414
3 aes-nearly_extinct   351
4 aes-not_endangered  2956
5 aes-shifting        1837
6 aes-threatened      1537
```
