ATTACH DATABASE "phoible.sqlite" AS phoible;
ATTACH DATABASE "clts.sqlite" AS clts;
ATTACH DATABASE "lsi.sqlite" AS lsi;

CREATE TEMP VIEW lsigraphemes AS
    SELECT DISTINCT grapheme
    FROM
        (
            WITH split(grapheme, segments) AS (
                SELECT
                    -- in final WHERE, we filter raw segments (1st row) and terminal ' ' (last row)
                    '',
                    f.cldf_segments || ' '
                FROM
                    lsi.formtable AS f
                JOIN lsi.languagetable AS l
                    ON f.cldf_languagereference = l.cldf_id
                WHERE
                    l.cldf_glottocode = 'mala1464'
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

SELECT lsi.grapheme, 'LSI', clts.name
FROM lsigraphemes AS lsi
         JOIN clts."data/sounds.tsv" AS clts
              ON clts.grapheme = lsi.grapheme
WHERE clts.name LIKE '%vowel' AND lsi.grapheme NOT IN phoiblegraphemes
ORDER BY lsi.grapheme;

SELECT phoible.grapheme, 'PHOIBLE', clts.name
FROM phoiblegraphemes AS phoible
         JOIN clts."data/sounds.tsv" AS clts
              ON clts.grapheme = phoible.grapheme
WHERE clts.name LIKE '%vowel' AND phoible.grapheme NOT IN lsigraphemes
ORDER BY phoible.grapheme;
