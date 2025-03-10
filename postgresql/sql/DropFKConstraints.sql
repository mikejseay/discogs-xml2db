--- artists
ALTER TABLE artist_namevariation DROP CONSTRAINT IF EXISTS artist_namevariation_fk_artist;
ALTER TABLE artist_alias DROP CONSTRAINT IF EXISTS artist_alias_fk_artist;
ALTER TABLE artist_alias DROP CONSTRAINT IF EXISTS artist_alias_fk_alias_artist;
ALTER TABLE group_member DROP CONSTRAINT IF EXISTS group_member_fk_group;
ALTER TABLE group_member DROP CONSTRAINT IF EXISTS group_member_fk_member;


--- labels
ALTER TABLE label DROP CONSTRAINT IF EXISTS label_fk_parent_label;

--- masters
ALTER TABLE master DROP CONSTRAINT IF EXISTS master_fk_main_release;
ALTER TABLE master_artist DROP CONSTRAINT IF EXISTS master_artist_fk_master;
ALTER TABLE master_artist DROP CONSTRAINT IF EXISTS master_artist_fk_artist;
ALTER TABLE master_genre DROP CONSTRAINT IF EXISTS master_genre_fk_master;
ALTER TABLE master_style DROP CONSTRAINT IF EXISTS master_style_fk_master;

--- releases
ALTER TABLE release DROP CONSTRAINT IF EXISTS release_fk_master;
ALTER TABLE release_artist DROP CONSTRAINT IF EXISTS release_artist_fk_release;
ALTER TABLE release_artist DROP CONSTRAINT IF EXISTS release_artist_fk_artist;
ALTER TABLE release_label DROP CONSTRAINT IF EXISTS release_label_fk_release;
ALTER TABLE release_label DROP CONSTRAINT IF EXISTS release_label_fk_label;
ALTER TABLE release_genre DROP CONSTRAINT IF EXISTS release_genre_fk_release;
ALTER TABLE release_style DROP CONSTRAINT IF EXISTS release_style_fk_release;
ALTER TABLE release_format DROP CONSTRAINT IF EXISTS release_format_fk_release;
ALTER TABLE release_identifier DROP CONSTRAINT IF EXISTS release_identifier_fk_release;
ALTER TABLE release_company DROP CONSTRAINT IF EXISTS release_company_fk_release;
ALTER TABLE release_company DROP CONSTRAINT IF EXISTS release_company_fk_company;
