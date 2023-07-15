
-- /* Semantic inputs */
-- DROP TABLE SemanticInputs;
-- DROP TABLE PrivateRecentInputs;
-- DROP TABLE RecentInputs;
-- DROP TABLE Indexes;
--
-- /* Terms */
-- DROP TABLE Terms;
--
-- /* Data */
-- DROP TABLE Users;
-- DROP TABLE Texts;
-- DROP TABLE Binaries;
--
-- /* Meta data */
-- DROP TABLE PrivateCreators;





/* Statements that the users (or bots) give as input to the semantic network.
 * A central feature of this semantic system is that all such statements come
 * with a numerical value which represents the degree to which the user deems
 * that the statement is correct (like when answering a survey).
 **/
CREATE TABLE SemanticInputs (
    -- User (or bot) who states the statement.
    user_id BIGINT UNSIGNED NOT NULL,
    -- Predicate of the statement.
    pred_id BIGINT UNSIGNED NOT NULL,

    /* The "input set" */
    -- Given some constants for the above four columns, the input sets contains
    -- pairs of rating values and the IDs of the predicate subjects.
    rat_val SMALLINT UNSIGNED NOT NULL,
    subj_id BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (
        user_id,
        pred_id,
        rat_val,
        subj_id
    ),

    UNIQUE INDEX (user_id, pred_id, subj_id)
);
-- TODO: Compress this table and its sec. index, as well as some other tables
-- and sec. indexes below. (But compression is a must for this table.)


CREATE TABLE PrivateRecentInputs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,
    pred_id BIGINT UNSIGNED NOT NULL,
    rat_val SMALLINT UNSIGNED, -- new rating value:
    subj_id BIGINT UNSIGNED NOT NULL,

    live_after TIME
    -- TODO: Make a recurring scheduled event that decrements the days of this
    -- time, and one that continously moves the private RIs to the public table
    -- when the time is up (and when the day part of the time is at 0).
);
CREATE TABLE RecentInputs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,
    pred_id BIGINT UNSIGNED NOT NULL,
    rat_val SMALLINT UNSIGNED, -- new rating value.
    subj_id BIGINT UNSIGNED NOT NULL,

    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- CREATE TABLE RecordedInputs (
--     user_id BIGINT UNSIGNED NOT NULL,
--     pred_id BIGINT UNSIGNED NOT NULL,
--     -- recorded rating value.
--     subj_id BIGINT UNSIGNED NOT NULL,
--
--     changed_at DATETIME,
--
--     rat_val SMALLINT UNSIGNED,
--
--     PRIMARY KEY (
--         user_id,
--         pred_id,
--         subj_id,
--         changed_at
--     )
-- );

CREATE TABLE Indexes (
    -- User (or bot) who states the statement.
    user_id BIGINT UNSIGNED NOT NULL,
    -- Index.
    idx_id BIGINT UNSIGNED NOT NULL,

    -- rat_val is changed for the subject's def_str in Indexes, when comparing
    -- to SemanticInputs.
    subj_def_str VARCHAR(255) NOT NULL,
    subj_id BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (
        user_id,
        pred_id,
        subj_def_str,
        subj_id
    ),

    UNIQUE INDEX (user_id, pred_id, subj_id)
);





CREATE TABLE Templates (
    -- Template ID.
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    -- String defining the term template (see initial_inserts.sql for some
    -- examples).
    tmpl_str VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,

    UNIQUE INDEX (tmpl_str)
);

CREATE TABLE Terms (
    -- Term ID.
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    -- Type of the term. Can be 'p' for Predicate, 'c' for Category, 'o' for
    -- Object, 'i' for Index, 'u' for User, 't' for Text, 'b' for Binary, or
    -- 'a' for Aggregation algorithms (Bots).
    -- Note that 'Object' here is used as a very broad term. So for any kind of
    -- Term that does not fit any of the other types, simply choose 'Object' as
    -- its type.
    -- All these types can have subclasses (and especially Objects), which is
    -- essentially what the Templates are used for defineing.
    type CHAR(1),
    -- ID of the template which defines how the defining string is to be
    -- interprested.
    tmpl_id BIGINT UNSIGNED,

    -- Defining string of the term. This can be a lexical item, understood in
    -- the context of the type alone if tmpl_id is null. If the tmpl_id is not
    -- null, the def_str can be a series of inputs separated by '|' of either
    -- IDs of the form "#<number>" (e.g. "#100") or any other string (e.g.
    -- "Physics"). These inputs is then plugged into the placeholders of the
    -- template in order of appearence and the resulting string is then
    -- interpreted in the context of the type to yield the definition of the
    -- Term.
    def_str VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,

    UNIQUE INDEX (type, tmpl_id, def_str)
);

INSERT INTO Terms (tmpl_id, type, def_str, id)
VALUES
    (NULL, 'c', "Terms", 1),
    (NULL, 'c', "Categories", 2),
    (NULL, 'c', "Predicates", 3),
    (NULL, 'c', "Objects", 4),
    (NULL, 'c', "Indexes", 5),
    (NULL, 'c', "Users", 6),
    (NULL, 'c', "Texts", 7),
    (NULL, 'c', "Binaries", 8),
    (NULL, 'c', "Aggregation algorithms (Bots)", 9),
    (NULL, 'u', "admin_1", 10),



CREATE TABLE Users (
    -- User ID.
    id BIGINT UNSIGNED PRIMARY KEY,

    username VARCHAR(50) UNIQUE,

    public_keys_for_authentication TEXT,
    -- (In order for third parties to be able to copy the database and then
    -- be able to have users log on, without the need to exchange passwords
    -- between databases.) (This could also be other data than encryption keys,
    -- and in principle it could even just be some ID to use for authenticating
    -- the user via a third party.)

    -- TODO: Implement managing of and restrictions on these fields when/if it
    -- becomes relevant:
    private_upload_vol_today BIGINT DEFAULT 0,
    private_download_vol_today BIGINT DEFAULT 0,
    private_upload_vol_this_month BIGINT DEFAULT 0,
    private_download_vol_this_month BIGINT DEFAULT 0
);

INSERT INTO Users (username, id)
VALUES ("admin_1", 10);



CREATE TABLE Texts (
    /* Text ID */
    id BIGINT UNSIGNED PRIMARY KEY,

    /* Data */
    str TEXT NOT NULL
);

CREATE TABLE Binaries (
    /* Binary string ID */
    id BIGINT UNSIGNED PRIMARY KEY,

    /* Data */
    bin LONGBLOB NOT NULL
);







CREATE TABLE PrivateCreators (
    term_id BIGINT UNSIGNED PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,
    INDEX (user_id)
);
-- (These should generally be deleted quite quickly, and instead a special bot
-- should rate which Term is created by which user, if and only if the given
-- user has declared that they are the creater themselves (by rating the same
-- predicate before the bot).)
