<?php

$src_path = $_SERVER['DOCUMENT_ROOT'] . "/../src/";
require_once $src_path . "db_io/db_io.php";




if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // // categories.
    // db_io\insertOrFindCategory("Categories", 1, NULL);
    // // insertOrFindCategory("Standard terms", 1, NULL);
    // db_io\insertOrFindCategory("Relations", 1, NULL);
    //
    // $res = db_io\insertOrFindCategory("Users and bots", 1, NULL);
    // $catUserEtcID = $res["id"];
    //
    // db_io\insertOrFindCategory("Users", $catUserEtcID, NULL);
    // db_io\insertOrFindCategory("User groups", $catUserEtcID, NULL);
    //
    // $res = db_io\insertOrFindCategory("Internal data", 1, NULL);
    // $catDataTermsID = $res["id"];
    //
    // db_io\insertOrFindCategory("Keyword strings", $catDataTermsID, NULL);
    // db_io\insertOrFindCategory("Lists", $catDataTermsID, NULL);
    // db_io\insertOrFindCategory("Texts", $catDataTermsID, NULL);
    // db_io\insertOrFindCategory("Binaries", $catDataTermsID, NULL);
    //
    // // relations.
    // db_io\insertOrFindRelation("Subcategories", 1, NULL);
    // db_io\insertOrFindRelation("Elements", 1, NULL);


    // echo var_dump(intval("0x01")) . ",  ";
    // echo intval("0x01") . ",  ";
    // echo var_dump(intval("0xAF")) . ",  ";
    // echo "<br>";
    // // what the hell php/Apache2..???..



    // echo var_dump(db_io\getCatSafeDef("01")) . "<br>";
    // echo var_dump(db_io\getCatSafeDef("02")) . "<br>";
    // echo var_dump(db_io\getCatSafeDef("03")) . "<br>";


    echo var_dump(db_io\getCatSafeDef("0A")) . "<br>";
    echo var_dump(db_io\getCatSafeSuperCats("0A")) . "<br>";
    echo print_r(db_io\getCatSafeSuperCats("0A")) . "<br>";


    echo ctype_xdigit("00A");
    echo ctype_xdigit("");
    echo ctype_xdigit("");
    echo ctype_xdigit("");
    echo ctype_xdigit("");
    echo ctype_xdigit("");
    echo is_string("");
    echo ctype_xdigit("00A") . "<br>";

    echo var_dump(hex2bin("00")) . "hex2bin<br>";

    echo var_dump(hexdec("FF")) . "hexdec<br>";

    echo print_r(
        db_io\getSet(
            'u', "01",
            'c', "13",
            "01",
            "00", "",
            "100", "0",
            "0"
        )
    ) . "<br>";

    echo print_r(
        db_io\getSet(
            'u', "01",
            'c', "14",
            "01",
            "", "FF",
            "100", "0",
            "0"
        )
    ) . "<br>";

    echo "br<br>";

    echo print_r(
        db_io\getSet(
            'u', "01",
            'c', "14",
            "01",
            "00", "FF",
            "3", "0",
            "0"
        )
    ) . "<br>";


    echo print_r(
        db_io\getSet(
            'u', "01",
            'c', "14",
            "01",
            "00", "FF",
            "3", "0",
            "1"
        )
    ) . "<br>";


    echo print_r(
        db_io\getSet(
            'u', "01",
            'c', "08",
            "01",
            "", "",
            "3", "0",
            "1"
        )
    ) . "<br>";

    // // exit;
    // // insertOrFindRelation("I should not exist", 1, NULL);
    // if (!isset($_POST["protocol"])) {
    //    echo "Error: No protocol specified";
    //    // exit;
    // }
}

// function sanitize_input($data) {
//     $data = trim($data);
//     // $data = stripslashes($data);
//     $data = htmlspecialchars($data);
//     return $data;
// }


// $arr = array($lexItem, $description, $user_id, $new_id);
// foreach($arr as $x){
//     echo strval($x) . "<br>";
// }


?>


<!-- <form action="javascript:void(0);" onsubmit="myFunction()">
  Enter name: <input type="text" name="fname">
  <input type="submit" value="Submit">
</form>

<script>
function myFunction() {
  alert("The form was submitted");
}
</script> -->


<form
    method="post"
    action=<?php echo htmlspecialchars($_SERVER["PHP_SELF"]);?>
    autocomplete="on"
>
    <!-- <p>
        <label for="descriptionInput">User ID:</label>
        <input type="text" id="userIDInput" name="userID">
    </p>
    <p>
        <label for="lexItemInput">Lexical item:</label>
        <input type="text" id="lexItemInput" name="lexItem">
    </p>
    <p>
        <label for="descriptionInput">Description:</label>
        <input type="text" id="descriptionInput" name="description">
    </p> -->
    <input type="submit" name="submit" value="Insert initial terms">
</form>
