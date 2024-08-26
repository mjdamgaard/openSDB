
/* Semantic inputs */
DROP TABLE SemanticInputs;
DROP TABLE RecordedInputs;
/* Indexes */
DROP TABLE IndexedEntities;

/* Entities */
DROP TABLE Entities;

-- /* Data */
-- DROP TABLE SimpleEntityData;
-- DROP TABLE AssocEntityData;
-- DROP TABLE FormalEntityData;
-- DROP TABLE PropertyTagData;
-- DROP TABLE StatementData;
-- DROP TABLE ListData;
-- DROP TABLE PropertyDocData;
-- DROP TABLE TextData;
-- DROP TABLE BinaryData;
-- DROP TABLE UserData;
-- DROP TABLE NativeBotData;

/* Users and Bots */
DROP TABLE Users;
DROP TABLE AggregationBots;

/* Ancillary data for aggregation bots */
DROP TABLE AncillaryBotData1e2d;
DROP TABLE AncillaryBotData1e4d;

/* Private user data */
DROP TABLE Private_UserData;
DROP TABLE Private_Sessions;
DROP TABLE Private_EMails;



/* Semantic inputs */

/* Semantic inputs are the statements that the users (or aggregation bots) give
 * as input to the semantic network. A central feature of this semantic system
 * is that all such statements come with a numerical value which represents the
 * degree to which the user deems that the statement is correct (like when
 * answering a survey).
 * The statements in this system are always formed from a tag entity and an
 * instance entity. The user thus states that the latter is an instance of the
 * given tag. The rating then tells how well the tag first the instance.
 **/

CREATE TABLE SemanticInputs (
    -- User (or bot) who states the statement.
    user_id BIGINT UNSIGNED NOT NULL,

    -- Tag of the statement.
    tag_id BIGINT UNSIGNED NOT NULL,

    -- Rating value of how well the tag fits the entity. The first byte
    -- of the TINYINT runs from 1 to 255, where 1
    -- means 'absolutely/perfectly not,' 128 means 'doesn't particularly fit or
    -- not fit,' and 255 means 'absolutely/perfectly.'
    rat_val TINYINT UNSIGNED NOT NULL,
    CHECK (rat_val != 0),

    -- The so-called instance of the tag, or rather the potential instance:
    -- How well the instance fits the tag is thus determined by the rating,
    -- which might also be below neutral, meaning that the instance does not
    -- fit the tag.
    inst_id BIGINT UNSIGNED NOT NULL,

    -- Resulting semantic input: "User #<user_id> states that entity 
    -- #<inst_id> fits the tag #<tag_id> on a scale
    -- from 0 to 10 (with 5 being neutral) by <rat_val> / 6553.5."

    PRIMARY KEY (
        user_id,
        tag_id,
        rat_val,
        inst_id
    ),

    UNIQUE INDEX (user_id, tag_id, inst_id)
);
-- TODO: Compress this table and its sec. index, as well as some other tables
-- and sec. indexes below. (But compression is a must for this table.)
-- There is also the option to create a sec. index: (tag_id, inst_id, rat_val,
-- user_id), but I actually think that it is better to implement semantically,
-- e.g. by using the "statement_user_rater_bot," namely since this better
-- allows for filtering such user lists.. 


-- RecordedInputs can first of all be used by time-dependent bots (e.g. a mean-
-- of-recent-inputs bot), and can also potentially used by bots that update on
-- scheduled events rather than immediately when the input is received. And
-- furthermore, they can also potentially be used by third-party bots and by
-- SDB peers.
CREATE TABLE RecordedInputs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,
    -- tag_id BIGINT UNSIGNED NOT NULL,
    -- inst_id BIGINT UNSIGNED NOT NULL,
    stmt_id BIGINT UNSIGNED NOT NULL,
    -- A rating value of NULL means 'take my rating away,' making it 'missing'/
    -- 'deleted.'
    rat_val TINYINT UNSIGNED,

    -- UNIQUE INDEX (tag_id, inst_id, id)
    UNIQUE INDEX (stmt_id, id)
);



/* Indexes */

CREATE TABLE IndexedEntities (
    -- Index entity which defines the restrictions on the entity keys.
    idx_id BIGINT UNSIGNED NOT NULL,

    /* The entity index */
    -- Given some constants for the above two columns, the "entity indexes"
    -- contain the "entity keys," which are each just the secondary index of an
    -- entity.
    key_str VARCHAR(255) NOT NULL,


    ent_id BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (
        idx_id,
        key_str,
        ent_id -- (A single key might in principle index several entities.) 
    )
);
-- (Also needs compressing.)

-- I intend to at some point copy at least one of these indexes (with a
-- specific idx_id) over in another table with a FULLTEXT index on the str
-- column. But I will do this in another file, then.





/* Entities */

CREATE TABLE Entities (
    -- Entity ID.
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    -- Template ID: An entity that this entity inherits properties from.
    -- the a template entity holds a template property which is a JSON object
    -- containing the properties of the instance entities, where some of the
    -- property values might include placeholders of the form '%1', '%2', etc.,
    -- or of the form '%b', '%t', or '%t1', '%t2', etc. ('%' is escaped by
    -- '\%'.)
    template_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    -- (A majority of entities will have a parent, so we use 0 instead of NULL.)

    -- Template input: A list of inputs separated by '|', which substitutes the
    -- /%[1-9][0-9]*/ placeholders of the template. ('|' is escaped by '\|'.)
    template_input VARCHAR(255) NOT NULL DEFAULT "",
    -- (We use "" for no specifying inputs.)

    -- Own property data structure (struct) containing the specific properties
    -- of this entity, and formatted as a JSON object. If a property value is
    -- an array, it is interpreted as a set (used for one-to-many properties,
    -- such as e.g. movie->actor). An array nested directly inside of an array
    -- is interpreted as a ordered list, however. (When in doubt of whether to
    -- define an entity via an ordered list or a set, use a set.) 
    property_struct TEXT DEFAULT NULL,
    property_struct_hash VARCHAR(255) NOT NULL DEFAULT (
        CASE
            WHEN property_struct IS NULL OR property_struct = "" THEN ""
            ELSE SHA2(property_struct, 224)
        END
    ),


    -- Data input: A TEXT or BLOB that which can be large enough that one might
    -- want to store it outside of the PRIMARY INDEX, and might want to only
    -- serve to the client upon specific request, and not whenever the client
    -- looks up defining data for the entity. This inputs either replaces the
    -- '%b' or '%t' placeholder ('b' for binary, 't' for text) in
    -- property_struct, or it is also split into multiple strings using '|'
    -- as a delimiter, in case of the '%t<num>' placeholders. ('|' is also
    -- escaped by '\|' here.)
    data_input LONGBLOB DEFAULT NULL,
    data_input_hash VARCHAR(255) NOT NULL DEFAULT (
        CASE
            WHEN data_input IS NULL OR data_input = "" THEN ""
            ELSE SHA2(data_input, 224)
        END
    ),
    -- (Any size restriction on this BLOB is implemented in the control layer,
    -- or in the interface with it, i.e. in the "input procedures.")


    UNIQUE INDEX (
        template_id, template_input, property_struct_hash, data_input_hash
    ),


    -- ID of the creator, i.e. the user who uploaded this entity.
    creator_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    -- (A majority of entities will have a creator.)

    UNIQUE INDEX (creator_id, id)
);


/* Some initial inserts */

INSERT INTO Entities
    (id, template_id, template_input, property_struct, data_input)
VALUES
    -- TODO: Add 'initial description's (with data_input text as the value).
    (1, 0, '', '{"type":"user","username":"%1"}', NULL),
    (2, 0, '', '{"type":"tag","title":"%1"}', NULL),
    (3, 0, '', '{"title":"%1"}', NULL),
    (4, 0, '', '{"type":"property","title":"%1"}', NULL),
    (5, 0, '', CONCAT(
        '{"type":["tag","property tag"],"subject":"%1","property":"%2",'
        '"title":"%2 of %1"}'
    ), NULL),
    (6, 1, 'initial_user', NULL, NULL),
    (7, 0, '', '{"type":"list","elements":"%1"}', NULL),
    (8, 5, '@6|type', NULL, NULL),
    (9, 0, '', CONCAT(
        '{"type":["tag","relevant properties tag"],"subject":"%1",',
        '"title":"relevant properties of %1"}'
    ), NULL),
    (10, 2, 'entity', NULL, NULL),
    -- 
    (NULL, 3, 'exAmpLe of A noT very usefuL enTiTy', NULL, NULL);


-- [...] If data_input is a binary file, '%b' is used, but this should
-- conventionally only be used for special file classes (which defines the
-- file format but no other metadata about the file). 
-- Special characters are '%', '@', which are escaped with backslashes,
-- as well as the other special characters of JSON, of course (escaped the
-- JSON way), in case of the propStruct. For the tmplInput, the separator '|'
-- is also special, also escaped by a backslash.
-- '@' is used to write IDs, namely by writing e.g. '"@6"' which refers the the
-- "initial_user" entity.







/* Users */

CREATE TABLE Users (
    -- User data key (private).
    data_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    username VARCHAR(50) NOT NULL,
    -- TODO: Consider adding more restrictions.

    public_keys_for_authentication TEXT,
    -- (In order for third parties to be able to copy the database and then
    -- be able to have users log on, without the need to exchange passwords
    -- between databases.) (This could also be other data than encryption keys,
    -- and in principle it could even just be some ID to use for authenticating
    -- the user via a third party.)

    UNIQUE INDEX (username)
);


/* Native aggregation bots (or simply 'bots' for short) */

CREATE TABLE AggregationBots (
    -- Aggregation bot data key (private).
    data_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    bot_name VARCHAR(255) NOT NULL,

    bot_description TEXT,

    UNIQUE INDEX (bot_name)
);






/* Ancillary data for aggregation bots */


CREATE TABLE AncillaryBotData1e2d (
    -- Name of the bot that uses this data.
    bot_name VARCHAR(255) NOT NULL,
    -- Entity which the data is about.
    ent_id BIGINT UNSIGNED NOT NULL,

    -- Data.
    -- data_1 BIGINT UNSIGNED NOT NULL,
    -- data_2 BIGINT UNSIGNED NOT NULL,
    data_1 BIGINT UNSIGNED,
    data_2 BIGINT UNSIGNED,
    -- TODO: Check mean_bots.sql to see if it is okay to make these  columns
    -- NOT NULL, and if not, change mean_bots.sql so that it can be done.

    PRIMARY KEY (
        bot_name,
        ent_id
    )
);
-- TODO: Compress.

CREATE TABLE AncillaryBotData1e4d (
    -- Name of the bot that uses this data.
    bot_name VARCHAR(255) NOT NULL,
    -- Entity which the data is about.
    ent_id BIGINT UNSIGNED NOT NULL,

    -- Data.
    data_1 BIGINT UNSIGNED NOT NULL,
    data_2 BIGINT UNSIGNED NOT NULL,
    data_3 BIGINT UNSIGNED NOT NULL,
    data_4 BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (
        bot_name,
        ent_id
    )
);
-- TODO: Compress.
-- TODO: Add other BotData_n_m tables if need be (and BotData_1_4 is only for
-- show right now).



/* Private user data */

CREATE TABLE Private_UserData (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    password_hash VARBINARY(255),

    username VARCHAR(50) NOT NULL UNIQUE,
    -- TODO: Consider adding more restrictions.

    public_keys_for_authentication TEXT,
    -- (In order for third parties to be able to copy the database and then
    -- be able to have users log on, without the need to exchange passwords
    -- between databases.) (This could also be other data than encryption keys,
    -- and in principle it could even just be some ID to use for authenticating
    -- the user via a third party.)


    -- TODO: Implement managing of and restrictions on these fields when it
    -- becomes relevant:
    private_upload_vol_today BIGINT NOT NULL DEFAULT 0,
    private_download_vol_today BIGINT NOT NULL DEFAULT 0,
    private_upload_vol_this_month BIGINT NOT NULL DEFAULT 0,
    private_download_vol_this_month BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE Private_Sessions (
    user_id BIGINT UNSIGNED PRIMARY KEY,
    session_id VARBINARY(255) NOT NULL,
    expiration_time BIGINT UNSIGNED NOT NULL -- unix timestamp.
);

CREATE TABLE Private_EMails (
    e_mail_address VARCHAR(255) PRIMARY KEY,
    number_of_accounts TINYINT UNSIGNED NOT NULL,
    -- This field is only temporary, until the e-mail address holder has
    -- confirmed the new account:
    account_1_user_id BIGINT UNSIGNED
);
