from __future__ import print_function, unicode_literals

from typecraft_python.parsing.parser import Parser
from pycldf import Generic


def word2morphemes(word):
    """
    See Rule 2 here https://www.eva.mpg.de/lingua/resources/glossing-rules.php
    """
    return '-'.join(m.morpheme for m in word.morphemes)


def morpheme2gloss(morpheme):
    """
    See Rule 4 here https://www.eva.mpg.de/lingua/resources/glossing-rules.php
    """
    glosses = [morpheme.meaning] + morpheme.glosses
    return '.'.join(g.replace('-', '.') for g in glosses if g)


def word2gloss(word):
    return '-'.join(morpheme2gloss(m) for m in word.morphemes)


def to_cldf(corpus, outdir=None):
    ds = Generic.in_dir(outdir or 'cldf')
    ds.add_component('ExampleTable', 'Text_ID')
    ds.add_component('LanguageTable')
    ds.add_table('texts.csv', 'ID', 'Title', 'Title_translation')

    languages = [
        {'ID': 'aka', 'Name': 'Akan', 'Glottocode': 'akan1250', 'ISO639P3code': 'aka'}]
    texts = []
    phrases = []
    for i, text in enumerate(corpus):
        tid = str(i + 1)
        texts.append({
            'ID': tid,
            'Title': text.title.strip(),
            'Title_translation': text.title_translation})
        print('\nText {0}: {1}\n'.format(tid, text.title.strip()))
        for phrase in text.phrases:
            igt = {
                'ID': phrase.id,
                'Language_ID': 'aka',
                'Primary_Text': phrase.phrase,
                'Analyzed_Word': [word2morphemes(w) for w in phrase.words],
                'Gloss': [word2gloss(w) for w in phrase.words],
                'Translated_Text': phrase.translation,
            }
            print(igt['Primary_Text'])
            print('\t'.join(igt['Analyzed_Word']))
            print('\t'.join(igt['Gloss']))
            print(igt['Translated_Text'])
            print('')
            phrases.append(igt)
    ds.write(**{
        'LanguageTable': languages,
        'ExampleTable': phrases,
        'texts.csv': texts,
    })


if __name__ == '__main__':
    import sys
    to_cldf(Parser.parse_file(sys.argv[1]))
