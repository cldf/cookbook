# Working with CLDF data in R

These scripts illustrate how to use basic R (i.e. without any external dependencies, packages, etc.) to work with CLDF data sets. `merge()` and the `df[filter$condition %in% filter2$condition,]` construct are used to combine the different data sources and perform basic queries and filtering tasks.

Note: While accessing CLDF data using standard data analysis tools as shown here is easy, this approach should be combined with consultation of the [JSON metadata](https://github.com/cldf/cldf/blob/master/README.md#cldf-metadata-file) supplied with a CLDF dataset, to verify assumptions regarding syntax (e.g. the [CSV dialect](https://www.w3.org/TR/2015/REC-tabular-metadata-20151217/#dialect-descriptions)) and semantics (e.g. the mapping of column names to [CLDF properties](http://cldf.clld.org/v1.0/terms.rdf)) of the data files.

- [simple_access_to_values.R](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/simple_access_to_values.R) (or its [notebook version](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/simple_access_to_values.ipynb)) illustrates a very basic analysis on the basis of the WALS CLDF dump.

- [wals_ids_comparison.R](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/wals_ids_comparison.R) (or its [notebook version](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/wals_ids_comparison.ipynb)) illustrates, in a more involved fashion, how to filter and analyse different CLDF dumps together (WALS and IDS, in this case).

- [typology_visualisation.R](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/typology_visualisation.R), a more involved example, outlining how to access, merge, filter, and post-process data for visualisation purposes. See also the associated [helper file](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/visualisation_helper.R) with all the functions that are being used in the example. This is based on coded provided by @bambooforest, [here](https://github.com/bambooforest/visualizing-typology-data/blob/master/procedure.R).
