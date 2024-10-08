
/* Ratings */
-- DROP TABLE AtomicStatementScores;
-- DROP TABLE PredicativeStatementScores;
-- DROP TABLE RelationalStatementScores;

-- DROP TABLE RecordedInputs;

/* Indexes */
-- DROP TABLE IndexedEntities;

/* Entities */
DROP TABLE Entities;

/* Users and Bots */
-- DROP TABLE Users;
-- DROP TABLE AggregationBots;

/* Ancillary data for aggregation bots */
-- DROP TABLE AncillaryBotData1e2d;
-- DROP TABLE AncillaryBotData1e4d;

/* Private user data */
-- DROP TABLE Private_UserData;
-- DROP TABLE Private_Sessions;
-- DROP TABLE Private_EMails;



/* Semantic inputs */

/* Semantic inputs are the statements that the users (or aggregation bots) give
 * as input to the semantic network. A central feature of this semantic system
 * is that all such statements come with a numerical value which qualifies
 * the statement.
 **/


CREATE TABLE AtomicStatementScores (
    -- User (or bot) who scores the statement.
    user_id BIGINT UNSIGNED NOT NULL,

    -- Statement.
    stmt_id BIGINT UNSIGNED NOT NULL,

    -- Score value. This value qualifies the statement. It might represent a
    -- grade that scores the statement on some grading scale, or a likelihood
    -- of how probable the stmt is, or it might even represent a quantity. For
    -- instance 'x costs money' might be qualified by a score in units of the
    -- money that x is believed to cost.
    score_val FLOAT NOT NULL,

    -- Rating error (standard deviation).
    score_err FLOAT UNSIGNED NOT NULL,

    PRIMARY KEY (
        user_id,
        stmt_id
    )

    -- Still better to use a bot for this instead:
    -- -- Index to look up users who has rated the statement.
    -- UNIQUE INDEX (stmt_id, score_val, score_err, user_id)
);


CREATE TABLE PredicativeStatementScores (
    -- User (or bot) who scores the statement.
    user_id BIGINT UNSIGNED NOT NULL,

    -- Predicate that forms the statement together with the subject.
    pred_id BIGINT UNSIGNED NOT NULL,

    -- Subject that forms the statement together with the predicate.
    subj_id BIGINT UNSIGNED NOT NULL,

    -- --"--
    score_val FLOAT NOT NULL,
    -- --"--
    score_err FLOAT UNSIGNED NOT NULL,

    PRIMARY KEY (
        user_id,
        pred_id,
        score_val,
        subj_id,
        score_err
    ),

    -- Index to look up specific rating (and restricting one rating pr. user.)
    UNIQUE INDEX (user_id, pred_id, subj_id)

    -- Still better to use a bot for this instead:
    -- -- Index to look up users who has rated the stmt / rating scale.
    -- UNIQUE INDEX (pred_id, subj_id, score_val, score_err, user_id)
);



CREATE TABLE RelationalStatementScores (
    -- User (or bot) who scores the statement.
    user_id BIGINT UNSIGNED NOT NULL,

    -- Relation that forms the stmt together with the object and subject.
    rel_id BIGINT UNSIGNED NOT NULL,

    -- Object that forms the stmt together with the relation and subject.
    obj_id BIGINT UNSIGNED NOT NULL,

    -- Subject that forms the stmt together with the relation and object.
    subj_id BIGINT UNSIGNED NOT NULL,

    -- --"--
    score_val FLOAT NOT NULL,
    -- --"--
    score_err FLOAT UNSIGNED NOT NULL,

    PRIMARY KEY (
        user_id,
        obj_id,
        rel_id,
        score_val,
        subj_id,
        score_err
    ),

    -- Index to look up specific rating (and restricting one rating pr. user.)
    UNIQUE INDEX (user_id, obj_id, rel_id, subj_id)

    -- Still better to use a bot for this instead:
    -- -- Index to look up users who has rated the stmt / rating scale.
    -- UNIQUE INDEX (obj_id, rel_id, subj_id, score_val, score_err, user_id)

    -- All relations are directional, so we don't need:
    -- UNIQUE INDEX (user_id, subj_id, rel_id, obj_id)
);

-- TODO: Compress these tables and their sec. index, as well as other tables
-- and sec. indexes below.




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
    rat_val FLOAT UNSIGNED,

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

-- CREATE TABLE EntityIDIntervals (
--     -- The start of the interval. The end is just before the next head_id in
--     -- this table, which just hold a NULL user_id when it is not reserved yet,
--     -- and is currently the last one of the table.
--     head_id INT UNSIGNED NOT NULL,

--     -- The length of the interval
--     interval_length BIGINT UNSIGNED NOT NULL,

--     -- The start of the parent interval, in which this interval is nested.
--     parent_head_id BIGINT UNSIGNED NOT NULL,

--     -- The user who reserved the interval.
--     user_id BIGINT UNSIGNED NOT NULL,

--     -- A key to guard against unintentionally repeated reservations/insertions.
--     -- If a user uses the same key twice, we simply return the same interval,
--     -- rather than reserving a new one. 
--     next_interval BIGINT UNSIGNED,

--     UNIQUE INDEX (user_id, interval_key),

--     -- A boolean of whether the 
--     is_finalized BOOL NOT NULL DEFAULT 0
-- );
-- INSERT INTO AllocatedIDIntervals (
--     head_id,
--     interval_length,
--     parent_head_id,
--     user_id,
--     interval_key
-- )
-- VALUES (
--     1,
--     100000000000000,
--     -- (Initially we just allocate a very large part of the space, and make
--     -- sure to only fill up from bottom to top, not expecting overflow. Then
--     -- once we start making the database distributed, we can resize this
--     -- interval and reimplement the reserveInterval() procedure.)
--     0,
--     1,
--     0

-- );
-- -- We assume that the administrator user of this database node is represented
-- -- by the entity with id = 1.




CREATE TABLE Entities (
    -- Entity ID.
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,


    -- A JSON value (string or object, or array) that defines the entity.
    def_str TEXT NOT NULL, -- (Can be resized.)

    def_hash CHAR(64) NOT NULL DEFAULT (SHA2(def_str, 256)),

    -- The user who submitted the entity, unless creator_id = 0, which means
    -- that the creator is anonymous and have forfeited the rights to edit
    -- the entity, but on the other hand, it can now be searched on the
    -- (is_private, def_hash, creator_id) index without knowing its original
    -- creator.
    creator_id BIGINT UNSIGNED NOT NULL DEFAULT 0,

    -- A boolean representing whether this entity can be viewed by anyone other
    -- than its creator.
    is_private TINYINT UNSIGNED NOT NULL DEFAULT 1,
    CHECK (is_private <= 1),

    creation_ident VARBINARY(255) NOT NULL DEFAULT "",

    CHECK (creator_id != 0 OR is_private),

    UNIQUE INDEX (is_private, def_hash, creator_id),

    UNIQUE INDEX (creator_id, creation_ident, id),

    modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    -- The modified_at field is (potentially) for future use.
);


/* Some initial inserts */

INSERT INTO Entities (
    id, def_strrrrr
)
VALUES
    (1, CONCAT(
        '"',
        "<h1><class>class</class></h1>",
        "<h2>Description</h2>",
        "<p>A class of all class entities (including itself). ",
        "Classes both serve as a broad way of categorizing entities, ",
        "and they are also used to define the meaning of their instances, ",
        "as their <attr>description</attr> will be shown on the info page ",
        "of each of their instances.",
        "</p>",
        "<p>As an example, this description of the <class>class</class> ",
        "entity will be shown on the info page of all class entities, just ",
        "above the description of the general <class>entity</class> class.",
        "</p>",
        "<p>The <attr>description</attr> of a class should include a ",
        "section of 'special attributes,' if it defines a new attribute ",
        "or redefines an attribute of a superclass (opposite of 'subclass'). ",
        "As an example, since the <class>class</class> class introduces an ",
        "optional <attr>superclass</attr> attribute and expands on the ",
        "<attr>description</attr> attribute, the following 'special ",
        "attributes' section will include a description of both these ",
        "attributes.",
        "</p>",
        "<h2>Special attributes</h2>",
        "<h3><attr>description</attr></h3>",
        "<flags><flag>mandatory</flag><flag>extends superclass</flag></flags>",
        "<p>...",
        "</p>",
        "<h3><attr>superclass</attr></h3>",
        "<flags><flag>optional</flag></flags>",
        "<p>...",
        "</p>",
        '"'
    )),
    (2, CONCAT(
        '{"classes":["@this"],"description":["@1"],"title":"class"}'
    )),
    (3, CONCAT(
        '"',
        "A class of all entities (including itself).\n",
        '"'
    )),
    (4, CONCAT(
        '{"classes":["@2"],"descriptions":["@3"],"title":"entity"}'
    )),
    (NULL, '"exAmpLe of A noT very usefuL enTiTy"');
    -- (1, 1, SHA2(CONCAT(
    --     "A class of all 'statement' entities, which can be scored by the ",
    --     "users in order to express their opinions and beliefs. ",
    --     "A statement can for instance be '<Movie> is funny,' which might ",
    --     "be scored by the users on a grading scale (A, B, C, D, F), and/or "
    --     "a n-star scale. ",
    --     "It can also be something like '<Movie> is an animated movie,' which ",
    --     "might then be scored on a true-false scale (i.e. a likelihood ",
    --     "scale) instead. ",
    --     "Or it can be a statement concerning some quantity, such as ",
    --     "'<Movie> has a length of x h,' where x here is taken to reference ",
    --     "the score itself with which the users can qualify the ",
    --     "statement. ",
    --     "Note that it is the job of a 'statement' entity to define the scale ",
    --     "that it is qualified by.\n"
    --     "Unless otherwise specified (by the @13 subclass), statements ",
    --     "Always talk about the thing that the entity represents, and not the ",
    --     "representation itself."
    -- ), 256), SHA2(CONCAT(
    --     '{"title":"statement"}'
    -- ), 256), ""),
    -- (1, 1, SHA2(CONCAT(
    --     "A class of all 'predicate' entities, which can be combined with a ",
    --     "another 'subject' entity in order to form a @3 entity. ",
    --     "Predicates must not require any specification other than said ",
    --     "subject entity in order to form a well-formed @3 entity."
    -- ), 256), SHA2(CONCAT(
    --     '{"title":"predicate"}'
    -- ), 256), ""),
    -- (1, 1, SHA2(CONCAT(
    --     "A class of all 'relation' entities, which can be combined with a ",
    --     "another 'object' entity in order to form a @4 entity. ",
    --     "Relations must not require any specification other than said ",
    --     "object entity in order to form a well-formed @4 entity. ",
    --     "Note that since predicates also takes a subject in order to form a ",
    --     "@3 entity, this means that relations are essentially binary ",
    --     "functions that returns a statement."
    -- ), 256), SHA2(CONCAT(
    --     '{"title":"relation"}'
    -- ), 256), ""),
    -- (1, 1, SHA2(CONCAT(
        
    -- ), 256), SHA2(CONCAT(
        
    -- ), 256), ""),
    -- (6, 1, 0, '', '', CONCAT(
    --     '{"title":"template"}'
    -- ), CONCAT(
    --     "A class of all 'template' entities, which ",
    --     "can be used to define new entities with defining data that ",
    --     "follow a specific format. The only property that defines an ",
    --     "entity of this template class ",
    --     "is the 'template' property, which is a variable property structure ",
    --     "that has placeholders for substitution. ...TODO: Continue."
    -- ), NULL),
    -- (7, 1, 0, '', '', CONCAT(
    --     '{"title":"user"}'
    -- ), CONCAT(
    --     "A class of the users of this Semantic Network. Whenever a ",
    --     "new user is created, an entity of this 'user' class is created to ",
    --     "represent this new user."
    -- ), NULL),
    -- (8, 6, 0, '', '', CONCAT(
    --     '{"template":{"username":"%s"}}' -- "class":"@7"
    -- ), CONCAT(
    --     "A @6 used to create user entities."
    -- ), CONCAT(
    --     "A @7 of this Semantic Network."
    -- )),
    -- (9, 1, 0, '', '', CONCAT(
    --     '{"title":"text"}'
    -- ),  CONCAT(
    --     "A class of texts. These are all strings of characters that has some ",
    --     "(at least partial) meaning attached to them. ",
    --     "Some text entities might also have more data (metadata) about them. ",
    --     "For instance, and article or a comment might also include an author ",
    --     "and a date."
    -- ), NULL),
    -- -- Note that we don't need a pure text data class/template, since we
    -- -- already the ability to write texts in other_props and in data_input.
    -- (10, 1, 0, '', '', CONCAT(
    --     '{"title":"lexical item","superclass":"@9"}'
    -- ),  CONCAT(
    --     "A class of lexical items, which are any part of a sentence that can ",
    --     "be said to have a meaning of its own, even if it cannot stand alone ",
    --     "in a well-formed sentence. An example is a compound verb. ",
    --     "Lexical items form a general class of what one might look up in a ",
    --     "an extended dictionary that also includes things like phrases, and ",
    --     "not just words." 
    -- ), NULL),
    -- (11, 1, 0, '', '', CONCAT(
    --     '{"title":"word","superclass":"@10"}'
    -- ),  CONCAT(
    --     "A class of words. This class also includes compound words such as ",
    --     "e.g. 'apple tree' and 'turned off.' Proper nouns are also included." 
    -- ), NULL),
    -- (12, 1, 0, '', '', CONCAT(
    --     '{"title":"scale type"}'
    -- ),  CONCAT(
    --     "A class the descriptions and accompanying data structures (structs) ",
    --     "that goes ",
    --     "into defining the scales that qualifies the @3 entities when these ",
    --     "are scored by the users."
    -- ), NULL),
    -- (13, 1, 0, '', '', CONCAT(
    --     '{"title":"data statement","superclass":"@3"}'
    -- ), CONCAT(
    --     "A class of all statements that do not talk about the thing that ",
    --     "the entities represent, but talk about the representation of the ",
    --     "entities, i.e. the defining data of the entities in the database. "
    --     "A good example is a statement saying that a subject is a more ",
    --     "popular duplicate of the same entity. "
    --     "Or that a subject is a better/more useful representation of the ",
    --     'entity (giving us a way to essentially "edit" entities).'
    -- ), NULL),
    -- (14, 1, 0, '', '', CONCAT(
    --     '{"title":"data predicate","superclass":"@4"}'
    -- ), CONCAT(
    --     "A class of all @4 entities that is used to form @13 entities."
    -- ), NULL),
    -- (15, 1, 0, '', '', CONCAT(
    --     '{"title":"data relation","superclass":"@5"}'
    -- ), CONCAT(
    --     "A class of all @5 entities that is used to form @14 and ",
    --     "@13 entities."
    -- ), NULL),
    -- (16, 6, 0, '', '', CONCAT(
    --     -- "class":"@3"
    --     '{"template":{"statement":"%s","scale type":"@21"}}'
    -- ), CONCAT(
    --     "A @6 that can be used to create @3 entities from texts, ",
    --     "scored on the @21."
    -- ), CONCAT(
    --     "A @3 stating that @[Statement] is true, scored on the @21."
    -- )),
    -- (17, 6, 0, '', '', CONCAT(
    --     -- "class":"@4"
    --     '{"template":{"predicate":"%s","subject class":"%e1",',
    --     '"statement":"@[Subject] fits @[Predicate]",',
    --     '"scale type":"@22"}}'
    -- ), CONCAT(
    --     "A @6 that can be used to create @4 entities from adjectives or ",
    --     "verbs, scored on the @22.\n",
    --     -- "@[Predicate] should either be a (compound) adjective, ",
    --     -- "a (compound) verb, or a (compound) noun, in which case we interpret ",
    --     -- "the predicate to be 'is a/an @[Predicate]'. If you want to..."
    --     "@[Predicate] should either be a (compound) adjective or ",
    --     "a (compound) verb. However, by writing e.g. 'is a'/'is an', or ",
    --     "'has'/'contains' in a parenthesis at the beginning of @[Predicate], ",
    --     "the app can cut away this parenthesis when rendering the title of ",
    --     "the entity in most cases. For instance, you might write '(is a) ",
    --     "sci-fi movie' as @[Predicate], which can then be rendered as ",
    --     "'sci-fi movie,' since the 'is a' part will generally be implicitly ",
    --     "understood anyway. Or you might write '(has) good acting', which ",
    --     "can then be rendered simply as 'good acting.' And as a last ",
    --     "example, one could also write '(contains) spoilers' as ",
    --     "@[Predicate], which can then be rendered simply as 'spoilers.'"
    -- ), CONCAT(
    --     "A @4 formed from an adjective or a verb (@[Predicate]), ",
    --     "scored on the @21."
    -- )),
    -- (18, 6, 0, '', '', CONCAT(
    --     -- "class":"@4"
    --     '{"template":{"statement":"%s","subject class":"%e1",',
    --     '"scale type":"@22"}}'
    -- ), CONCAT(
    --     "A @6 that can be used to create @4 entities with complicated ",
    --     "formulations, scored on the @22.\n",
    --     "@[Statement] should be a complicated sentence describing a ",
    --     "predicate, referring directly to '@[Subject]'. If the predicate can ",
    --     "be formulated simply as '@[Subject] <some verb>', use @17 instead."
    -- ), CONCAT(
    --     "A @4 formed from a whole statement, referring to @[Subject] ",
    --     "as the subject of the predicate. It is scored on the @22."
    -- )),
    -- (19, 6, 0, '', '', CONCAT(
    --     -- "class":"@5"
    --     '{"template":{"noun":"%s",',
    --     '"subject class":"%e1","object class":"%e2",',
    --     '"predicate":"is the %s of @[Object]",',
    --     '"statement":"@[Subject] is the %s of @[Object]",',
    --     '"scale type":"@21"}}'
    -- ), CONCAT(
    --     "A @6 that can be used to create factual @5 entities from ",
    --     "(singular) nouns, scored on the @21.\n",
    --     "@[Noun] should be a singular (compound) noun."
    -- ), CONCAT(
    --     "A factual @5 formed from a (singular) noun, stating the @[Noun] ",
    --     "of @[Object] is the @[Subject]. As a factual @5, it is scored on ",
    --     "the @21."
    -- )),
    -- (20, 6, 0, '', '', CONCAT(
    --     -- "class":"@5"
    --     '{"template":{"noun (pl.)":"%s1",',
    --     '"subject class":"%e1","object class":"%e2",',
    --     '"graded w.r.t.":"%s2",',
    --     '"predicate":"is an instance of the %s1 of @[Object], graded ',
    --     'with respect to %s2",',
    --     '"statement":"@[Subject] is an instance of the %s1 of @[Object], ',
    --     'graded with respect to %s2",',
    --     '"scale type":"@22"}}'
    -- ), CONCAT(
    --     "A @6 that can be used to create one-to-many @5 entities from ",
    --     "(plural) nouns, scored on the @22 according to @[Graded w.r.t.] ",
    --     "These entity lists should also be filtered ",
    --     "according to the corresponding factual version of this relation, ",
    --     "created from @27.\n",
    --     "@[Noun (pl.)] should be a plural (compound) noun."
    -- ), CONCAT(
    --     "A one-to-many @5 formed from a (plural) noun, stating that ",
    --     "@[Subject] is an instance of the @[Noun (pl.)] of @[Object], graded ",
    --     "according to @[Graded w.r.t.] on the @22.\n",
    --     "These entity lists should also be filtered ",
    --     "according to the corresponding factual version of this relation, ",
    --     "created from @27."
    -- )),
    -- (21, 12, 0, '', '', CONCAT(
    --     '{"title":"Likelihood scale"}'
    -- ), CONCAT(
    --     "A scale to score the truth/falsity of a (factual) statement, or more ",
    --     "precisely the likelihood with which the scoring users deem the ",
    --     "statement to be true. ",
    --     "This scale have a fixed interval, going from 0 % to 100 %."
    -- ), NULL),
    -- (22, 12, 0, '', '', CONCAT(
    --     '{"title":"Grading scale"}'
    -- ), CONCAT(
    --     "A scale to score how well entities fit a certain predicate. ",
    --     "This scale is intended for most instances where you need to score ",
    --     "a class of entities among themselves in relation to some quality.\n",
    --     "The entities with the highest scores should be the ones that you ",
    --     "want to see at the top of the list if you are looking for the given ",
    --     "quality specifically, and lowest-scored entities should be the ones ",
    --     "you want to see last. ",
    --     "And if you adjust a search/feed algorithm to give more weight to ",
    --     "entities with this quality, the added weight should then generally ",
    --     "be proportional to the score, i.e. the highest scored entities are ",
    --     "boosted the most.\n",
    --     "The interval of the scale is unlimited, but the default interval ",
    --     "runs from approximately 0 to 10. And it is the intention that for ",
    --     "most qualities, when the classes include enough entities, the ",
    --     "curve over the combined user scores of all the entities should ",
    --     "a bell curve, approximately. To remind the users of this, we will ",
    --     "draw a bell curve in the background of the actual curve. And the ",
    --     "bots that aggregate the user scores might even stretch or shrink ",
    --     "the scale, or add an offset to it, such that it normalizes to a ",
    --     "bell curve.\n",
    --     "We will also divide the interval into grades, from F--A (skipping ",
    --     "E), where F denotes 'among worst in terms of achieving the given ",
    --     "quality, D denotes 'among the bad at achieving ...', C denotes ",
    --     "'among the middling ...', B denotes 'among the good ...', and A ",
    --     "denotes 'among the best in terms of achieving the given quality'."
    -- ), NULL),
    -- (23, 6, 0, '', '', CONCAT(
    --     -- "class":"@3"
    --     '{"template":{"predicate":"%e1","subject":"%e2"}}'
    -- ), CONCAT(
    --     "A @6 for creating @3 entities by applying @[Predicate] to ",
    --     "@[Subject]."
    -- ), CONCAT(
    --     "A @3 formed by applying @[Predicate] to @[Subject]."
    -- )),
    -- (24, 6, 0, '', '', CONCAT(
    --     -- "class":"@13"
    --     '{"template":{"predicate":"%e1","subject":"%e2"}}'
    -- ), CONCAT(
    --     "A @6 for creating @13 entities by applying @[Predicate] to ",
    --     "@[Subject]."
    -- ), CONCAT(
    --     "A @13 formed by applying @[Predicate] to @[Subject]."
    -- )),
    -- (25, 6, 0, '', '', CONCAT(
    --     -- "class":"@4"
    --     '{"template":{"relation":"%e1","object":"%e2"}}'
    -- ), CONCAT(
    --     "A @6 for creating @4 entities by applying @[Relation] to ",
    --     "@[Object]."
    -- ), CONCAT(
    --     "A @4 formed by applying @[Relation] to @[Object]."
    -- )),
    -- (26, 6, 0, '', '', CONCAT(
    --     -- "class":"@14"
    --     '{"template":{"relation":"%e1","object":"%e2"}}'
    -- ), CONCAT(
    --     "A @6 for creating @14 entities by applying @[Relation] to ",
    --     "@[Object]."
    -- ), CONCAT(
    --     "A @14 formed by applying @[Relation] to @[Object]."
    -- )),
    -- (27, 6, 0, '', '', CONCAT(
    --     -- "class":"@5"
    --     '{"template":{"noun (pl.)":"%s",',
    --     '"subject class":"%e1","object class":"%e2",',
    --     '"predicate":"is an instance of the %s of @[Object]",',
    --     '"statement":"@[Subject] is an instance of the %s of @[Object]",',
    --     '"scale type":"@21"}}'
    -- ), CONCAT(
    --     "A @6 that can be used to create factual one-to-many @5 entities ",
    --     "from (plural) nouns, scored on the @21 in terms of whether they are ",
    --     "instances of the @[Noun (pl.)] of @[Object].\n",
    --     "@[Noun (pl.)] should be a plural (compound) noun."
    -- ), CONCAT(
    --     "A one-to-many @5 formed from a (plural) noun, stating that ",
    --     "@[Subject] is an instance of the @[Noun (pl.)] of @[Object], scored ",
    --     "on the @21."
    -- )),
    -- -- (10, 1, 0, '', '', CONCAT(
    -- --     '{"superclass":"@2","title":"property tag"}'
    -- -- ), CONCAT(
    -- --     "A class of 'property tags,' which are tags of a very specific ",
    -- --     "structure used to form semantic relations in this semantic system. ",
    -- --     "A property tag is always constructed from just a 'property' entity ",
    -- --     "(of the 'property relation' class) and another 'subject' entity ",
    -- --     "(of any class). The resulting rating scale is then how well the ",
    -- --     "given instance entity fits the given property of the subject entity. "
    -- --     "For instance, we might have a movie entity as our subject entity, ",
    -- --     "and 'director' as our property entity, and have 'John Doe' ",
    -- --     "as the instance entity, which says that John Doe is the ",
    -- --     "director of the given movie. If the property entity has no ",
    -- --     "further description, then the rating scale is just a 1–5 scale of ",
    -- --     "how well the ",
    -- --     "instance (e.g. John Doe) fits the given tag, e.g. the 'director ",
    -- --     "of the given movie.' But the property entity might also specify ",
    -- --     "this rating further in its description. (For instance, it might ", 
    -- --     "specify that the main director always ought to be given 5 stars on ",
    -- --     "the rating scale from 1 to 5, e.g.)"
    -- -- ), NULL),
    -- -- (11, 3, 0, '', '', CONCAT(
    -- --     '{"format":{',
    -- --         -- '"class":"@10",',
    -- --         '"subject":"%e1",',
    -- --         '"property":"%e2",',
    -- --     '}}'
    -- -- ), NULL),
    -- -- (12, 1, 0, '', '', CONCAT(
    -- --     '{"title":"entity"}'
    -- -- ), CONCAT(
    -- --     "A class of all entities of this Semantic Network. All entities ",
    -- --     "automatically has this class without needing to specify so in their ",
    -- --     "definition."
    -- -- ), NULL),
    -- -- (13, 4, 5, '', 'initial_user', NULL, NULL),
    -- -- (14, 1, 0, '', '', CONCAT(
    -- --     '{"title":"list"}'
    -- -- ), CONCAT(
    -- --     "A class of all (ordered) lists. The only property of ",
    -- --     "this class, other than the 'class' property itself, is an 'elements' ",
    -- --     "property that includes a list of all the elements. Note that lists ",
    -- --     "are written in property structs as e.g. '",
    -- --     '"elements":[[elem_1, elem_2, elem_3]]',
    -- --     "', whereas '[elem_1, elem_2, elem_3]' (with no nesting) is ",
    -- --     "interpreted as an unordered set of valid property values (used for ",
    -- --     "one-to-many properties)."
    -- -- ), NULL),
    -- -- (15, 3, 0, '', '', CONCAT(
    -- --     '{"format":{"elements":[["%s%t"]]}' -- "class":"@14"
    -- -- ), NULL),
    -- -- (16, 3, 0, '', '', CONCAT(
    -- --     -- "class":"@3"
    -- --     '{"format":{"class":"@2","title":"%s",',
    -- --     '"instance class":"%e1","description":"%t"}'
    -- -- ), NULL),
    -- -- (17, 8, 9, '8', 'relevant property', NULL, CONCAT(
    -- --     "A property relation where the objects are the property relations ",
    -- --     "that are relevant to the subject entity."
    -- -- ), NULL),
    -- -- (18, 8, 9, '8,1', 'relevant property of class instances', NULL, CONCAT(
    -- --     "A property relation where the objects are the property relations ",
    -- --     "that are relevant to all the instances of the subject class."
    -- -- ), NULL),
    -- -- (19, 10, 11, '12,18', '', NULL, NULL),
    -- -- (20, 10, 11, '2,18', '', NULL, NULL),
    -- -- (21, 1, 0, '', '', CONCAT(
    -- --     '{"title":"set"}'
    -- -- ), CONCAT(
    -- --     "A class of all sets (unordered lists). The only property of ",
    -- --     "this class, other than the 'class' property itself, is an 'elements' ",
    -- --     "property holding an array of all the elements of the set. ",
    -- --     "Note that sets are written in property structs as e.g. '",
    -- --     '"elements":[elem_1, elem_2, elem_3]',
    -- --     "', whereas '[[elem_1, elem_2, elem_3]]' (a nested array) is ",
    -- --     "interpreted as a (ordered) list instead. "
    -- --     "Whenever a set entity is the value of a property in a property ",
    -- --     "struct, the interpretation is that all the elements fits the given ",
    -- --     "property, not the set itself. To sey that a set entity itself is ",
    -- --     "the value of a property, simply wrap it in another set, either ",
    -- --     "using the '[]' syntax or by creating another set entity with the ",
    -- --     "given set as its only element."
    -- -- ), NULL),
    -- -- (22, 3, 0, '', '', CONCAT(
    -- --     '{"format":{"elements":["%s%t"]}' -- "class":"@21"
    -- -- ), NULL),
    -- -- 
    -- (NULL, 1, 6, '', 'exAmpLe of A noT very usefuL enTiTy', NULL, NULL, NULL);


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
