# coding: utf8
"""Plot the number of filled-in parameters for each language.

parameter_sampled: map languages to sets of parameters
"""
import sys
import argparse
from collections import Counter

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap

import pycldf
from clldutils.path import Path
try:
    from pyglottolog.api import Glottolog
except ImportError:
    Glottolog = None



def parameters_sampled(dataset):
    """Check which parameters are given for which languages.

    Return the dictionary mapping all language ids present in the dataset's
    primary table to the set of parameter ids with values for that language.

    Parameters
    ----------
    dataset: pycldf.Dataset

    Returns
    -------
    dict

    """
    languageReference = dataset[dataset.primary_table, "languageReference"].name
    parameterReference = dataset[dataset.primary_table, "parameterReference"].name
    return Counter(row[languageReference] for row in dataset[dataset.primary_table])


def main(dataset, output, glottolog_repos, cmap):
    dataset = pycldf.Dataset.from_metadata(dataset)

    # Try to load language locations from the dataset
    locations = {}
    if Glottolog:
        for lang in Glottolog(glottolog_repos).languoids():
            if lang.latitude is not None:
                if lang.id not in locations:
                    locations[lang.id] = (lang.latitude, lang.longitude)
                if lang.iso and lang.iso not in locations:
                    locations[lang.iso] = (lang.latitude, lang.longitude)

    try:
        idcol = dataset["LanguageTable", "id"].name
        latcol = dataset["LanguageTable", "latitude"].name
        loncol = dataset["LanguageTable", "longitude"].name
        try:
            gccol = dataset["LanguageTable", "glottocode"].name
        except KeyError:
            pass
        try:
            isocol = dataset["LanguageTable", "iso639P3code"].name
        except KeyError:
            pass
        for row in dataset["LanguageTable"]:
            if row[latcol] is not None:
                locations[row[idcol]] = row[latcol], row[loncol]
            elif row[gccol] in locations:
                locations[row[idcol]] = locations[row[gccol]]
            elif row[isocol] in locations:
                locations[row[idcol]] = locations[row[isocol]]                
    except ValueError:
        # No language table
        pass

    # Aggregate the data
    lats, lons, sizes = [], [], []

    for language, sample_size in parameters_sampled(dataset).items():
        if language in locations:
            lat, lon = locations[language]
            lats.append(float(lat))
            lons.append(float(lon))
            sizes.append(sample_size)

    assert len(sizes) == len(lats) == len(lons)

    # Calculate coordinate boundaries
    min_lat, max_lat = min(lats), max(lats)
    d_lat = max_lat - min_lat
    min_lat = max(-90, min_lat - 0.1 * d_lat)
    max_lat = min(90, max_lat + 0.1 * d_lat)

    min_lon, max_lon = min(lons), max(lons)
    d_lon = max_lon - min_lon
    min_lon = max(-180, min_lon - 0.1 * d_lon)
    max_lon = min(180, max_lon + 0.1 * d_lon)

    # Draw the base map
    # TODO: Get coordinates from commandline, fallback to bounding box of data
    # TODO: Give more control over map drawing to user (projection, level of
    # detail, drawing other patterns (countries, eg.) instead of just coast
    # lines, continent color) – What is a good way to do that?
    map = Basemap(
        llcrnrlat=min_lat,
        llcrnrlon=min_lon,
        urcrnrlat=max_lat,
        urcrnrlon=max_lon,
        resolution='h',
        area_thresh=10)
    map.drawcoastlines()
    map.fillcontinents(color='#fff7ee', zorder=0)

    # Plot the sample sizes
    map.scatter(lons, lats, c=sizes, cmap=cmap, latlon=True)

    # TODO: Improve shape of components: Colorbar is very huge, margins are quite large
    plt.colorbar()
    plt.gcf().set_size_inches(12, 9)

    plt.savefig(output)
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument(
        'dataset', type=Path,
        help="Path to the CLDF dataset's JSON description")
    parser.add_argument(
        "output",
        help="File name to write output to")
    parser.add_argument(
        "--glottolog-repos", default=None,
        help="Path to local clone or export of clld/glottolog")
    parser.add_argument(
        "--cmap", type=plt.get_cmap, default=plt.get_cmap("magma_r"),
        help="Colormap to be used for the parameter counts")
    options = parser.parse_args()
    main(options.dataset, options.output, options.glottolog_repos, options.cmap)
