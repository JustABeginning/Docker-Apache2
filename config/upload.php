<?php
define("INPUT_FILE", "file");
define("INPUT_SUBMIT", "submit");
#
define("TARGET_DIR", "./files/");
define('DISALLOWED_FILETYPES', ['php' => true, 'html' => true]);
#
define('SERVER_RESPONSE', "status");

$result = [SERVER_RESPONSE => 0];

$condition = isset($_POST[INPUT_SUBMIT]) && isset($_FILES[INPUT_FILE]) && is_uploaded_file($_FILES[INPUT_FILE]['tmp_name']);

if ($condition) {
    $target_file = TARGET_DIR . basename($_FILES[INPUT_FILE]["name"]);
    $targetFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

    if (!isset(DISALLOWED_FILETYPES[$targetFileType])) {
        if (move_uploaded_file($_FILES[INPUT_FILE]["tmp_name"], $target_file)) {
            $result = [SERVER_RESPONSE => 1];
        }
    }
}

header('Content-Type: application/json; charset=utf-8');
#
echo json_encode($result);
