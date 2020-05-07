# CLDF and "wide" data

In this recipe we show how to convert a CLDF dataset from [long (or narrow) format to wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data).

CLDF follows best practices in data management by mandating a long format for its [ValueTable](https://github.com/cldf/cldf/tree/master/components/values).
This complies with the recommendation that

> Each observation must have its own row. [Tidy Data](https://r4ds.had.co.nz/tidy-data.html#tidy-data-1)

However, Linguists are often used to data in a wide format, e.g. a matrix (or spreadsheet) where each language has a row and
each typological feature or semantic concept has a column (with feature values and lexemes as cells, respectively).

Fortunately, it is always possible to convert the observations of a CLDF dataset to such a matrix. As an example, we'll
convert [the 2020 version of WALS Online](https://doi.org/10.5281/zenodo.3731125) to the
[matrix format](https://cdstar.shh.mpg.de/bitstreams/EAEA0-7269-77E5-3E10-0/wals_language.csv.zip) provided
as download for previous versions.

1. Download and unzip the data from [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3731125.svg)](https://doi.org/10.5281/zenodo.3731125).
   You should now have a local folder `cldf-datasets-wals-014143f/` on your disk.
2. Larger CLDF datasets are best handled using SQLite, so we load the data into a SQLite database running [`pycldf`'s](https://github.com/cldf/pycldf)
   `createdb` command:
   ```
   $ cldf createdb cldf-datasets-wals-014143f/cldf/StructureDataset-metadata.json wals2020.sqlite
   ```
   Using this db to extract the feature values for a single WALS feature is straightforward:
   ```sql
   SELECT
       l.cldf_name as 'Language', c.cldf_name as 'Value' FROM LanguageTable as l, ValueTable as v, CodeTable as c 
   WHERE 
       v.cldf_parameterReference = '1A' and l.cldf_id = v.cldf_languageReference and v.cldf_codeReference = c.cldf_id
   ;
   ```

Retrieving values for **all** features, and labeling the columns with feature names is a bit more complicated, though.
Actually, **retrieving** all values is not the problem:
```sql
SELECT
    l.cldf_id as wals_code
FROM
    LanguageTable as l
    JOIN ValueTable as v ON l.cldf_id = v.cldf_languageReference
    JOIN CodeTable as c ON v.cldf_codeReference = c.cldf_id
GROUP BY
    l.cldf_id
;
```
But how do we tease out the individual values and sort them into columns? We can exploit the fact that WALS has at most one
value per language and feature, so the following construct works:
```sql
SELECT
    l.cldf_id as wals_code,
max(case when v.cldf_parameterReference = '1A' then c.Number || ' ' || c.cldf_name end) as '1A Consonant Inventories'
FROM
    LanguageTable as l
    JOIN ValueTable as v ON l.cldf_id = v.cldf_languageReference
    JOIN CodeTable as c ON v.cldf_codeReference = c.cldf_id
GROUP BY
    l.cldf_id
;
```
But typing all `max(...) as ...` for 192 features is tedious.
So we'll use a two-step process to cobble together a suitable SQL query.

3. First, we run a query to retrieve the data which is needed to assemble the result set specification in the final query:
   ```sql
   SELECT
       'max(case when v.cldf_parameterReference = ''' || p.cldf_id || ''' then c.Number || '' '' || c.cldf_name end) as ''' || p.cldf_id || ' ' || replace(p.cldf_name, '''', '"') || ''','
   FROM
       ParameterTable as p
   ORDER BY
       p.cldf_id
   ;
   ```
4. Then we plug the result (stripping the final comma) into the full query:
   ```sql
   SELECT
       l.cldf_id as wals_code,
       l.cldf_iso639P3code as iso_code,
       l.cldf_glottocode as glottocode,
       l.cldf_name as Name,
       l.cldf_latitude as latitude,
       l.cldf_longitude as longitude,
       l.Genus as genus,
       l.Family as family,
       l.cldf_macroarea as macroarea,
       max(case when v.cldf_parameterReference = '1A' then c.Number || ' ' || c.cldf_name end) as '1A Consonant Inventories',
       [...]
   FROM
       LanguageTable as l
       JOIN ValueTable as v ON l.cldf_id = v.cldf_languageReference
       JOIN CodeTable as c ON v.cldf_codeReference = c.cldf_id
   GROUP BY
       l.cldf_id,
       l.cldf_iso639P3code,
       l.cldf_glottocode,
       l.cldf_name,
       l.cldf_latitude,
       l.cldf_longitude,
       l.Genus,
       l.Family,
       l.cldf_macroarea
   ORDER BY
       l.cldf_id
   ;
   ```

The [full query](matrix.sql) can be run against the SQLite database as follows
```
sqlite3 -header -csv wals2020.sqlite < matrix.sql > matrix.csv
```
to create a CSV table [matrix.csv](matrix.csv) which can be loaded into spreadsheet
programs.

