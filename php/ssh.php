<?php 

include "private/functions.php";
include "private/bridge.php";

/*
 /////////////////////////////////////////

 Software name : MatRemote, part of LUKE

 Authors : Yves Savoye-Peysson and Joan Decker

 Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France

 CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html

 The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.

 /////////////////////////////////////////
// ssh over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 

*/

$remotehost = $_POST['remotehost'];
$remotecmd = $_POST['remotecmd'];
$remoteuser = $_POST['remoteuser'];

list($remote_host,$remote_login,$remote_password) = login($remotehost,$remoteuser);

$safemode = safemode($remotehost);
//$safemode = 0;//disable safe mode

if ($safemode >= 1) {

  list($flag_filter,$txt_filter) = filter_cmd($_POST);

  if ($flag_filter == 1){
    $flag = sendmail($remotehost,$txt_filter,$remoteuser);
    //***************** UNCOMMENT the following lines to disable the filtering and check the strings (see also functions.php *************************
    //echo "flag_filter,txt_filter = ".$flag_filter.",".$txt_filter."\n";
    //************************************************************************************************************************************************
    die("*************************************************\nNon standard unix command in MatRemote:\n".$remotecmd."\nAn automatic message has been  send to the administrator.\nJob aborted...\n*************************************************");
  }
}

$remote_cmd = $remotecmd;

/*
echo "cmd=".$remote_cmd."\n";
echo "host=".$remote_host."\n";
echo "passwd=".$remote_password."\n";
echo "login=".$remote_login."\n";
*/

$connection = ssh2_connect($remote_host);

if (ssh2_auth_password($connection, $remote_login, $remote_password)) {
   //echo "Successful ssh identification !"."\n";
  
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
