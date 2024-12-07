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

if (empty($_POST)) {
    $_POST = json_decode(file_get_contents('php://input'), true);
}

/* Verification of the session ID  */

// Get the userID and the session ID.
$paramNameArr = array("u", "ses");
$typeArr = array("id", "session_id_hex");
$paramValArr = InputGetter::getParams($paramNameArr);
InputValidator::validateParams($paramValArr, $typeArr, $paramNameArr);
$userID = $paramValArr[0];
$sesIDHex = $paramValArr[1];

// Get connection to the database.
require $db_io_path . "sdb_config.php";
$conn = DBConnector::getConnectionOrDie(
    DB_SERVER_NAME, DB_DATABASE_NAME, DB_USERNAME, DB_PASSWORD
);

// // Authenticate the user by verifying the session ID.
// $sesID = hex2bin($sesIDHex);
// $res = Authenticator::verifySessionID($conn, $userID, $sesID);
// TODO: Comment in again.


// TODO: Consider implementing default values for the InputGetter, defined
// either as part of $paramNameArr, or perhaps via a third array. ..Ah, we
// could just pass dyadic name--value arrays instead of the name strings
// in the case when there's a default value. (But this is not an urgent thing.) 


/* Handling of the input request */

// Get request type.
if (!isset($_POST["req"])) {
    echoBadErrorJSONAndExit("No request type specified");
}
$reqType = $_POST["req"];


// Match $reqType against any of the following single-query request types
// and execute the corresponding query if a match is found.
$sql = "";
$paramNameArr = "";
$typeArr = "";
switch ($reqType) {
    case "opScore":
        $sql = "CALL insertOrUpdateOpinionScore (?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "q", "s", "v", "w");
        $typeArr = array("id", "id", "id", "float", "float");
        break;
    case "delOpScore":
        $sql = "CALL deleteOpinionScore (?, ?, ?)";
        $paramNameArr = array("u", "s", "e");
        $typeArr = array("id", "id", "id");
        break;
    case "prvScore":
        $sql = "CALL insertOrUpdatePrivateScore (?, ?, ?, ?)";
        $paramNameArr = array("u", "q", "s", "v");
        $typeArr = array("id", "id", "id", "float");
        break;
    case "delPrvScore":
        $sql = "CALL deletePrivateScore (?, ?, ?)";
        $paramNameArr = array("u", "s", "e");
        $typeArr = array("id", "id", "id");
        break;
    case "funEnt":
        $sql = "CALL insertOrFindFunctionEntity (?, ?, ?, ?)";
        $paramNameArr = array("u", "def", "a", "days");
        $typeArr = array("id", "fun_def", "bool", "int");
        break;
    case "editFunEnt":
        $sql = "CALL editOrFindFunctionEntity (?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "e", "def", "a", "days");
        $typeArr = array("id", "id", "fun_def", "bool", "int");
        break;
    case "callEnt":
        $sql = "CALL insertOrFindFunctionCallEntity (?, ?, ?, ?)";
        $paramNameArr = array("u", "def", "a", "days");
        $typeArr = array("id", "fun_call", "bool", "int");
        break;
    case "editCallEnt":
        $sql = "CALL editOrFindFunctionCallEntity (?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "e", "def", "a", "days");
        $typeArr = array("id", "id", "fun_call", "bool", "int");
        break;
    case "attrEnt":
        $sql = "CALL insertOrFindAttributeDefinedEntity (?, ?, ?, ?)";
        $paramNameArr = array("u", "def", "a", "days");
        $typeArr = array("id", "json_str", "bool", "int");
        break;
    case "editAttrEnt":
        $sql = "CALL editOrFindAttributeDefinedEntity (?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "e", "def", "a", "days");
        $typeArr = array("id", "id", "json_str", "bool", "int");
        break;
    case "utf8Ent":
        $sql = "CALL insertUTF8Entity (?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "def", "prv", "a", "days");
        $typeArr = array("id", "text", "bool", "bool", "int");
        break;
    case "editUTF8Ent":
        $sql = "CALL editUTF8Entity (?, ?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "e", "def", "prv", "a", "days");
        $typeArr = array("id", "id", "text", "bool", "bool", "int");
        break;
    case "htmlEnt":
        $sql = "CALL insertHTMLEntity (?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "def", "prv", "a", "days");
        $typeArr = array("id", "text", "bool", "bool", "int");
        break;
    case "editHTMLEnt":
        $sql = "CALL editHTMLEntity (?, ?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "e", "def", "prv", "a", "days");
        $typeArr = array("id", "id", "text", "bool", "bool", "int");
        break;
    case "jsonEnt":
        $sql = "CALL insertJSONEntity (?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "def", "prv", "a", "days");
        $typeArr = array("id", "json_text", "bool", "bool", "int");
        break;
    case "editJSONEnt":
        $sql = "CALL editJSONEntity (?, ?, ?, ?, ?, ?)";
        $paramNameArr = array("u", "e", "def", "prv", "a", "days");
        $typeArr = array("id", "id", "json_text", "bool", "bool", "int");
        break;
    case "anonymizeEnt":
        $sql = "CALL anonymizeEntity (?, ?)";
        $paramNameArr = array("u", "e");
        $typeArr = array("id", "id");
        break;
    default:
        echoBadErrorJSONAndExit("Unrecognized request type");
}

// Get inputs.
$paramValArr = InputGetter::getParams($paramNameArr);
// Validate inputs.
InputValidator::validateParams($paramValArr, $typeArr, $paramNameArr);
// Prepare input MySQLi statement.
$stmt = $conn->prepare($sql);
// Execute statement.
DBConnector::executeSuccessfulOrDie($stmt, $paramValArr);
// Fetch the result as an associative array.
$res = $stmt->get_result()->fetch_assoc();
// Finally echo the JSON-encoded result array (containing outID and exitCode).
header("Content-Type: text/json");
if ($res["exitCode"] == "0") {
    http_response_code(201);
}
// if ($res["exitCode"] == "10") {
//     http_response_code(500);
//     $res = "Deadlock encountered in the database";
// }

echo json_encode($res);

// The program exits here, which also closes $conn.
?>