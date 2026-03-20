<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// -------------------------------
// Database credentials (get this from db_info.txt)
// -------------------------------
$DB_NAME = '';
$DB_USER = '';
$DB_PASS = '';
$DB_HOST = '';

// -------------------------------
// Connect to MySQL
// -------------------------------
$conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);

if ($conn->connect_error) {
    die("❌ Connection failed: " . $conn->connect_error);
}
echo "✅ Connected to MySQL successfully!";

// Optional: list tables
$result = $conn->query("SHOW TABLES;");
if ($result) {
    echo "<br>Tables in database:";
    while ($row = $result->fetch_array()) {
        echo "<br>- " . $row[0];
    }
}

$conn->close();
?>