# Working with CLDF data in R

These scripts illustrate how to use basic R (i.e. without any external dependencies, packages, etc.) to work with CLDF data sets. `merge()` and the `df[filter$condition %in% filter2$condition,]` construct are used to combine the different data sources and perform basic queries and filtering tasks. 

[simple_access_to_values.R](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/simple_access_to_values.R) (or its [notebook version](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/simple_access_to_values.ipynb)) illustrates a very basic analysis on the basis of the WALS CLDF dump.

[wals_ids_comparison.R](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/wals_ids_comparison.R) (or its [notebook version](https://github.com/cldf/cookbook/blob/master/recipes/cldf_r/wals_ids_comparison.ipynb)) illustrates, in a more involved fashion, how to filter and analyse different CLDF dumps together (WALS and IDS, in this case).
