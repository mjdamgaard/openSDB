


DELIMITER //
CREATE PROCEDURE createOrUpdateSession (
    IN userID BIGINT UNSIGNED,
    IN sessionID VARBINARY(2000),
    IN expirationDate DATETIME
)
BEGIN
    INSERT INTO Private_Sessions (user_id, session_id, expiration_date)
    VALUES (userID, sessionID, expirationDate)
    ON DUPLICATE KEY UPDATE
        session_id = sessionID,
        expiration_date = expirationDate;
    SELECT 0 AS exitCode;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE createNewUser (
    IN username VARCHAR(50),
    IN eMailAddress VARCHAR(50),
    IN pwHash VARBINARY(2000)
)
BEGIN proc: BEGIN
    DECLARE outID BIGINT UNSIGNED;
    DECLARE exitCode TINYINT;
    DECLARE accountNum TINYINT UNSIGNED;

    SELECT number_of_accounts INTO accountNum
    FROM Private_EMails
    WHERE e_mail_address = eMailAddress
    FOR UPDATE;
    IF (accountNum IS NULL OR accountNum >= 2) THEN -- TODO: Change 2 to a
    -- higher number.
        SET exitCode = 1; -- e-mail address cannot get more accounts currently.
        SELECT outID, exitCode;
        LEAVE proc;
    END IF;

    INSERT INTO Private_EMails (e_mail_address, number_of_accounts)
    VALUES (eMailAddress, 1)
    ON DUPLICATE KEY UPDATE number_of_accounts = number_of_accounts + 1;

    INSERT INTO Entities (type_id, cxt_id, def_str)
    VALUES (5, NULL, username);
    SELECT LAST_INSERT_ID() INTO outID;
    INSERT INTO Users (id, username)
    VALUES (outID, username);
    INSERT INTO Private_PasswordHashes (user_id, pw_hash)
    VALUES (outID, pwHash);

    SET exitCode = 0; -- insert.
    SELECT outID, exitCode;
END proc; END //
DELIMITER ;
