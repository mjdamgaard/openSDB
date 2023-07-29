
SELECT "Bots: Mean bots";

-- DROP PROCEDURE updateMeanBots;
--
-- DROP PROCEDURE updateMeanWithOffset3Bot;

DELIMITER //
CREATE PROCEDURE updateMeanBots (
    IN userID BIGINT UNSIGNED,
    IN catID BIGINT UNSIGNED,
    IN instID BIGINT UNSIGNED,
    IN ratVal SMALLINT UNSIGNED,
    IN prevRatVal SMALLINT UNSIGNED,
    IN stmtID BIGINT UNSIGNED
)
BEGIN
    CALL updateMeanWithOffset3Bot (
        userID, catID, instID, ratVal, prevRatVal, stmtID
    );
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE updateMeanWithOffset3Bot (
    IN userID BIGINT UNSIGNED,
    IN catID BIGINT UNSIGNED,
    IN instID BIGINT UNSIGNED,
    IN ratVal SMALLINT UNSIGNED,
    IN prevRatVal SMALLINT UNSIGNED,
    IN stmtID BIGINT UNSIGNED
)
BEGIN proc: BEGIN
    DECLARE prevMeanHP, newMeanHP, ratValHP, prevRatValHP BIGINT UNSIGNED;
    DECLARE userNum BIGINT UNSIGNED;
    DECLARE newMean SMALLINT UNSIGNED;

    -- get previous high-precision mean and the number of users for the
    -- statement.
    SELECT data_1, data_2 INTO prevMeanHP, userNum
    FROM BotData
    WHERE (
        def_id = 83 AND
        obj_id = stmtID
    )
    FOR UPDATE;
    -- if this is the first input for the statement, initialize a neutral mean
    -- with an offset of what amounts to 3 neutral ratings.
    IF (prevMeanHP IS NULL) THEN
        SET prevMeanHP =  9223372036854775807;
        SET userNum = 3;
        INSERT INTO BotData (def_id, obj_id, data_1, data_2)
        VALUES (83, stmtID, prevMeanHP, userNum);
        SELECT data_1, data_2 INTO prevMeanHP, userNum
        FROM BotData
        WHERE (
            def_id = 83 AND
            obj_id = stmtID
        )
        FOR UPDATE;
    END IF;
    -- compute the high-precision rating values.
    SET ratValHP = ratVal << (6 * 8);
    SET prevRatValHP = prevRatVal << (6 * 8);
    -- compute the high-precision new mean.
    SET newMeanHP = prevMeanHP DIV (userNum + 1) * userNum +
        ratValHP DIV (userNum + 1);
    -- compute the normal-precision new mean.
    SET newMean = newMeanHP >> (6 * 8);

    -- update the bot's input set.
    REPLACE INTO SemanticInputs (
        user_id,
        cat_id,
        rat_val,
        inst_id
    )
    VALUES (
        83,
        catID,
        newMean,
        instID
    );
    -- update the bot's data for the statement.
    REPLACE INTO BotData (def_id, obj_id, data_1, data_2)
    VALUES (83, stmtID, newMeanHP, userNum + 1);

END proc; END //
DELIMITER ;
