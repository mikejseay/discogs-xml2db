-- Let's assure the quality of the database first.

-- Some of the columns are fully NULL and make no sense.

ALTER TABLE artist_alias 
DROP COLUMN IF EXISTS alias_artist_id;

-- Some of the columns contain information which is useless to me.

ALTER TABLE release_company 
DROP COLUMN IF EXISTS uri;

-- label.parent_id is fully NULL, here's how you can in-fill it. This is very fast.

UPDATE label
SET parent_id = label.id
FROM label
WHERE label.parent_name = label.name;

-- Fix master_artist.role by in-filling from release_artist and using the main fields to connect them. Sorry this is messy, but I'm pretty sure it works. In retrospect, the result is barely useful, but it was an interesting problem.

UPDATE master_artist
SET role = sq3.role_on_main_release
FROM
  (SELECT
     ma.master_id,
     ma.artist_id,
     role_on_main_release
   FROM
     (SELECT
        sq1.master_id,
        sq1.artist_id,
        MAX(sq1.role) AS role_on_main_release
      FROM
        (SELECT
           master.id AS master_id,
           release_artist.artist_id,
           release_artist.role
         FROM master
           INNER JOIN release_artist
             ON master.main_release = release_artist.release_id
         WHERE release_artist.role IS NOT NULL) AS sq1
      GROUP BY sq1.master_id, sq1.artist_id) AS sq2
     INNER JOIN
     master_artist AS ma
       ON sq2.master_id = ma.master_id
          AND sq2.artist_id = ma.artist_id) AS sq3
WHERE master_artist.master_id = sq3.master_id
      AND master_artist.artist_id = sq3.artist_id;

-- To add the foreign key (release_label.label_id). For some reason this takes a long time...

UPDATE release_label
SET label_id = label.id
FROM label
WHERE release_label.label_name = label.name;

-- Fix absence of the "main" field in release by finding it in master (takes 5 minutes for some reason).

UPDATE release
SET main = 1
WHERE id IN
(SELECT DISTINCT main_release
FROM master);

-- Fix incorrect entries in release.released
-- I'm actually not exactly sure how to do this...

-- UPDATE release
-- SET released = NULL
-- where the date is ? or < 1860
