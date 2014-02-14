<?php 

include "private/functions.php";
include "private/bridge.php";


// scp_putdir over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 

$remotehost = $_POST["remotehost"];
$remotedatapath = $_POST["remotedatapath"];
$batch_dir =  $_POST["batch_dir"];
$debugmode = $_POST["debugmode"];

list($remote_host,$remote_login,$remote_password) = login($remotehost);
//echo $remote_host."\n";
//echo $remote_login."\n";
//echo $remote_password."\n";

$ftp_rootdir = ftprootdir();
//echo $ftp_rootdir."\n";

$remote_cmd = $remotecmd;

$connection = ssh2_connect($remote_host);

if (ssh2_auth_password($connection, $remote_login, $remote_password)) {
   if ($debugmode == '1') echo "Successful ssh identification !"."\n";

   $remote_cmd = "mkdir ".$remotedatapath.$batch_dir;//create batch dir on remote machine

   $stream = ssh2_exec($connection, $remote_cmd);  
   $errorStream = ssh2_fetch_stream($stream, SSH2_STREAM_STDERR);
  
   stream_set_blocking($errorStream, true);
   stream_set_blocking($stream, true);
  
   echo stream_get_contents($stream)."\n";

   echo "ssh2php_error:".stream_get_contents($errorStream)."\n";

   //echo $ftp_rootdir.$batch_dir."\n";
   $files = file_list($ftp_rootdir.$batch_dir,"");

   $i = 0;
   $error = 0;

   while ($i < sizeof($files)) {
      //echo " - File-$i : ".$files[$i]."\n";  
      //echo $ftp_rootdir.$batch_dir.$files[$i]."\n";
      //echo $remotedatapath.$batch_dir.$files[$i]."\n";
      $error_transfer[$i] = ssh2_scp_send($connection, $ftp_rootdir.$batch_dir.$files[$i], $remotedatapath.$batch_dir.$files[$i]);
      $error += 1 - $error_transfer[$i];
      $i = $i + 1;    
   }
  
   if ($error > 0) {
      echo "scp2php_error:".$error."\n";
   } else {
      echo "scp2php_error:\n";
  }
    
} else {
   die('Identification failed...');
}

?>






