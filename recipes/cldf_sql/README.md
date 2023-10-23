# Using CLDF via SQL

Thanks to the [CLDF SQL](https://github.com/cldf/cldf/blob/master/extensions/sql.md) extension,
we can access (most) data in a CLDF dataset via SQL. To do so, we must first load the dataset into
a SQLite databse, using the [`cldf createdb` command](https://github.com/cldf/pycldf#converting-a-cldf-dataset-to-an-sqlite-database).
(For an introduction to SQL databases, see the [Software Carpentry lesson "Databases and SQL"](https://swcarpentry.github.io/sql-novice-survey/).)


## A first example with WALS

Let's see how this works in practice. So to list the languages in [WALS](https://wals.info) with the number
of datapoints for each, we'd first create the SQLite database:
```shell
$ cldf createdb --download-dir tmp/ https://doi.org/10.5281/zenodo.7385533  wals.sqlite
```

Now we can run SQL such as
```sql
SELECT l.cldf_name, count(v.cldf_id) AS c 
FROM valuetable AS v 
JOIN languagetable AS l 
    ON l.cldf_id = v.cldf_languageReference 
GROUP BY l.cldf_id 
ORDER BY c desc 
LIMIT 20
```

Assuming the SQL query is stored in a file `wals.sql`, we can run it on the database using the [sqlite3](https://sqlite.org/cli.html) command
```shell
$ sqlite3 wals.sqlite < wals.sql
English|159
French|158
German|157
Russian|156
Spanish|155
Hungarian|155
Greek (Modern)|155
Finnish|155
Turkish|154
Mandarin|153
Indonesian|153
Japanese|151
Georgian|150
Amele|150
Lezgian|149
Korean|149
Evenki|149
Basque|149
Supyire|148
Hausa|148
```

In much the same way we can investigate the somewhat famous sparsity of the WALS data by looking at the
number of datapoints per feature. We can also visualize the results easily using shell tools such as
[termgraph](https://pypi.org/project/termgraph/):

```shell
$ pip install termgraph
$ sqlite3 wals.sqlite "select p.cldf_id, count(v.cldf_id) as c from valuetable as v join parametertable as p on p.cldf_id = v.cldf_parameterReference group by p.cldf_id order by c desc limit 30" | termgraph --delim "|"

83A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.52 K
82A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.50 K
81A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.38 K
87A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.37 K
143G: ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.32 K
143F: ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.32 K
143E: ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.32 K
143A: ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.32 K
97A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.32 K
86A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.25 K
88A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.23 K
144A: ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.19 K
85A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.18 K
112A: ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.16 K
89A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.15 K
95A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.14 K
69A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.13 K
33A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.07 K
51A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1.03 K
26A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 969.00
116A: ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 955.00
93A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 902.00
57A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 902.00
92A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 884.00
96A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 879.00
90A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 824.00
101A: ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 711.00
94A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 659.00
90C : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 620.00
37A : ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 620.00
```


## Comparing phoneme inventories extracted from wordlists with PHOIBLE

While SQL is already a useful tool to access data of a single CLDF dataset (because it's built
for multi-table relational data), a particular cool feature of SQLite is its
[ATTACH DATABASE](https://www.sqlitetutorial.net/sqlite-attach-database/) statement. It allows us
to attach multiple databases and then query across the tables of all attached databases
seamlessly.

We'll use this feature (and a couple more SQL gimmicks) to compare the phoneme inventory extracted
from a [CLDF Wordlist](https://github.com/cldf/cldf/tree/master/modules/Wordlist) with 
[segments](https://cldf.clld.org/v1.0/terms.html#segments) to an inventory for the same language as
documented in [PHOIBLE](https://phoible.org/).


### Creating the SQLite databases

The datasets involved in this analysis are
- [LSI - the vocabularies of the Linguistic Survey of India](https://doi.org/10.5281/zenodo.8361936) (but any wordlist with segments would work)
- [PHOIBLE](https://doi.org/10.5281/zenodo.2677911)
- [CLTS](https://doi.org/10.5281/zenodo.5583682) - the reference catalog making sure we compare like with like

We can download LSI and CLTS using the same temporary directory as for WALS above, because the CLDF metadata
contains [enough identifying information to detect the corresponding dataset](https://github.com/cldf/cldf/blob/master/extensions/discovery.md#cldf-dataset-discovery):
```shell
cldf createdb --download-dir tmp/ "https://doi.org/10.5281/zenodo.8361936#rdf:ID=lsi" lsi.sqlite
cldf createdb --download-dir tmp/ "https://doi.org/10.5281/zenodo.5583682#dc:identifier=https://doi.org/10.5281/zenodo.3515744" clts.sqlite
```

For PHOIBLE v2.0.1 this isn't the case, so just make sure to use an empty temporary directory:
```shell
rm -rf tmp/*
cldf createdb --download-dir tmp/ "https://doi.org/10.5281/zenodo.2677911" phoible.sqlite
```

Once we have created the corresponding SQLite databases (as above), we can make them available to a query
in SQL as follows (and run a quick check to make sure we got what we expected). We open and connect to an 
[SQLite in-memory database](https://www.sqlite.org/inmemorydb.html);
```shell
$ sqlite3
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> 
```
and then can run the following SQL statements:
```sqlite
ATTACH DATABASE "phoible.sqlite" AS phoible;
ATTACH DATABASE "clts.sqlite" AS clts;
ATTACH DATABASE "lsi.sqlite" AS lsi;

SELECT 'PHOIBLE', count(*), 'inventories' FROM phoible."contributions.csv";
SELECT 'CLTS', count(*), 'sounds' FROM clts."data/sounds.tsv";
SELECT 'LSI', count(*), 'varieties' FROM lsi.languagetable;
```
to see a result like
```
PHOIBLE|3020|inventories
CLTS|8657|sounds
LSI|363|varieties
```


### Extracting the phoneme inventories

Now we want to find out which segments appear in the wordlist, but not in the corresponding PHOIBLE
inventory and vice versa. We will use the language [Malayalam](https://glottolog.org/resource/languoid/id/mala1464),
specified by Glottocode `mala1464` as example.

To make these two queries simpler, we first [create views](https://www.sqlitetutorial.net/sqlite-create-view/) collecting
the two inventories.

Computing the inventory for the wordlist requires somewhat advanced SQL, because we have to split
the values of the `segments` column and create a result row for each segment. This can be done
with a [recursive common table expression](https://www.sqlite.org/lang_with.html) (see
[Simon Willison's blog post](https://til.simonwillison.net/sqlite/simple-recursive-cte) for a
gentle introduction):

```sqlite
CREATE TEMP VIEW lsigraphemes AS 
    SELECT DISTINCT grapheme
    FROM
        (
            WITH split(grapheme, segments) AS (
                SELECT
                    -- in final WHERE, we filter raw segments (1st row) and terminal ' ' (last row)
                    '',
                    f.cldf_segments || ' ' 
                FROM lsi.formtable AS f
                JOIN lsi.languagetable AS l 
                    ON f.cldf_languagereference = l.cldf_id
                WHERE l.cldf_glottocode = 'mala1464'
                -- recursively consume/select all segments in a segments string
                UNION ALL SELECT
                    substr(segments, 0, instr(segments, ' ')), -- each grapheme contains text up to next ' '
                    substr(segments, instr(segments, ' ') + 1) -- next recursion parses segments after this ' '
                FROM split -- recurse
                WHERE segments != '' -- break recursion once no more segments exist
            ) 
            SELECT grapheme FROM split
            WHERE grapheme!=''
        );
```

Collecting the segments from a PHOIBLE inventory is simpler, we have to take care, though, to not
aggregate all segments listed for one Glottocode, but select only segments from one particular
inventory (i.e. a row in the `contributions.csv` table). This is because PHOIBLE may have [more than
one inventory per Glottocode](https://phoible.org/languages/mala1464).

```sqlite
CREATE TEMP VIEW phoiblegraphemes AS
    SELECT DISTINCT c.cltsgrapheme AS grapheme 
    FROM
        (
            SELECT v.cldf_value AS grapheme 
            FROM phoible.valuetable AS v
            JOIN phoible.languagetable AS l
                ON l.cldf_id = v.cldf_languagereference
            WHERE l.cldf_glottocode = 'mala1464' AND v.contribution_id = 1762
        ) AS p
    JOIN
        (
            SELECT phoible.grapheme AS phoiblegrapheme, clts.grapheme AS cltsgrapheme 
            FROM clts."data/graphemes.tsv" AS phoible, clts."data/sounds.tsv" AS clts 
            WHERE phoible.dataset = 'phoible' AND phoible.name = clts.name
        ) AS c
        ON c.phoiblegrapheme = p.grapheme;
```

Notes: 
- We created `TEMP`, i.e. temporary, views, because the views access data in multiple 
  attached databases, thus cannot "live" in any of these, but must be objects of the temporary 
  in-memory database we are operating in. But we also wouldn't want to persist the views thereby
  changing the attached databases.
- In the LSI case we didn't have to map segments to CLTS explicitly, because this is already done in
  the [Lexibank curation workflow](https://doi.org/10.1038/s41597-022-01432-0).


### Comparing the inventories

Now the heavy lifting is done, and comparing the two sets of graphemes is straightforward. The following
query lists all vowels that appear in [LSI for Malayalam](https://lsi.clld.org/languages/MALAYALAM), but 
not in [PHOIBLE inventory 1762](https://phoible.org/inventories/view/1762), pulling in the name of the
corresponding CLTS sound:
```sqlite
SELECT lsi.grapheme, 'LSI', clts.name
FROM lsigraphemes AS lsi
JOIN clts."data/sounds.tsv" AS clts
    ON clts.grapheme = lsi.grapheme
WHERE clts.name LIKE '%vowel' AND lsi.grapheme NOT IN phoiblegraphemes
ORDER BY lsi.grapheme;
```

While vowels in PHOIBLE but not in LSI can be listed as
```sqlite
SELECT phoible.grapheme, 'PHOIBLE', clts.name
FROM phoiblegraphemes AS phoible
JOIN clts."data/sounds.tsv" AS clts
    ON clts.grapheme = phoible.grapheme
WHERE clts.name LIKE '%vowel' AND phoible.grapheme NOT IN lsigraphemes
ORDER BY phoible.grapheme;
```

The complete SQL script is available in [query.sql](query.sql) and can be passed to `sqlite3` on the
commandline as follows:
```shell
$ sqlite3 < recipes/cldf_sql/query.sql 
```
creating the following output:

Grapheme | Dataset | CLTS name
--- | --- | ---
ʌ|LSI|unrounded open-mid back vowel
ʌː|LSI|long unrounded open-mid back vowel
a|PHOIBLE|unrounded open front vowel
aː|PHOIBLE|long unrounded open front vowel
æ|PHOIBLE|unrounded near-open front vowel
ɨ|PHOIBLE|unrounded close central vowel
ʊ|PHOIBLE|rounded near-close near-back vowel

Considering that the inventory from LSI was extracted from just 175 words, it isn't surprising that
the PHOIBLE inventory is bigger. Comparing the two LSI vowels missing in PHOIBLE might suggest that
what's transcribed as "ʌ" in LSI is listed as "a" in PHOIBLE.


### Conclusion

Using CLDF datasets still requires an understanding of the underlying data, e.g. to know that PHOIBLE's
inventories are modeled as contributions or to understand CLTS' custom tables. Reading through the
CLDF metadata (for [CLTS](https://github.com/cldf-clts/clts/blob/v2.2.0/cldf-metadata.json) and
[PHOIBLE](https://github.com/cldf-datasets/phoible/blob/v2.0.1/cldf/StructureDataset-metadata.json)
should still go a long way towards reaching this understanding).

What we get from standardization via CLDF is
- uniform data access on filesystem level (allowing `cldf created` to find the relevant tables)
- uniform selection of values/forms associated with a language specified by Glottocode
- transparent access to segments of word forms
- unambiguous mapping to CLTS graphemes/BIPA sounds

What we get from CLDF SQL is
- access to tables and columns via standard CLDF ontology terms (rather than dataset-local file or column names)
- a declarative way to specify data aggregations across datasets
- performance
