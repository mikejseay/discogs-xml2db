--- artists
DROP INDEX artist_namevariation_idx_artist;
DROP INDEX artist_alias_idx_artist;
DROP INDEX group_member_idx_group;
DROP INDEX group_member_idx_member;

--- masters
DROP INDEX master_artist_idx_master;
DROP INDEX master_artist_idx_artist;
DROP INDEX master_genre_idx_master;
DROP INDEX master_style_idx_master;

--- releases
DROP INDEX release_artist_idx_release;
DROP INDEX release_artist_idx_artist;
DROP INDEX release_label_idx_release;
DROP INDEX release_label_idx_label;
DROP INDEX release_genre_idx_release;
DROP INDEX release_style_idx_release;
DROP INDEX release_format_idx_release;
DROP INDEX release_identifier_idx_release;
DROP INDEX release_company_idx_release;
DROP INDEX release_company_idx_company;
