<?php
define('LOAD_HTML', "/app/static/form.html");
#
define('ALLOWED_REMOTES', ['127.0.0.1' => true, 'localhost' => true]);

function error_reponse()
{
    $result = ['status' => 0];
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($result);
}

$condition = isset(ALLOWED_REMOTES[$_SERVER['HTTP_HOST']]);

if ($condition) {
    if (is_readable(LOAD_HTML)) {
        require LOAD_HTML;
    } else {
        error_reponse();
    }
} else {
    error_reponse();
}
