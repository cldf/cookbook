
# CLDF + SQL

## SQL: What and why?

SQL - the Structured Query Language

### A DSL (domain-specific language) as opposed to a general purpose language like Python

> particularly useful in handling structured data, i.e., data incorporating relations among entities and variables.

No file reading, writing, file system operations, etc.


### SQL is old.

terminology like "join", "select", "group by", "intersect", "union" comes from SQL!

Learning SQL is like learning Latin. Makes it soemwhat easier to understand all of its derivatives.
But the only people speaking it are somewhat strange. In the case of SQL, though, the Vatican is a
really cool place!

SQL is (still) good to have on your CV if you ever apply for data scienctist jobs


### SQL is *declarative* (as opposed to *imperative*), i.e. no "control flow statements", 

> SQL is an example of a declarative programming language. Statements do not describe computations directly, but instead describe the desired result of some computation.

Also, modularization via functions is not a thing.

Example:
- values for languages without glottocodes, Python vs. SQL

While this "lack of expressiveness" might seem like a disadvantage, it actually is advantageous to judge
applicability of SQL: If you can fit your data aggregation needs into one statement (one *query*) (and possibly a handful of
*views*), SQL could be a good choice.


### SQL is (possibly too) big:
- stored procedures
- SQL ALTER *
- SQL INSERT/UPDATE/DELETE *
- indexes
- ...


### SQL is - unfortunately - somewhat diverse

> Despite the existence of standards, virtually no implementations in existence adhere to it fully, and most SQL code requires at least some changes before being ported to different database systems.


### SQL the language vs. database managers aka RDBMS or database engines

But the reason why SQL is a good choice for data manipulation in linguistics is SQLite, i.e. an
ubiquitous, [database engine](https://en.wikipedia.org/wiki/Database_engine) that works on single-file databases.
So this diversity only hurts us by making googling for SQL solutions a bit trickier. (But it's good to know 
that should we run into performance issues with SQLite, PostgreSQL is a likely solution - and is known for adhering "most"
to the SQL standard.)

SQLite is an embedded SQL database engine (embedded in the code accessing the database) as opposed to
RDBMS like PostgreSQL or MySQL, where the database engine runs in a server-like process and is accessed
over the network (or sockets).

SQLite adds functionality like input and output.

Example: Writing query results to CSV


## SQL - Getting started

-> software carpentry: https://swcarpentry.github.io/sql-novice-survey/

Getting used to SQL as R user: Maybe start with dbplyr https://dbplyr.tidyverse.org/ - running
[show_query](https://dplyr.tidyverse.org/reference/explain.html) now and then.

### Running SQL with `sqlite3`

[sqlite3](https://sqlite.org/cli.html)

Interactively:


From the shell:
```shell
$ sqlite3 lsi.sqlite "select cldf_id, cldf_name from languagetable limit 5"
JAPANESE|JAPANESE
AINU|AINU
KOREAN|KOREAN
TURKI|TURKI
MANCHU|MANCHU
```


or save SQL in a text file and feed it into `sqlite3` via [input redirection](https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Redirecting-Input):
```shell
$ sqlite3 < q.sql
```

Output:
```shell
$ sqlite3 --header --csv lsi.sqlite "select cldf_id, cldf_name from languagetable limit 5"
cldf_id,cldf_name
JAPANESE,JAPANESE
AINU,AINU
KOREAN,KOREAN
TURKI,TURKI
MANCHU,MANCHU
```



## CLDF SQL

Each CLDF dataset can be converted to a SQLite database, running the `cldf createdb` command installed
with `pycldf`. This SQLite database makes uniform access a lot easier for tools that are not CLDF aware:
- tables are named with component names rather than filenames
- columns are named with CLDF propery terms rather than - possibly custom - column names

### Examples

1. Investigating coverage in terms of languages of a dataset
2. Computing WALS-style value tables for StructureDatasets


## SQLite advanced

SQLite offers some advanced features which make it particularly suited for our use cases. We'll look
at these using a "real-world" example: We will compare phoneme inventories for Malayalam,
- as described in the PHOIBLE database vs.
- as extracted from the lexical data in the Linguistic Survey of India.

Of course, comparability of phonemes across datasets is mediated by CLTS, so we'll need the following
three datasets:
- PHOIBLE
- LSI
- CLTS

All three are available as CLDF datasets, and running `cldf createdb` we can load all three in individual
SQLite databases:
```shell
cldf createdb 
```


### ATTACH DATABASE

SQLite allows *attaching* multiple databases to the **same** connection - and querying across these
databases seamlessly!

E.g. we can easily compare coverage across datasets:
```sql
sqlite> attach database "lsi.sqlite" as lsi;
sqlite> attach database "phoible.sqlite" as phoible;
sqlite> select l.cldf_glottocode, l.cldf_name, p.cldf_name
   ...> from lsi.languagetable as l join phoible.languagetable as p on l.cldf_glottocode = p.cldf_glottocode
   ...> where l.cldf_glottocode like 'mala%';
mala1464|MALAYALAM|Malayalam
```


### CTEs (aka "inline VIEWs")

A good way to make SQL more modular, by using "named subqueries".

> common table expressions (CTE) are temporary result sets defined within the scope of a query.
https://www.sqlitetutorial.net/sqlite-cte/

```sql
select count(*) from formtable 
where cldf_id not in (
    select cldf_formReference from cognatetable);
```
vs.
```sql
with has_cognate as (select cldf_formReference from cognatetable) 
select count(*) from formtable where cldf_id not in has_cognate;
```


### WITH RECURSIVE

https://til.simonwillison.net/sqlite/simple-recursive-cte

Example: Split Glottolog classification into individual rows
https://github.com/glottolog/glottolog-cldf/blob/1eae737024e03d9e32b3b50571ea9997537344ab/cldf/parameters.csv#L4
```sql
with ancestors(ancestor, classification, level) as (
    select 
        '' as ancestor, 
        v.cldf_value as classification,
        0 as level
    from valuetable as v
    where
        v.cldf_languageReference = 'mala1464' and
        v.cldf_parameterReference = 'classification'
    union all
    select
        substr(classification, 0, 9),
        substr(classification, 10),
        level + 1
    from ancestors
    where classification != ''
)
select printf('%.*c', level, ' ') || '|- ' || ancestor from ancestors where ancestor != '' order by level;
```

prints
```shell
$ sqlite3 glottolog.sqlite < q.sql 
 |- drav1251
  |- sout3133
   |- sout3138
    |- tami1291
     |- tami1292
      |- tami1293
       |- tami1294
        |- tami1297
         |- tami1298
          |- mala1541
```


### A "real world" example

```sql
attach database "phoible.sqlite" as phoible;
attach database "clts.sqlite" as clts;
attach database "lsi-cldf/lsi.sqlite" as lsi;

WITH
  lsigraphemes AS (
    SELECT
      '' as grapheme,
      'LSI' as source,
      f.cldf_segments || ' ' as segments
    from lsi.formtable as f, lsi.languagetable as l
    where f.cldf_languagereference = l.cldf_id and l.cldf_glottocode = 'mala1464'
    UNION ALL
    SELECT
      substr(segments, 0, instr(segments, ' ')),
      'LSI',
      substr(segments, instr(segments, ' ') + 1)
    FROM lsigraphemes
    WHERE segments != ''
  ),
  phoiblegraphemes as (
    select distinct c.cltsgrapheme as grapheme, 'PHOIBLE' as source
    from
      (
        select v.cldf_value as grapheme from phoible.valuetable as v
        where cldf_languagereference = 'mala1464' and contribution_id = 1762
      ) as p
    join
      (
        select phoible.grapheme as phoiblegrapheme, clts.grapheme as cltsgrapheme 
        from clts."data/graphemes.tsv" as phoible, clts."data/sounds.tsv" as clts 
        where phoible.dataset = 'phoible' and phoible.name = clts.name
      ) as c
    on c.phoiblegrapheme = p.grapheme
  )
select g.grapheme, source, clts.name 
from (
  select distinct grapheme, source from lsigraphemes 
  where grapheme != '' and grapheme not in (select grapheme from phoiblegraphemes)
  union
  select grapheme, source from phoiblegraphemes 
  where grapheme not in (select grapheme from lsigraphemes)
) as g
join clts."data/sounds.tsv" as clts
on clts.grapheme = g.grapheme
where clts.name like '%vowel' 
order by g.source, g.grapheme;
```


### JSON

-> Language Atlas example


## SQL as ideal intermediate data aggregation step between raw data and analysis (e.g. in R)

- CLDF SQL helps with re-use (of code, etc.) because it focuses on the commonalitites between CLDF datasets
- DoReCo: SQLite is fast!

  When the result is supposed to be a single table to be fed into R, SQL makes for a transparent aggregation.

