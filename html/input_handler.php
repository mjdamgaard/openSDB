<?php

header("Access-Control-Allow-Origin: http://localhost:3000");
header("Cache-Control: max-age=3");

$err_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/php/err/";
require_once $err_path . "errors.php";

$user_input_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/php/user_input/";
require_once $user_input_path . "InputGetter.php";
require_once $user_input_path . "InputValidator.php";

$db_io_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/php/db_io/";
require_once $db_io_path . "DBConnector.php";

$auth_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/php/auth/";
require_once $auth_path . "Authenticator.php";


if ($_SERVER["REQUEST_METHOD"] != "POST") {
    echoBadErrorJSONAndExit("Only the POST HTTP method is allowed for inputs");
}


/* Verification of the session ID  */

// get the userID and the session ID.
$paramNameArr = array("u", "ses");
$typeArr = array("id", "session_id_hex");
$paramValArr = InputGetter::getParams($paramNameArr);
InputValidator::validateParams($paramValArr, $typeArr, $paramNameArr);
$userID = $paramValArr[0];
$sesIDHex = $paramValArr[1];

// get connection to the database.
require $db_io_path . "sdb_config.php";
$conn = DBConnector::getConnectionOrDie(
    DB_SERVER_NAME, DB_DATABASE_NAME, DB_USERNAME, DB_PASSWORD
);

// authenticate the user by verifying the session ID.
$sesID = hex2bin($sesIDHex);
$res = Authenticator::verifySessionID($conn, $userID, $sesID);




/* Handling of the input request */

// get request type.
if (!isset($_POST["req"])) {
    echoBadErrorJSONAndExit("No request type specified");
}
$reqType = $_POST["req"];


// match $reqType against any of the following single-query request types
// and execute the corresponding query if a match is found.
$sql = "";
$paramNameArr = "";
$typeArr = "";
switch ($reqType) {
    case "rat":
        $sql = "CALL insertOrUpdateRating (?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "t", "i", "r", "l");
        $typeArr = array("id", "id", "id", "rat", "unix_time");
        break;
    case "def":
        $sql = "CALL insertOrFindDefEntity (?, ?, ?, ?)";
        $paramNameArr = array("u", "r", "t", "d");
        $typeArr = array("id", "tint", "str", "id");
        break;
    case "sim":
        $sql = "CALL insertOrFindSimEntity (?, ?, ?)";
        $paramNameArr = array("u", "r", "t");
        $typeArr = array("id", "tint", "str");
        break;
    case "fun":
        $sql = "CALL insertOrFindFunEntity (?, ?, ?, ?)";
        $paramNameArr = array("u", "r", "f", "i");
        $typeArr = array("id", "tint", "id", "str");
        break;
    case "propTag":
        $sql = "CALL insertOrFindPropTagEntity (?, ?, ?, ?)";
        $paramNameArr = array("u", "r", "s", "p");
        $typeArr = array("id", "tint", "id", "id");
        break;
    case "text":
        $sql = "CALL insertOrFindSimEntity (?, ?, ?)";
        $paramNameArr = array("u", "r", "t");
        $typeArr = array("id", "tint", "text");
        break;
    case "bin":
        // $sql = "CALL insertBinary (?, ?, ?)";
        // $paramNameArr = array("u", "n", "b");
        // $typeArr = array("id", "str", "blob");
        echoErrorJSONAndExit('The "bin" request type is not implemented yet');
        break;
    default:
        echoBadErrorJSONAndExit("Unrecognized request type");
}

// get inputs.
$paramValArr = InputGetter::getParams($paramNameArr);
// validate inputs.
InputValidator::validateParams($paramValArr, $typeArr, $paramNameArr);
// prepare input MySQLi statement.
$stmt = $conn->prepare($sql);
// execute statement.
DBConnector::executeSuccessfulOrDie($stmt, $paramValArr);
// fetch the result as an associative array.
$res = $stmt->get_result()->fetch_assoc();
// finally echo the JSON-encoded result array (containing outID and exitCode).
header("Content-Type: text/json");
echo json_encode($res);

// The program exits here, which also closes $conn.
?>
