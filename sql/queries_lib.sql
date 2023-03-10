

DROP PROCEDURE selectSet;
DROP PROCEDURE selectData;
DROP PROCEDURE selectCreations;




DELIMITER //
CREATE PROCEDURE selectSet (
    IN userType CHAR(1),
    IN userID BIGINT UNSIGNED,
    IN subjType CHAR(1),
    IN subjID BIGINT UNSIGNED,
    IN relID BIGINT UNSIGNED,
    IN ratingRangeMin VARBINARY(255),
    IN ratingRangeMax VARBINARY(255),
    IN num INT UNSIGNED,
    IN numOffset INT UNSIGNED,
    IN isAscOrder BOOL
)
BEGIN
    SELECT set_id INTO @setID
    FROM Sets
    WHERE (
        user_t = userType AND
        user_id = userID AND
        subj_t = subjType AND
        subj_id = subjID AND
        rel_id = relID
    );
    IF (isAscOrder) THEN
        SELECT (rat_val AS ratingVal, obj_t AS objType, obj_id AS objID)
        FROM SemanticInputs
        WHERE (
            set_id = @setID AND
            rat_val BETWEEN ratingRangeMin AND ratingRangeMax
        )
        ORDER BY rat_val, obj_t, obj_id ASC
        LIMIT numOffset, num;
    ELSE
        SELECT (rat_val AS ratingVal, obj_t AS objType, obj_id AS objID)
        FROM SemanticInputs
        WHERE (
            set_id = @setID AND
            rat_val BETWEEN ratingRangeMin AND ratingRangeMax
        )
        ORDER BY rat_val, obj_t, obj_id DESC
        LIMIT numOffset, num;
    END IF;
END //
DELIMITER ;







DELIMITER //
CREATE PROCEDURE selectCatTitle (
    IN catID BIGINT UNSIGNED
)
BEGIN
    SELECT (title AS catTitle) FROM Categories WHERE id = catID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE selectCatSuperCat (
    IN catID BIGINT UNSIGNED
)
BEGIN
    SELECT (super_cat_id AS superCatID) FROM Categories WHERE id = catID;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE selectCatAllSuperCats (
    IN catID BIGINT UNSIGNED
)
BEGIN
    SELECT (super_cat_id AS superCatID) FROM Categories WHERE id = catID;
END //
DELIMITER ;




DELIMITER //
CREATE PROCEDURE selectRelObjNoun (
    IN relID BIGINT UNSIGNED
)
BEGIN
    SELECT (obj_noun AS objNoun) FROM Relations WHERE id = relID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE selectRelSubjCat (
    IN relID BIGINT UNSIGNED
)
BEGIN
    SELECT (subj_cat_id AS subjCatID) FROM Relations WHERE id = relID;
END //
DELIMITER ;








DELIMITER //
CREATE PROCEDURE selectData (
    IN dataType CHAR(1),
    IN dataID BIGINT UNSIGNED
)
BEGIN
    CASE dataType
        WHEN "t" THEN
            SELECT str AS data FROM Texts WHERE (id = dataID);
        -- TODO: Implement more data term types.
        ELSE
            SELECT NULL;
    END CASE;
END //
DELIMITER ;








DELIMITER //
CREATE PROCEDURE selectCreations (
    IN userID BIGINT UNSIGNED,
    IN termType CHAR(1),
    IN num INT UNSIGNED,
    IN numOffset INT UNSIGNED,
    IN isAscOrder BOOL
)
BEGIN
    IF (isAscOrder) THEN
        SELECT term_id
        FROM Creators
        WHERE (user_id = userID AND term_t = termType)
        ORDER BY term_id ASC
        LIMIT numOffset, num;
    ELSE
        SELECT term_id
        FROM Creators
        WHERE (user_id = userID AND term_t = termType)
        ORDER BY term_id DESC
        LIMIT numOffset, num;
    END IF;
END //
DELIMITER ;