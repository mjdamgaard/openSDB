<?php


$err_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/php/err/";
require_once $err_path . "errors.php";


$db_io_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/php/db_io/";
require_once $db_io_path . "DBConnector.php";
require_once $db_io_path . "sdb_config.php";



class EntityInserter {

    public $creationIDStore = array();

    public function getPublicCreations($userID) {
        // Get connection to the database and prepare the MySQLi statement.
        $conn = DBConnector::getConnectionOrDie(
            DB_SERVER_NAME, DB_DATABASE_NAME, DB_USERNAME, DB_PASSWORD
        );
        $sql = "CALL selectCreations (?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);

        // Then fetch the creations
        $paramValArr = array($userID, 100000, 0, 1);
        DBConnector::executeSuccessfulOrDie($stmt, $paramValArr);
        $creations = $stmt->get_result()->fetch_all();
        $conn->close();

        // Construct the creationIDStore as a [ident => entID] array from the
        // creations [[ident, entID]] array.
        $this->creationIDStore = array();
        foreach ($creations AS $val) {
            $this->creationIDStore[$val[0]] = strval($val[1]);
        }

        // Then go through each one again and replace any relative keys..
    }


    public function insertPublicEntities(
        $userID, $firstNewCrID, $newCreations
    ) {
        $explodePattern = "/([^@]|@@)+|@\\w+|@\\([^\\(\\)]*\\)|./";
        $crRefPattern = "/^@\\([^\\(\\)]*\\)$/";

        // We repeat the following process two times to make sure that that all
        // creation references that can be replaced by an outID from the first
        // iteration will be so in the second iteration.
        for ($i = 0; $i < 2; $i++) {
            // Insert all entities one at a time, and store each one's outID.
            // If a defStr contains a creation reference, substitute it first
            // if there the given creation already exists.
            foreach ($newCreations as $ident => $def) {
                $defStr = json_encode($def);

                // First explode the deStr into an array of strings that either
                // are or are not creation references.
                preg_match_all(
                    $explodePattern, $defStr, $matches, PREG_SET_ORDER
                );
                $explodedDefStr = array_map(
                    function($val) {return $val[0];},
                    $matches
                );

                // Then substitute any creation reference if possible.
                foreach ($explodedDefStr as $matchInd => $match) {
                    if (preg_match($crRefPattern, $match)) {
                        $refIdent = intval(substr($match, 3));
                        if (
                            array_key_exists($refIdent, $this->creationIDStore)
                        ) {
                            $creationID = $this->creationIDStore[$refIdent];
                            $explodedDefStr[$matchInd] = "@" . $creationID;
                        }
                    }
                }

                // Then implode back the exploded defStr with the substitutions.
                $subbedDefStr = implode($explodedDefStr);

                // Get connection to the database.
                $conn = DBConnector::getConnectionOrDie(
                    DB_SERVER_NAME, DB_DATABASE_NAME, DB_USERNAME, DB_PASSWORD
                );

                // If indent already exists in $this->creationIDStore, edit the
                // entity.
                if (array_key_exists($ident, $this->creationIDStore)) {
                    // Prepare the MySQLi statement.
                    $sql = "CALL editEntity (?, ?, ?)";
                    $stmt = $conn->prepare($sql);
                    $entID = $this->creationIDStore[$ident];
                    $paramValArr = array($userID, $entID, $subbedDefStr);
                    // Execute the statement
                    DBConnector::executeSuccessfulOrDie($stmt, $paramValArr);
                }
                // Else insert the new entity and store the outID in $this->
                // creationIDStore
                else {
                    // Prepare the MySQLi statement.
                    $sql = "CALL insertOrFindEntity (?, ?, ?, ?)";
                    $stmt = $conn->prepare($sql);
                    $paramValArr = array($userID, $subbedDefStr, 1, $ident);
                    // Execute the statement
                    DBConnector::executeSuccessfulOrDie($stmt, $paramValArr);
                    $res = $stmt->get_result()->fetch_assoc();
                    // Store the new outID.
                    $outID = strval($res["outID"]);
                    $this->creationIDStore[$ident] = $outID;
                }

                $conn->close();

                print_r("explodedDefStr: </br>");
                print_r(htmlspecialchars(json_encode($explodedDefStr)));
                print_r("</br>");
                print_r("subbedDefStr: </br>");
                print_r(htmlspecialchars(json_encode($subbedDefStr)));
                print_r("</br>");
                print_r("creationIDStore: </br>");
                print_r(htmlspecialchars(json_encode($this->creationIDStore)));
                print_r("</br>");
            }
        }
    }


}

?>
