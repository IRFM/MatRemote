<?php 

include "private/bridge.php";

// scp_getfile over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 

$remotehost = $_POST["remotehost"];
$remotedatapath = $_POST["remotedatapath"];
$filename = $_POST["filename"];

list($remote_host,$remote_login,$remote_password) = login($remotehost);

$ftp_rootdir = ftprootdir();
//echo $ftp_rootdir."\n";

$connection = ssh2_connect($remote_host);

if (ssh2_auth_password($connection, $remote_login, $remote_password)) {
   //echo "Successful ssh identification !"."\n";

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





