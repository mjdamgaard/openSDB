USE mydatabase;

-- DROP TABLE StatementInputs;
-- DROP TABLE Users;
-- DROP TABLE Bots;
-- DROP TABLE SimpleTerms;
-- DROP TABLE StandardTerms;
-- DROP TABLE CompoundTerms;
-- DROP TABLE Strings;
-- DROP TABLE Binaries;
-- DROP TABLE Lists;



/* Types */
-- SET @empty_t = -1;
-- SET @bot_t = 0;
-- SET @user_t = 1;
-- SET @simple_t = 2;
-- SET @standard_t = 3;
-- SET @compound_t = 4;
-- SET @string_t = 5;
-- SET @binary_t = 6;
-- SET @list_t = 7;





/* Statements which the users (or bots) give as input to the semantic network.
 * A central feature of this semantic system is that all such statements come
 * with a numerical value which represents the degree to which the user deems
 * that the statement is correct (like when answering a survey).
 **/
CREATE TABLE StatementInputs (
    -- subject of predicate or relation.
    subject_t TINYINT,
    subject_id BIGINT UNSIGNED,

    -- user or bot who states the statement.
    user_id BIGINT UNSIGNED,

    -- predicate or relation.
    pred_or_rel_t TINYINT,
    pred_or_rel_id BIGINT UNSIGNED,

    -- relation object (second input, so to speak) if pred_or_rel is a relation.
    object_t TINYINT,
    object_id BIGINT UNSIGNED,
    -- FOREIGN KEY (pred_or_rel) REFERENCES Term(id),


    -- numerical value (signed) which defines the degree to which the users
    -- (or bot) deems the statement to be true/fitting. When dividing with
    -- 2^63, this value runs from -1 to (almost) 1. And then -1 is taken to mean
    -- "very far from true/fitting," 0 is taken to mean "not sure / not
    -- particularly fitting or unfitting," and 1 is taken to mean "very much
    -- true/fitting."
    rating_value BIGINT UNSIGNED,

    -- In this version, a user or bot can only have one rating value per
    -- statement, which means that the combination of user and statement
    -- (subject, pred_or_rel and object) is unique for each row.
    PRIMARY KEY (
        subject_t, subject_id,
        user_id,
        pred_or_rel_t, pred_or_rel_id,
        object_t, object_id
    ),
    -- Additionally, I intend to create a clustered index on
    -- (subject, user, pred_or_rel) (in that order). (Part of the reason why
    -- is that I intend to implement all aggregates, such as average, via bots,
    -- which are also implemented as "Users.")


    -- preventing that relation--object combinations are saved as predicates,
    -- and thus that relation--object predicates are always saved in their
    -- exploded version in the StatementInputs rows.
    CHECK (
        -- either pred_or_rel is NOT a compound term...
        pred_or_rel_t <> 4 -- @compound_t
        -- ...or if it is, then it cannot be a predicate, and object thus has to
        -- not be an empty object.
        OR object_t <> -1 -- @empty_t
    )



    /* timestamp */
    -- created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE Bots (
    -- bot ID.
    -- type TINYINT = @bot_t,
    id BIGINT UNSIGNED CHECK (
        -- ensure that first byte of id is redundant such that the type flag
        -- is able to be sent via this byte for this type if desired.
        id <= 0x0011111111111111
    ),
    -- PRIMARY KEY(type, id),
    PRIMARY KEY(id),

    /* primary fields */
    description_t TINYINT,
    description_id BIGINT UNSIGNED
);


CREATE TABLE Users (
    -- user ID.
    -- type TINYINT = @user_t,
    id BIGINT UNSIGNED CHECK (
        -- ensure that first byte of id is redundant such that the type flag
        -- is able to be sent via this byte for this type if desired.
        id <= 0x0011111111111111
    ),
    -- PRIMARY KEY(type, id),
    PRIMARY KEY(id),

    /* primary fields */
    -- TBD.

    /* timestamp */
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);





-- * and "Simple" ones. Both subtypes take two inputs each in all three cases,
-- * which we will call descriptors (1 and 2).
-- *
-- * The "Simple" subtype takes as its first descriptor a string denoting af
-- * lexical item (a semantically meaningful part of a sentence). Examples of lex-
-- * ical items could be: "the number pi", "is subset of" (or "belongs to"), "has
-- * related link:", and "is funny".
-- * The second descriptor of the Simple subtype is an (optional) text descrip-
-- * tion, which can be used to explain the lexical item more thoroughly, and to
-- * clear up any potential ambiguities.
-- *
-- * The "Categorized" subtype, on the other hand, takes as its first descriptor
-- * a list of two element which are themselves lists. The first of these two sub-
-- * lists is a list of "categorizing predicates," which we will abbreviate as
-- * 'cpreds,' and the second sublist is a list of "specification relations,"
-- * which we will abbreviate as 'srels.'
-- * The list of cpreds... Hm, jeg tænkte lige for lidt siden, om ikke man bare
-- * skulle lave cpreds om til en liste af kategorier i stedet, men besluttede
-- * nej. Nu er jeg så lige blevet i tvivl igen: Skal cpreds ikke bare ændres til
-- * cats?.. (11:44)


/* Terms each fall into three subtypes: Simple, Standard, and Compound Terms.
 *
 * The "Simple" subtype takes as its first descriptor a string denoting af
 * lexical item (a semantically meaningful part of a sentence). Examples of
 * lexical items could be: "the number pi", "is subset of" (or "belongs to"),
 * "has related link:", and "is funny".
 * The second descriptor of the Simple subtype is an (optional) text descrip-
 * tion, which can be used to explain the lexical item more thoroughly, and to
 * clear up any potential ambiguities.
 **/


CREATE TABLE SimpleTerms (
    -- simple term ID.
    -- type TINYINT = @simple_t,
    id BIGINT UNSIGNED CHECK (
        -- ensure that first byte of id is redundant such that the type flag
        -- is able to be sent via this byte for this type if desired.
        id <= 0x0011111111111111
    ),
    -- PRIMARY KEY(type, id),
    PRIMARY KEY(id),

    /* The "Simple" subtype takes as its first descriptor a string denoting af
     * lexical item (a semantically meaningful part of a sentence). Examples of
     * lexical items could be: "the number pi", "is subset of" (or "belongs to"),
     * "has related link:", and "is funny".
     * The second descriptor of the Simple subtype is an (optional) text descrip-
     * tion, which can be used to explain the lexical item more thoroughly, and to
     * clear up any potential ambiguities.
     **/

    -- specifying lexical item.
    spec_lexical_item_t TINYINT,
    spec_lexical_item_id BIGINT,

    -- description.
    description_t TINYINT,
    description_id BIGINT UNSIGNED
);


CREATE TABLE StandardTerms (
    /* standard term ID */
    -- type TINYINT = @standard_t,
    id BIGINT UNSIGNED CHECK (
        -- ensure that first byte of id is redundant such that the type flag
        -- is able to be sent via this byte for this type if desired.
        id <= 0x0011111111111111
    ),
    -- PRIMARY KEY(type, id),
    PRIMARY KEY(id),


    -- specifying parent predicates.
    spec_parent_preds_t TINYINT,
    spec_parent_preds_id BIGINT UNSIGNED,

    -- specifying child predicates.
    spec_child_preds_t TINYINT,
    spec_child_preds_id BIGINT UNSIGNED
);


CREATE TABLE CompoundTerms (
    /* compound term ID */
    -- type TINYINT = @compound_t,
    id BIGINT UNSIGNED CHECK (
        -- ensure that first byte of id is redundant such that the type flag
        -- is able to be sent via this byte for this type if desired.
        id <= 0x0011111111111111
    ),
    -- PRIMARY KEY(type, id),
    PRIMARY KEY(id),


    -- relation (or perhaps function).
    rel_or_fun_t TINYINT,
    rel_or_fun_id BIGINT UNSIGNED,

    -- realtion object (or perhaps function input).
    input_t TINYINT,
    input_id BIGINT UNSIGNED
);



CREATE TABLE Strings (
    /* variable character string ID */
    -- type TINYINT = @string_t,
    id BIGINT UNSIGNED CHECK (
        -- ensure that first byte of id is redundant such that the type flag
        -- is able to be sent via this byte for this type if desired.
        id <= 0x0011111111111111
    ),
    -- PRIMARY KEY(type, id),
    PRIMARY KEY(id),


    /* data */
    str TEXT
);

CREATE TABLE Binaries (
    /* variable character string ID */
    -- type TINYINT = @binary_t,
    id BIGINT UNSIGNED CHECK (
        -- ensure that first byte of id is redundant such that the type flag
        -- is able to be sent via this byte for this type if desired.
        id <= 0x0011111111111111
    ),
    -- PRIMARY KEY(type, id),
    PRIMARY KEY(id),

    /* data */
    bin BLOB
);

-- Remember that this table has to be compressed so that nulled elements (and
-- tail) require no extra storage.
CREATE TABLE Lists (
    /* variable character string ID */
    -- type TINYINT = @binary_t,
    id BIGINT UNSIGNED CHECK (
        -- ensure that first byte of id is redundant such that the type flag
        -- is able to be sent via this byte for this type if desired.
        id <= 0x0011111111111111
    ),
    -- PRIMARY KEY(type, id),
    PRIMARY KEY(id),

    /* data */
    element_1_t TINYINT,
    element_1_id BIGINT UNSIGNED,
    element_2_t TINYINT,
    element_2_id BIGINT UNSIGNED,
    element_3_t TINYINT,
    element_3_id BIGINT UNSIGNED,
    element_4_t TINYINT,
    element_4_id BIGINT UNSIGNED,
    element_5_t TINYINT,
    element_5_id BIGINT UNSIGNED,
    element_6_t TINYINT,
    element_6_id BIGINT UNSIGNED,
    element_7_t TINYINT,
    element_7_id BIGINT UNSIGNED,
    element_8_t TINYINT,
    element_8_id BIGINT UNSIGNED,
    element_9_t TINYINT,
    element_9_id BIGINT UNSIGNED,
    element_10_t TINYINT,
    element_10_id BIGINT UNSIGNED,

    tail BIGINT UNSIGNED,
);


-- TODO: change to a join on type as a virtual columns and also on id.
CREATE VIEW Terms AS
SELECT (type, id, descriptor_1, descriptor_2) FROM
    SELECT (
        type, id,
        spec_lexical_item AS descriptor_1,
        description       AS descriptor_2
    )
    FROM SimpleTerms
    UNION
    SELECT (
        type, id,
        spec_parent_preds AS descriptor_1,
        spec_child_preds  AS descriptor_2
    )
    FROM StandardTerms
    UNION
    SELECT (
        type, id,
        rel_or_fun AS descriptor_1,
        input      AS descriptor_2
    )
    FROM CompoundTerms;

-- TODO: change these type codes.
-- type code for DateTime: 6.
-- type code for Year: 7.
-- type code for Date: 8.
-- type code for Time: 9.

-- type code for Bool 10.
-- type code for TinyInt: 11.
-- type code for SmallInt: 12.
-- type code for MediumInt: 13.
-- type code for Int: 14.
-- type code for BigInt: 18.






-- -- type code for MBlob: 38.
-- CREATE TABLE MBlobs (
--     /* medium BLOB ID */
--     id BIGINT AUTO_INCREMENT,
--     PRIMARY KEY(id),
--
--     /* data */
--     bin MEDIUMBLOB
-- );
--
-- -- saving LBlobs for later.
--
--
--
-- -- (List0 does not need its own table.)
-- -- type code for L0List: 40.
--
-- -- type code for L1List: 41.
-- CREATE TABLE L1Lists (
--     /* length 1 list ID */
--     id BIGINT AUTO_INCREMENT,
--     PRIMARY KEY(id),
--
--     /* primary fields */
--     element_1 BIGINT,
--
--     /* database types (tables) of primary fields */
--         /* element types */
--         -- allowed element types: any (so no constraints).
--         element_1_type TINYINT
--     /**/
-- );
--
-- -- type code for L2List: 42.
-- CREATE TABLE L2Lists (
--     /* length 2 list ID */
--     id BIGINT AUTO_INCREMENT,
--     PRIMARY KEY(id),
--
--     /* primary fields */
--     element_1 BIGINT,
--     element_2 BIGINT,
--
--     /* database types (tables) of primary fields */
--         /* element types */
--         -- allowed element types: any (so no constraints).
--         element_1_type TINYINT,
--         element_2_type TINYINT
--     /**/
-- );
--
-- -- type code for L3List: 43.
-- CREATE TABLE L3Lists (
--     /* length 3 list ID */
--     id BIGINT AUTO_INCREMENT,
--     PRIMARY KEY(id),
--
--     /* primary fields */
--     element_1 BIGINT,
--     element_2 BIGINT,
--     element_3 BIGINT,
--
--     /* database types (tables) of primary fields */
--         /* element types */
--         -- allowed element types: any (so no constraints).
--         element_1_type TINYINT,
--         element_2_type TINYINT,
--         element_3_type TINYINT
--     /**/
-- );
--
-- -- type code for L4List: 44.
-- CREATE TABLE L4Lists (
--     /* length 4 list ID */
--     id BIGINT AUTO_INCREMENT,
--     PRIMARY KEY(id),
--
--     /* primary fields */
--     element_1 BIGINT,
--     element_2 BIGINT,
--     element_3 BIGINT,
--     element_4 BIGINT,
--
--     /* database types (tables) of primary fields */
--         /* element types */
--         -- allowed element types: any (so no constraints).
--         element_1_type TINYINT,
--         element_2_type TINYINT,
--         element_3_type TINYINT,
--         element_4_type TINYINT
--     /**/
-- );
--
-- -- saving larger fixed-length lists for later.
--
--
-- -- type code for LongList: 51.
-- CREATE TABLE LongLists (
--     /* long (+10) length list ID */
--     id BIGINT AUTO_INCREMENT,
--     PRIMARY KEY(id),
--
--     /* primary fields */
--     element_1 BIGINT,
--     element_2 BIGINT,
--     element_3 BIGINT,
--     element_4 BIGINT,
--     element_5 BIGINT,
--     element_6 BIGINT,
--     element_7 BIGINT,
--     element_8 BIGINT,
--     element_9 BIGINT,
--     element_10 BIGINT,
--     tail BIGINT,
--
--     /* database types (tables) of primary fields */
--         /* element types */
--         -- allowed element types: any (so no constraints).
--         element_1_type TINYINT,
--         element_2_type TINYINT,
--         element_3_type TINYINT,
--         element_4_type TINYINT,
--         element_5_type TINYINT,
--         element_6_type TINYINT,
--         element_7_type TINYINT,
--         element_8_type TINYINT,
--         element_9_type TINYINT,
--         element_10_type TINYINT,
--
--         /* tail types */
--         -- allowed tail types: any List types.
--         tail_type TINYINT CHECK (
--             tail_type >= 40 -- all List types
--         )
--     /**/
-- );
