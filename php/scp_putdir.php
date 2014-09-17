<?php 

include "private/functions.php";
include "private/bridge.php";

// scp_putdir over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 

$remotehost = $_POST["remotehost"];
$remotedatapath = $_POST["remotedatapath"];
$batch_dir = $_POST["batch_dir"];
$pbssearch = $_POST["pbssearch"];
$condorsearch = $_POST["condorsearch"];
$xgridsearch = $_POST["xgridsearch"];
$directsearch = $_POST["directsearch"];
$sgesearch = $_POST["sgesearch"];
$timeid = $_POST["timeid"];
$script = $_POST["script"];
$remoteuser = $_POST['remoteuser'];

list($remote_host,$remote_login,$remote_password) = login($remotehost,$remoteuser);

$safemode = safemode($remotehost);

$connection = ssh2_connect($remote_host);

if (ssh2_auth_password($connection, $remote_login, $remote_password)) {
   //echo "Successful ssh identification !"."\n";

   $ftp_rootdir = ftprootdir();
      //echo $ftp_rootdir.$batch_dir."\n";
      //echo "Bridge folder: ".getcwd()."\n";

   echo "scp2php_error:".ssh2_transfer_dir($connection,$post,$safemode,$ftp_rootdir,$remotedatapath,$batch_dir)."\n";

} else {

   die('Identification failed...');

}



function ssh2_transfer_dir($connection,$post,$safemode,$ftp_rootdir, $remotedatapath,$batch_dir) {


      $remote_cmd = "mkdir ".$remotedatapath.$batch_dir;//create batch dir on remote machine

      $stream = ssh2_exec($connection, $remote_cmd);  

      //echo "remote_cmd = ".$remote_cmd;

      $errorStream = ssh2_fetch_stream($stream, SSH2_STREAM_STDERR);
     
      stream_set_blocking($errorStream, true);
      stream_set_blocking($stream, true);
     
      echo stream_get_contents($stream)."\n";

      $error0 = stream_get_contents($errorStream)."\n";
      //echo $error0;
     
      
      //$safemode = 0;

      if ($safemode >= 1) {

         $bridgetype = 'bridge_';
         $script_name = make_batch_script($post,$bridgetype);//make batch script on the bridge (security enforced)
         
         $crc1 = strtoupper(dechex(crc32(file_get_contents($ftp_rootdir.$batch_dir.$script_name))));
         $crc2 = strtoupper(dechex(crc32(file_get_contents($ftp_rootdir.$batch_dir.$bridgetype.$script_name))));
         //echo "scrc1 : ".$crc1."\n";
         //echo "scrc2 : ".$crc2."\n";

        if ($crc1 != $crc2) {// files not the same
            
            
            $fp = fopen($ftp_rootdir.$batch_dir.$script_name, 'r');
            $content1 = fread($fp,filesize($ftp_rootdir.$batch_dir.$script_name));
            fclose($fp);

            $fp = fopen($ftp_rootdir.$batch_dir.$bridgetype.$script_name, 'r');
            $content2 = fread($fp,filesize($ftp_rootdir.$batch_dir.$bridgetype.$script_name));
            fclose($fp);

            $flag = sendmail($remotehost,$script_name.": ".$crc1."\n".$content1."\n".$bridgetype.$script_name.": ".$crc2."\n".$content2,$remoteuser);
            die("*************************************************\nNon standard script file command in MatRemote:\n".$script_name."\nAn automatic message has been  send to the administrator.\nJob aborted...\n*************************************************");
            
         }
         
      }
      

      $files = scandir($ftp_rootdir.$batch_dir);
      
      while ($i < sizeof($files)) {

         $ext = end(explode('.',$files[$i]));
         //echo $files[$i]." - ".$ext."\n";


         if ((strcmp($files[$i],"datadir_".$timeid) == 0) OR (strcmp($files[$i],"MAT_RUN_".$timeid.".mat") == 0) OR (similar_text($ext, "m") == 1) OR (strcmp($files[$i],$script) == 0)) {
            //echo "non unlink : ".$files[$i]." - ".$ext."\n";
            if (($safemode >= 2) AND (strcmp($files[$i],$script) == 0)){
                  //echo "unlink : ".$files[$i]." - ".$ext."\n";
                  unlink($ftp_rootdir.$batch_dir.$script);//remove non authorized files 
               } elseif ($safemode >= 3) {
                  //echo "unlink : ".$files[$i]." - ".$ext."\n";
                  unlink($ftp_rootdir.$batch_dir.$script);//remove non authorized files
               }

         } else {
            if ($safemode >= 1) {
               //echo "unlink : ".$files[$i]." - ".$ext."\n";
               unlink($ftp_rootdir.$batch_dir.$files[$i]);//remove non authorized files
            }
         }

         $i = $i + 1; 
      }

      if ($safemode >= 1) {
         $script_name = make_batch_script($_POST,'');//make batch script on the bridge (security enforced)
      } 

      $i = 0;
      $error1 = 0;

      $files = scandir($ftp_rootdir.$batch_dir);

      while ($i < sizeof($files)) {
         if ((strcmp($files[$i],".") != 0) AND (strcmp($files[$i],"..") != 0) AND (strcmp($files[$i],".DS_Store") != 0)) {
            //echo " - File-$i : ".$files[$i]."\n";  
            //echo $ftp_rootdir.$batch_dir.$files[$i]."\n";
            //echo $remotedatapath.$batch_dir.$files[$i]."\n";
            if (is_file($ftp_rootdir.$batch_dir.$files[$i])) {
               $error_transfer[$i] = ssh2_scp_send($connection,$ftp_rootdir.$batch_dir.$files[$i],$remotedatapath.$batch_dir.$files[$i]);
            } else {

               //$error_transfer[$i] = ssh2_transfer_dir($connection,$post,$safemode,$ftp_rootdir.$files[$i]."/",$remotedatapath.$batch_dir,$files[$i]);
               /**************** YP: recursive job must be done ***************/


               $remote_cmd = "mkdir ".$remotedatapath.$batch_dir.$files[$i];//create batch dir on remote machine
               //echo "command for new dir = ".$remote_cmd."\n";
               $error_transfer[$i] = ssh2_exec($connection, $remote_cmd);

            }
            $error1 += 1 - $error_transfer[$i];
         }
         $i = $i + 1; 
      }
     
      if ($error1 > 0) {
         return $error0."-".$error1;
      } else {
         return $error0;
     }


}

?>






