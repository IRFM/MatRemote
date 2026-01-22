<?php 

include "private/bridge.php";

/*
 /////////////////////////////////////////

 Software name : MatRemote, part of LUKE

 Authors : Yves Savoye-Peysson and Joan Decker

 Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France

 CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html

 The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.

 /////////////////////////////////////////


// scp_getfile over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 
*/

$remotehost = $_POST["remotehost"];
$remotedatapath = $_POST["remotedatapath"];
$filename = $_POST["filename"];
$remoteuser = $_POST['remoteuser'];

list($remote_host,$remote_login,$remote_password) = login($remotehost,$remoteuser);

$connection = ssh2_connect($remote_host);



if (ssh2_auth_password($connection, $remote_login, $remote_password)) {
   echo "Successful ssh identification !"."\n";

   $ftp_rootdir = ftprootdir();
   echo "ftp_rootdir = ".$ftp_rootdir."\n";

   echo "filename = ".$filename."\n";
   echo "remotedatapath = ".$remotedatapath.$filename."\n";
  

   if (strpos($filename,"datadir")) {


		$localDir  = $ftp_rootdir.$filename."/";
		echo "LocalDir = ".$localDir."\n";
		$remoteDir = $remotedatapath.$filename."/";
		echo "RemoteDir = ".$remoteDir."\n";
		 
		// Create SFTP resource
		if (!$sftp = ssh2_sftp($connection)) throw new Exception('Unable to create SFTP connection.');


		$i = 0;
        $error = 0;

		// download all the files
		$files = scandir('ssh2.sftp://'.$sftp.$remoteDir);
		if (!empty($files)) {
		  	foreach ($files as $file) {
		  		echo $files[$i]."\n";
		    	if ($file != '.' && $file != '..' && $file != '.DS_Store') {
		    		echo "transfer = ".$files[$i]."\n";
		      		$error_transfer[$i] = ssh2_scp_recv($connection, $remoteDir.$file, $localDir.$file);
		      		$error += 1 - $error_transfer[$i];
		    	}
		    	
		    	$i = $i + 1; 
		  	}
		}

   } else {
 		$error = ssh2_scp_recv($connection, $remotedatapath.$filename,$ftp_rootdir.$filename);

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





