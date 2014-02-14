<?php 

include "private/bridge.php";


// scp_getfile over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 

$remotehost = $_POST["remotehost"];
$remotedatapath = $_POST["remotedatapath"];
$filename = $_POST["filename"];
$debugmode = $_POST["debugmode"];

if ($debugmode == '1') {
  echo '-----------------------------------'."\n";
  echo "remotehost:".$remotehost."\n";
  echo "remotedatapath:".$remotedatapath."\n";
  echo "filename:".$filename."\n";
  echo "debugmode:".$debugmode."\n";
  echo '-----------------------------------'."\n";
}

list($remote_host,$remote_login,$remote_password) = login($remotehost);
//echo $remote_host."\n";
//echo $remote_login."\n";
//echo $remote_password."\n";

$ftp_rootdir = ftprootdir();
//echo $ftp_rootdir."\n";

$connection = ssh2_connect($remote_host);

if (ssh2_auth_password($connection, $remote_login, $remote_password)) {
   if ($debugmode == '1') echo "Successful ssh identification !"."\n";

   echo $remotedatapath.$filename."\n";
   echo $ftp_rootdir.$filename."\n";

   $error = ssh2_scp_recv($connection, $remotedatapath.$filename,$ftp_rootdir.$filename);

   if ($error > 0) {
      echo "scp2php_error:".$error."\n";
   } else {
      echo "scp2php_error:".$error."\n";
  }
    
} else {
   die('Identification failed...');
}

?>





