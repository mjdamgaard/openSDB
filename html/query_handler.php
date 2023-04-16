<?php

$err_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/err/";
require_once $err_path . "errors.php";

$user_input_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/user_input/";
require_once $user_input_path . "InputGetter.php";
require_once $user_input_path . "InputVerifier.php";

$db_io_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/db_io/";
require_once $db_io_path . "DBConnector.php";



// queries can also be GET-gotten.
if ($_SERVER["REQUEST_METHOD"] != "POST") {
    $_POST = $_GET;
}


// get request type.
if (!isset($_POST["type"])) {
    echoErrorJSONAndExit("No request type specified");
}
$reqType = $_POST["type"];


// match $reqType against any of the following single-query request types
// and execute the corresponding query if a match is found.
$sql = "";
$paramNameArr = "";
$typeArr = "";
switch ($reqType) {
    case "S":
        $sql = "CALL selectSet (?, ?, ?, ?, ?, ?)";
        $paramNameArr = array(
            "id",
            "rl", "rh",
            "n", "o",
            "a"
        );
        $typeArr = array(
            "setID",
            "bin", "bin",
            "uint", "uint",
            "tint"
        );
        // columns: ("ratVal", "objID"),
        break;
    case "SI":
        $sql = "CALL selectSetInfo (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "setID"
        );
        // columns: ("userID", "subjID", "relID", "elemNum"),
        break;
    case "SISK":
        $sql = "CALL selectSetInfoFromSecKey (?, ?, ?)";
        $paramNameArr = array("uid", "sid", "rid");
        $typeArr = array(
            "userOrGroupID", "termID", "relID"
        );
        // columns: ("setID", "elemNum"),
        break;
    case "R":
        $sql = "CALL selectRating (?, ?)";
        $paramNameArr = array("oid", "sid");
        $typeArr = array(
            "termID", "setID"
        );
        // columns: ("ratVal"),
        break;
    case "CD":
        $sql = "CALL selectCatDef (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "catID"
        );
        // columns: ("catTitle", "superCatID"),
        break;
    case "ED":
        $sql = "CALL selectETermDef (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "eTermID"
        );
        // columns: ("eTermTitle", "catID"),
        break;
    case "RD":
        $sql = "CALL selectRelDef (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "relID"
        );
        // columns: ("objNoun", "subjCatID"),
        break;
    case "SCD":
        $sql = "CALL selectSuperCatDefs (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "catID"
        );
        // columns: ("catTitle", "superCatID"),
        break;
    case "T":
        $sql = "CALL selectText (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "textID"
        );
        // columns: ("text"),
        break;
    case "B":
        $sql = "CALL selectBinary (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "binID"
        );
        // columns: ("binary"),
        break;
    case "K":
        $sql = "CALL selectKeywordString (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "kwsID"
        );
        // columns: ("keywordString"),
        break;
    case "P":
        $sql = "CALL selectPattern (?)";
        $paramNameArr = array("id");
        $typeArr = array(
            "pattID"
        );
        // columns: ("pattern"),
        break;
    default:
        header("Content-Type: text/json");
        echoErrorJSONAndExit("Unrecognized request type");
}

// get inputs.
$paramValArr = InputGetter::getParams($paramNameArr);
// verify inputs.
InputVerifier::verifyTypes($paramValArr, $typeArr, $paramNameArr);
// get connection.
$conn = DBConnector::getConnectionOrDie();
// prepare input MySQLi statement.
$stmt = $conn->prepare($sql);
// execute query statement.
DBConnector::executeSuccessfulOrDie($stmt, $paramValArr);
// fetch the result as a numeric array.
$res = $stmt->get_result()->fetch_all();
// set the Content-Type header to json.
header("Content-Type: text/json");
// finally echo the JSON-encoded numeric array, containing e.g. the
// columns: ("ratVal", "objID") for $reqType == "S", etc., so look at
// the comments above for what the resulting arrays will contain.
echo json_encode($res);

// The program exits here, which also closes $conn.

?>
