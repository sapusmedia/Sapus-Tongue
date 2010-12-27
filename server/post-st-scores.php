<?php

if (!isset($g_link)) {
    $g_link = false;
}

function GetMyConnection()
{
    global $g_link;
    if( $g_link )
        return $g_link;
    $g_link = mysql_connect( 'localhost', 'sapusadmin', 'ABRAlaVACAlocaEN1950') or die('Could not connect to mysql server.' );
    mysql_select_db('sapusmediaricardo', $g_link) or die('Could not select database.');
    return $g_link;
}

function CleanUpDB()
{
    global $g_link;
    if( $g_link != false )
        mysql_close($g_link);
    $g_link = false;
}

$username = $_POST["username"];
$score = $_POST["score"];
$type = $_POST["playertype"];
$angle = $_POST["angle"];
$speed = $_POST["speed"];
$hash = $_POST["hash"];
$ip = $_SERVER['REMOTE_ADDR'];

GetMyConnection();

$query = sprintf("INSERT INTO sapustongue (address, timestamp, username, score, playertype, angle, speed) VALUES('%s', NOW(), '%s', '%s', '%s', '%s', '%s')",
    $ip,
    mysql_real_escape_string($username),
    mysql_real_escape_string($score),
    mysql_real_escape_string($type),
    mysql_real_escape_string($angle),
    mysql_real_escape_string($speed) );

$result = mysql_query( $query);

// Check result
// This shows the actual query sent to MySQL, and the error. Useful for debugging.
if (!$result) {
    $message  = 'Invalid query: ' . mysql_error() . "\n";
    $message .= 'Whole query: ' . $query;
    die($message);
}

CleanUpDB();
?>
