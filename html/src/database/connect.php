<?php

function get_connection() {
    $servername = "localhost";
    $username = "mads";
    $password = "lemmein";
    $database = "mydatabase";

    // // echo $servername . $username . $password . $database;
    // try {
    //     $conn = new PDO("mysql:host=$servername;dbname=$database", $username, $password);
    //     // set the PDO error mode to exception
    //     $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    //     echo "Connected successfully";
    // } catch(PDOException $e) {
    //     echo "Connection failed: " . $e->getMessage();
    // }

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
      die("Connection failed: " . $conn->connect_error);
    }
    // echo "Connected successfully";

    return $conn;
}

?>