<?php 

include "private/bridge.php";

// ssh over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 

$remotehost = $_POST["remotehost"];
$remotecmd = $_POST["remotecmd"];
$debugmode = $_POST["debugmode"];

if ($debugmode == '1') {
  echo '-----------------------------------'."\n";
  echo "remotehost:".$remotehost."\n";
  echo "remotecmd:".$remotecmd."\n";
  echo "debugmode:".$debugmode."\n";
  echo '-----------------------------------'."\n";
}

list($remote_host,$remote_login,$remote_password) = login($remotehost);
//echo $remote_host."\n";
//echo $remote_login."\n";
//echo $remote_password."\n";

$remote_cmd = $remotecmd;

$connection = ssh2_connect($remote_host);

if (ssh2_auth_password($connection, $remote_login, $remote_password)) {
   if ($debugmode == '1') echo "Successful ssh identification !"."\n";
  
   $stream = ssh2_exec($connection, $remote_cmd);  
   $errorStream = ssh2_fetch_stream($stream, SSH2_STREAM_STDERR);
  
   stream_set_blocking($errorStream, true);
   stream_set_blocking($stream, true);
  
   echo stream_get_contents($stream)."\n";

   echo "ssh2php_error:".stream_get_contents($errorStream)."\n";
    
   fclose($errorStream);
   fclose($stream);
} else {
   die('Identification failed...');
}

?>







