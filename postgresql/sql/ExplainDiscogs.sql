-- Birds-eye statistics of the discogs catalogue.
-- How many distinct pieces of media across what formats? How many distinct artists? Labels/companies? How many genres / styles? (Use good practice to make sure you're not double-counting anything.)

-- Discogs tracks 15 238 626 releases.

SELECT COUNT(*)
FROM release;

-- Discogs tracks 8 149 686 artists.

SELECT COUNT(*)
FROM artist;

-- Discogs tracks 1 865 196 labels.

SELECT COUNT(*)
FROM label;

-- Of which 8 418 505 are unique (i.e. not re-issues).

SELECT COUNT(*)
FROM release
WHERE main = 1 OR master_id IS NULL;

-- From 6 156 446 distinct artists.

SELECT COUNT(*)
FROM
  (SELECT DISTINCT artist_id
   FROM release_artist) AS q1;

-- Master release with the most releases

SELECT
  m.id,
  m.title,
  m.year,
  q1.releases
FROM master AS m
  INNER JOIN (SELECT
                master_id,
                COUNT(*) AS releases
              FROM release
              WHERE master_id IS NOT NULL
              GROUP BY master_id
              ORDER BY releases DESC
              LIMIT 10) AS q1
    ON m.id = q1.master_id

-- Normalize by number of years.

SELECT
  m.id,
  m.title,
  m.year,
  q1.releases,
  2036.0 - m.year                 AS years_til_2036,
  q1.releases / (2036.0 - m.year) AS year_norm
FROM master AS m
  INNER JOIN (SELECT
                master_id,
                COUNT(*) AS releases
              FROM release
              WHERE master_id IS NOT NULL
              GROUP BY master_id) AS q1
    ON m.id = q1.master_id
ORDER BY year_norm DESC
LIMIT 10;

-- Get detailed information about each release of a particular master.

SELECT
  id,
  title,
  released,
  country,
  MAX(format) AS format,
  MAX(label)  AS label
FROM
  (SELECT
     r.id,
     r.title,
     r.released,
     r.country,
     rf.name       AS format,
     rl.label_name AS label
   FROM
     (SELECT *
      FROM release
      WHERE master_id = 10362) AS r
     INNER JOIN release_format AS rf
       ON r.id = rf.release_id
     INNER JOIN release_label AS rl
       ON r.id = rl.release_id) AS q1
GROUP BY id, title, released, country
ORDER BY id;

-- Count the number of distinct countries, formats, and labels a particular master has been released from.

SELECT
  COUNT(DISTINCT country) AS distinct_countries,
  COUNT(DISTINCT format)  AS distinct_formats,
  COUNT(DISTINCT label)   AS distinct_labels
FROM
  (SELECT
     r.id,
     r.title,
     r.released,
     r.country,
     rf.name       AS format,
     rl.label_name AS label
   FROM
     (SELECT *
      FROM release
      WHERE master_id = 10362) AS r
     INNER JOIN release_format AS rf
       ON r.id = rf.release_id
     INNER JOIN release_label AS rl
       ON r.id = rl.release_id) AS q1;

-- Which artist has had the most master releases?

SELECT
  q1.artist_id AS id,
  a.name,
  q1.masters
FROM
  (SELECT
     artist_id,
     COUNT(*) AS masters
   FROM master_artist
   GROUP BY artist_id
   ORDER BY masters DESC) AS q1
  INNER JOIN artist AS a
    ON q1.artist_id = a.id
LIMIT 10;

-- What artist had the most name variations?

SELECT
  a.id,
  a.name,
  q1.variations
FROM artist AS a
  INNER JOIN (SELECT
                artist_id,
                COUNT(*) AS variations
              FROM artist_namevariation
              GROUP BY artist_id
              ORDER BY variations DESC
              LIMIT 10) AS q1
    ON a.id = q1.artist_id
ORDER BY variations DESC;

-- Which "artist" has the highest average number of releases per master?

SELECT
  q3.artist_id,
  a.name,
  q3.avg_releases_per_master
FROM
  (SELECT
     artist_id,
     AVG(releases_per_master) AS avg_releases_per_master
   FROM
     (SELECT
        ma.master_id,
        ma.artist_id,
        q1.releases_per_master
      FROM
        (SELECT
           master_id,
           COUNT(*) AS releases_per_master
         FROM release
         GROUP BY master_id) AS q1
        INNER JOIN master_artist AS ma
          ON q1.master_id = ma.master_id) AS q2
   GROUP BY artist_id
   ORDER BY avg_releases_per_master DESC
   LIMIT 10) AS q3
  INNER JOIN artist AS a
    ON q3.artist_id = a.id;

-- What master has the longest name in characters?

SELECT
  id,
  title,
  length(title) AS title_length
FROM master
ORDER BY title_length DESC
LIMIT 10;

-- What is the earliest known audio recording?

SELECT
  id,
  title,
  released,
  country
FROM release
WHERE released LIKE '1%'
ORDER BY released
LIMIT 10;

-- How many releases have been made in each format?

SELECT
  rf.format,
  COUNT(*) AS instances
FROM release AS r
  INNER JOIN (SELECT
                release_id,
                MAX(name) AS format
              FROM release_format
              GROUP BY release_id) AS rf
    ON r.id = rf.release_id
GROUP BY rf.format;

-- How have the number of releases in each format changed over the years?

SELECT
  q1.format,
  q1.released_year,
  COUNT(*)
FROM
  (SELECT
     to_date(left(r.released, 4), 'YYYY') AS released_year,
     rf.format
   FROM release AS r
     INNER JOIN (SELECT
                   release_id,
                   MAX(name) AS format
                 FROM release_format
                 GROUP BY release_id) AS rf
       ON r.id = rf.release_id) AS q1
GROUP BY q1.format, q1.released_year;

-- Genres / styles

-- Get occurences of genres

SELECT
  genre,
  COUNT(*) AS cnt
FROM master_genre
GROUP BY genre;

-- Get occurences of styles

SELECT
  style,
  COUNT(*) AS cnt
FROM master_style
GROUP BY style;

-- Get occurences of genres-style combinations

SELECT
  mg.genre,
  ms.style,
  COUNT(*) AS instances
FROM master_genre AS mg
  INNER JOIN master_style AS ms
    ON mg.master_id = ms.master_id
GROUP BY mg.genre, ms.style;

-- Get the genre that is most associated with each style

WITH q1 AS (SELECT
              mg.genre,
              ms.style,
              COUNT(*) AS instances
            FROM master_genre AS mg
              INNER JOIN master_style AS ms
                ON mg.master_id = ms.master_id
            GROUP BY mg.genre, ms.style)
SELECT
  MAX(q1.genre) AS genre,
  q2.style
FROM
  (SELECT
     q1.style,
     MAX(q1.instances) AS max_instances
   FROM q1
   GROUP BY q1.style) AS q2
  INNER JOIN q1 ON q1.style = q2.style AND q1.instances = q2.max_instances
GROUP BY q2.style;

-- Get co-occurences of genres

SELECT
  a.genre  AS g1,
  b.genre  AS g2,
  COUNT(*) AS cnt
FROM master_genre AS a
  INNER JOIN master_genre AS b
    ON a.master_id = b.master_id AND a.genre < b.genre
GROUP BY a.genre, b.genre;

-- Get co-occurences of styles

SELECT
  a.style  AS g1,
  b.style  AS g2,
  COUNT(*) AS cnt
FROM master_style AS a
  INNER JOIN master_style AS b
    ON a.master_id = b.master_id AND a.style < b.style
GROUP BY a.style, b.style;

-- Artist that is the member of the most groups

SELECT
  a.id,
  a.name,
  q1.instances AS groups
FROM artist AS a
  INNER JOIN (SELECT
                member_artist_id,
                COUNT(*) AS instances
              FROM group_member
              GROUP BY member_artist_id
              ORDER BY instances DESC
              LIMIT 10) AS q1
    ON a.id = q1.member_artist_id
ORDER BY instances DESC;

-- What artist has the most aliases?

SELECT
  id,
  name
FROM artist
WHERE id IN
      (SELECT DISTINCT artist_id
       FROM artist_alias
       WHERE alias_name IN
             (SELECT alias_name
              FROM artist_alias
              WHERE artist_id =
                    (SELECT artist_id
                     FROM
                       (SELECT
                          artist_id,
                          COUNT(*) AS instances
                        FROM artist_alias
                        GROUP BY artist_id
                        ORDER BY instances DESC
                        LIMIT 1) AS q1)));

-- What release credits the largest number of artists?

SELECT
  q1.release_id,
  q1.num_artists,
  r.title,
  r.released,
  r.country
FROM
  (SELECT
     release_id,
     COUNT(*) AS num_artists
   FROM release_artist
   GROUP BY release_id
   ORDER BY num_artists DESC
   LIMIT 1) AS q1
  INNER JOIN release AS r
    ON q1.release_id = r.id;

-- What release has the most pieces of media in each format?

WITH q2 AS (SELECT
              q1.format,
              q1.max_qty,
              q1.release_id,
              r.title
            FROM
              (SELECT
                 rf1.name            AS format,
                 rf1.max_qty,
                 MIN(rf2.release_id) AS release_id
               FROM
                 (SELECT
                    name,
                    MAX(qty) AS max_qty
                  FROM release_format
                  GROUP BY name) AS rf1
                 INNER JOIN
                 release_format AS rf2
                   ON rf1.max_qty = rf2.qty AND rf1.name = rf2.name
               GROUP BY rf1.name, rf1.max_qty
               ORDER BY rf1.max_qty DESC
               LIMIT 10) AS q1
              INNER JOIN release AS r
                ON q1.release_id = r.id)
SELECT
  q2.release_id,
  q2.format,
  q2.max_qty,
  a.name,
  q2.title
FROM
  q2
  INNER JOIN
  (SELECT
     ra.release_id,
     MIN(ra.artist_id) AS artist_id
   FROM release_artist AS ra
   WHERE ra.release_id IN (SELECT release_id
                           FROM q2)
   GROUP BY ra.release_id) AS q3
    ON q2.release_id = q3.release_id
  INNER JOIN artist AS a
    ON q3.artist_id = a.id
ORDER BY q2.max_qty DESC;