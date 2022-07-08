--- artists
CREATE INDEX artist_namevariation_idx_artist ON artist_namevariation (artist_id);
CREATE INDEX artist_alias_idx_artist ON artist_alias (artist_id);
CREATE INDEX group_member_idx_group ON group_member (group_artist_id);
CREATE INDEX group_member_idx_member ON group_member (member_artist_id);

--- masters
CREATE INDEX master_artist_idx_master ON master_artist (master_id);
CREATE INDEX master_artist_idx_artist ON master_artist (artist_id);
CREATE INDEX master_genre_idx_master ON master_genre (master_id);
CREATE INDEX master_style_idx_master ON master_style (master_id);

--- releases
CREATE INDEX release_idx_master ON release (master_id);
CREATE INDEX release_artist_idx_release ON release_artist (release_id);
CREATE INDEX release_artist_idx_artist ON release_artist (artist_id);
CREATE INDEX release_label_idx_release ON release_label (release_id);
CREATE INDEX release_label_idx_label ON release_label (label_id);
CREATE INDEX release_genre_idx_release ON release_genre (release_id);
CREATE INDEX release_style_idx_release ON release_style (release_id);
CREATE INDEX release_format_idx_release ON release_format (release_id);
CREATE INDEX release_identifier_idx_release ON release_identifier (release_id);
CREATE INDEX release_company_idx_release ON release_company (release_id);
CREATE INDEX release_company_idx_company ON release_company (company_id);
