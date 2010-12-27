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

function escapeString($post)
{
    if (phpversion() >= '4.3.0') {
        return array_map('mysql_real_escape_string',$post);
    } else {
        return array_map('mysql_escape_string',$post);		
    }
}

GetMyConnection();

$query = "SELECT * FROM sapustongue ORDER BY score DESC LIMIT 0,50";
$result = mysql_query( $query );

// Check result
// This shows the actual query sent to MySQL, and the error. Useful for debugging.
if (!$result) {
    $message  = 'Invalid query: ' . mysql_error() . "\n";
    $message .= 'Whole query: ' . $query;
    die($message);
}

// Use result
// Attempting to print $result won't allow access to information in the resource
// One of the mysql result functions must be used
// See also mysql_result(), mysql_fetch_array(), mysql_fetch_row(), etc.
while ($row = mysql_fetch_assoc($result)) {
    echo $row['username'];
    print ' : ';
    echo $row['score'];
    print ' : ';
    echo $row['playertype'];
    print '<p>';
}

// Free the resources associated with the result set
// This is done automatically at the end of the script
mysql_free_result($result);

CleanUpDB();
?>
