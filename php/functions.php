<?php 

// functions for scp over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 

function filter_cmd($post){ //filter allowed commands transfered by the bridge (security enforced)

    $keys = keyslist();

    foreach ($keys as $key)  {
        $$key = $post[$key];//only preset keys are loaded (security)
    }

    list($remote_host,$remote_login,$remote_password,$pbssearch,$condorsearch,$xgridsearch,$directsearch,$sgesearch) = login($remotehost);
    
    $safemode = safemode();

    $localcmd[0] = "ls";
    $localcmd[1] = "test -d ".$remotedatapath;
    $localcmd[2] = "chmod -R 777 ".$remotedatapath.$batch_dir;
    $localcmd[3] = "ls ".$remotedatapath.$batch_dir;
    $localcmd[4] = "rm -fr ".$remotedatapath.$batch_dir;
    $localcmd[5] = 'echo $SHELL';
    $localcmd[6] = "";
    $localcmd[7] = "";
    $localcmd[8] = "";


    if (strcmp($pbssearch,"1") == 0) {

        if (strcmp($wait,"1") == 0) {
            $cmdextras = " -W block=true";
        } else {
            $cmdextras = "";
        }

        $localcmd[6] = "qsub -q batch".$cmdextras." -l nodes=".$nodes.":ppn=".$ppn." -l ncpus=".$ncpus." -l mem=".$memory."mb -l walltime=".$walltime.":00:00 -v jobtimeid=".$timeid.",debugmode=".$debugmode.","."remotebatchdir=".$remotedatapath.$batch_dir.",remotebatch_matlabfun=".$matlabfun.",remotepathfnc=".$remotepathfnc.",TESTVAR=".$testvar.",remotematfnc=".$remotematfnc.",remotebatch_matlabroot=".$matlabroot.",remotebatch_matlabprefdir=".$matlabprefdir." ".$remotedatapath.$batch_dir.$script;
        $localcmd[7] = "qstat ".$id;
        $localcmd[8] = "rm -f matlabbatch.sh.e".$id." matlabbatch.sh.o".$id;

    }

    if (strcmp($condorsearch,"1") == 0) {

        $localcmd[6] = "export CONDOR_CONFIG=".$condorconfig."; export PATH=".$condorpath."; export jobtimeid=".$timeid."; export debugmode=".$debugmode."; condor_submit ".$remotedatapath.$batch_dir.$condorscript." -v";
        $localcmd[7] = "export CONDOR_CONFIG=".$condorconfig."; export PATH=".$condorpath."; condor_q ".$id;

    }

    if (strcmp($xgridsearch,"1") == 0) {

        if (strlen($remote_password) > 0) {
  
            $localcmd[6] = "xgrid -h ".$hostname." -p ".$remote_password." -job batch ".$remotedatapath.$batch_dir.$xgridscript;
            $localcmd[7] = "xgrid -h ".$hostname." -p ".$remote_password." -job attributes -id ".$id;

        } else {

            $localcmd[6] = "xgrid -h ".$hostname." -job batch ".$remotedatapath.$batch_dir.$condorscript;
            $localcmd[7] = "xgrid -h ".$hostname." -job attributes -id ".$id;
        }
   
    }

    if (strcmp($directsearch,"1") == 0) {

        if (strcmp($remote_host,"tolbachik.hd.free.fr") == 0) {

            $localcmd[6] = "export remotebatchdir=".$remotedatapath.$batch_dir."; export debugmode=".$debugmode."; export jobtimeid=".$timeid."; export remotebatch_matlabprefdir=".$matlabprefdir."; export remotebatch_matlabroot=".$matlabroot."; export remotematfnc=".$remotematfnc."; export TESTVAR=".$testvar."; export remotepathfnc=".$remotepathfnc."; export remotebatch_matlabfun=".$matlabfun."; ".$remotedatapath.$batch_dir.$script;
            $localcmd[7] = "ps -p ".$id;
            $localcmd[8] = "cd ".$remotedatapath.$batch_dir.";rm pid_".$id.".mat";

        }

        if (strcmp($remote_host,"shenma.ipp.ac.cn") == 0) {

            $localcmd[6] = "setenv remotebatchdir ".$remotedatapath.$batch_dir."; setenv debugmode ".$debugmode."; setenv jobtimeid ".$timeid."; setenv remotebatch_matlabprefdir ".$matlabprefdir."; setenv remotebatch_matlabroot ".$matlabroot."; setenv remotematfnc ".$remotematfnc."; setenv TESTVAR ".$testvar."; setenv remotepathfnc ".$remotepathfnc."; setenv remotebatch_matlabfun ".$matlabfun."; ".$remotedatapath.$batch_dir.$script;
            $localcmd[7] = "ps -p ".$id." -o comm=";
 
        }
        
        if (strcmp($remote_host,"g01.efda-itm.eu") == 0) {
            
        }

        if (strcmp($remote_host,"andromede1.partenaires.cea.fr") == 0) {

            $localcmd[6] = "setenv remotebatchdir ".$remotedatapath.$batch_dir."; setenv debugmode ".$debugmode."; setenv jobtimeid ".$timeid."; setenv remotebatch_matlabprefdir ".$matlabprefdir."; setenv remotebatch_matlabroot ".$matlabroot."; setenv remotematfnc ".$remotematfnc."; setenv TESTVAR ".$testvar."; setenv remotepathfnc ".$remotepathfnc."; setenv remotebatch_matlabfun ".$matlabfun."; ".$remotedatapath.$batch_dir.$script." &;";
            $localcmd[7] = "ps -p ".$id." -o comm=";
        }       
  
    }

    if (strcmp($sgesearch,"1") == 0) {

        $localcmd[6] = "qsub ".$remotedatapath.$batch_dir.$sgescript;
        $localcmd[7] = "qstat -j ".$id;

    }

    $flag = 1;
    $txt = "";

    for ($i = 0; $i < count($localcmd); $i++) {

        if (strcmp($localcmd[$i],$remotecmd) == 0) {
            $txt = $localcmd[$i];
            $flag = 0;
        }
    }
    
    if (((strcmp($remotedatapath,"*") == 0) || (strcmp($remotedatapath,"*.") == 0) || (strcmp($remotedatapath,"*.*") == 0)) AND ($safemode == 1)) $flag = 1;
    if (((strcmp($batch_dir,"*.*") == 0) || (strcmp($batch_dir,".*") == 0) || (strcmp($batch_dir,"*") == 0)) AND ($safemode == 1)) $flag = 1;

    //***************** UNCOMMENT the following line to check the output string (see also ssh.php *************************
    //$txt = $localcmd[0];//$localcmd[5];
    //**********************************************************************************************************************************************
    
    if ($safemode >= 1) {
        $flag = 0;//disable the filtering
    }
    

    return array($flag,$txt);
} 

function sendmail($remotehost,$remotecmd,$remoteuser){ 


    $mailadress = mailadresslist();

    $to = $mailadress[1];
    //echo "to:".$to."\n";
    $subject = "MatRemote filtering error";
    //echo "subject:".$subject."\n";
    $message = "This is an automatic warning message generated by the MatRemote library.\n"."A forbidden filtered remote command has been send :\n".$remotecmd."\n"."The forbidden command has been send by the user:\n".$remoteuser."\n";
    //echo "message:".$message."\n";
    $headers = 'From: '.$mailadress[0]."\r\n".'X-Mailer: PHP/';
    //echo "headers:".$headers."\n";
    if (mail($to, $subject, $message, $headers)) {
       //echo("<p>Message successfully sent!</p>");
       $flag_mail = '0';
    } else {
       //echo("<p>Message delivery failed...</p>");
       $flag_mail = '1';
    }

    return $flag_mail;
}


function make_batch_script($post){

    $keys = keyslist();

    foreach ($keys as $key)  {
        $$key = $post[$key];//only preset keys are loaded (security)
    }


    list($remote_host,$remote_login,$remote_password) = login($remotehost);

    $safemode = safemode();

    $ftp_rootdir = ftprootdir();

    $initdir = getcwd();
    chdir($ftp_rootdir.$batch_dir);


    $batchscript = '';
    $flag_script = 1;

    if (strcmp($shell,'bash') == 0) {
        $envcmdbase1 = 'export ';
        $envcmdbase2 = '=';
    } elseif (strcmp($shell,'csh') == 0) {
        $envcmdbase1 = 'setenv ';
        $envcmdbase2 = ' ';
    } else {
        $envcmdbase1 = 'export ';
        $envcmdbase2 = '=';
    }

    if ((strcmp($sgesearch,'1') == 0) AND ($safemode >= 1)) {

        $i = 1; 

        while ($i <= $nbatchscriptparams) {

            $cmd = $post["batchscriptparams".$i];

            if (strcmp($cmd,'#$ -N') == 0) {
                $cmd = $cmd.' '.strstr($script,'.',true);
            } elseif (strcmp($cmd,'#$ -M') == 0) {
                $cmd = $cmd.' '.$usermail;
            } 
            
            $batchscript = $batchscript.$cmd."\n";

            $i = $i + 1;
            
        }

        $batchscript = $batchscript.$envcmdbase1.'jobtimeid'.$envcmdbase2.$timeid."\n";
        $batchscript = $batchscript.$envcmdbase1.'debugmode'.$envcmdbase2.$debugmode."\n";
        $batchscript = $batchscript.$envcmdbase1.'remotebatch_matlabfun'.$envcmdbase2.$matlabfun."\n";
        $batchscript = $batchscript.$envcmdbase1.'remotepathfnc'.$envcmdbase2.$remotepathfnc."\n";
        $batchscript = $batchscript.$envcmdbase1.'remotematfnc'.$envcmdbase2.$remotematfnc."\n";
        $batchscript = $batchscript.$envcmdbase1.'TESTVAR'.$envcmdbase2.$testvar."\n";
        $batchscript = $batchscript.$envcmdbase1.'remotebatch_matlabroot'.$envcmdbase2.$matlabroot."\n";
        $batchscript = $batchscript.$envcmdbase1.'remotebatch_matlabprefdir'.$envcmdbase2.$matlabprefdir."\n";

        $batchscript = $batchscript.'cd '.$remotedatapath.$batch_dir."\n";
        $batchscript = $batchscript.$remotedatapath.$batch_dir.$xgridscript."\n";
        
        $flag_script = fopen($sgescript,'w');
    }

    if ((strcmp($condorsearch,'1') == 0) AND ($safemode >= 1)) {

        $batchscript = '####################'."\n";
        $batchscript = $batchscript.'##'."\n";
        $batchscript = $batchscript.'## Batch CONDOR file for remote job under id '.$timeid."\n";
        $batchscript = $batchscript.'##'."\n";
        $batchscript = $batchscript.'## Type the following commands in Matlab cmd window to check the CONDOR status'."\n";
        $batchscript = $batchscript.'##'."\n";
        $batchscript = $batchscript.'## ! condor_status (for the number of available nodes)'."\n";
        $batchscript = $batchscript.'## ! condor_q (job queue)'."\n";
        $batchscript = $batchscript.'##'."\n";
        $batchscript = $batchscript.'####################'."\n";
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'##User = '."\n";//username, if specified in the CONDOR config.local file
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";//CONDOR universe
        $batchscript = $batchscript.'Universe = vanilla'."\n";
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'InputDir = '.$remotedatapath.$batch_dir."\n";//CONDOR simulation input dir
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'OutputDir = '.$remotedatapath.$batch_dir."\n";//CONDOR simulation output dir
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'Executable = '.$remotedatapath.$batch_dir.$script."\n";//matlab shell script
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'InitialDir = $(InputDir)'."\n";
        $batchscript = $batchscript.' '."\n";

        if (strcmp($debugmode,'1') == 0) {

            $batchscript = $batchscript.'#'."\n";
            $batchscript = $batchscript.'Error = $(OutputDir)/condor_err.'.$timeid."\n";
            $batchscript = $batchscript.'Log = $(OutputDir)/condor_log.'.$timeid."\n";
            $batchscript = $batchscript.' '."\n";
        }

        $jobenvstr = "remotebatch_matlabfun=".$matlabfun.";remotepathfnc=".$remotepathfnc.";TESTVAR=".$testvar.";remotematfnc=".$remotematfnc.";remotebatch_matlabroot=".$matlabroot.";remotebatch_matlabprefdir=".$matlabprefdir;

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'environment = '.$jobenvstr."\n";//***************YP
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'GetEnv = true'."\n";
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'##Transfer-Input-Files =  '."\n";
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'##Transfer-Output-Files = '."\n";
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'Arguments = '."\n";//job arguments

        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'##Output = '."\n";
        $batchscript = $batchscript.' '."\n";

        $batchscript = $batchscript.'#'."\n";
        $batchscript = $batchscript.'Queue 1'."\n";
        $batchscript = $batchscript.' '."\n";

        $flag_script = fopen($condorscript, 'w');

    }

    if ((strcmp($xgridsearch,'1') == 0) AND ($safemode >= 1)) {
     
        $batchscript = '<?xml version="1.0" encoding="UTF-8"?>'."\n";
        $batchscript = $batchscript.'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'."\n";
        $batchscript = $batchscript.'<plist version="1.0">'."\n";
        $batchscript = $batchscript.'<array>'."\n";
        $batchscript = $batchscript.'   <dict>'."\n";
        $batchscript = $batchscript.'       <key>name</key>'."\n";
        $batchscript = $batchscript.'       <string>matlab_job_'.$timeid.'</string>'."\n";
        $batchscript = $batchscript.'       <key>taskSpecifications</key>'."\n";
        $batchscript = $batchscript.'       <dict>'."\n";
        $batchscript = $batchscript.'           <key>0</key>'."\n";//first job
        $batchscript = $batchscript.'           <dict>'."\n";
        $batchscript = $batchscript.'               <key>arguments</key>'."\n";
        $batchscript = $batchscript.'               <array>'."\n";
        $batchscript = $batchscript.'                   <string>'.$remotedatapath.$batch_dir.$script.'</string>'."\n";
        $batchscript = $batchscript.'               </array>'."\n";
        $batchscript = $batchscript.'               <key>command</key>'."\n";
        $batchscript = $batchscript.'               <string>/bin/sh</string>'."\n";
        $batchscript = $batchscript.'               <key>environment</key>'."\n";
        $batchscript = $batchscript.'               <dict>'."\n";

        $batchscript = $batchscript.'                   <key>remotebatch_matlabfun</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$matlabfun.'</string>'."\n";
        $batchscript = $batchscript.'                   <key>remotepathfnc</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$remotepathfnc.'</string>'."\n";
        $batchscript = $batchscript.'                   <key>remotematfnc</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$remotematfnc.'</string>'."\n";
        $batchscript = $batchscript.'                   <key>TESTVAR</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$testvar.'</string>'."\n";
        $batchscript = $batchscript.'                   <key>remotebatch_matlabroot</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$matlabroot.'</string>'."\n";

        $batchscript = $batchscript.'                   <key>jobtimeid</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$timeid.'</string>'."\n";
        $batchscript = $batchscript.'                   <key>debugmode</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$debugmode.'</string>'."\n";
        $batchscript = $batchscript.'                   <key>hostname</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$hostname.'</string>'."\n";
        $batchscript = $batchscript.'                   <key>remotebatchdir</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$remotedatapath.$batch_dir.'</string>'."\n";
        $batchscript = $batchscript.'                   <key>MATLAB_PREFDIR</key>'."\n";
        $batchscript = $batchscript.'                   <string>'.$remotebatch_matlabprefdir.'</string>'."\n";
        $batchscript = $batchscript.'               </dict>'."\n";
        $batchscript = $batchscript.'           </dict>'."\n";
        $batchscript = $batchscript.'       </dict>'."\n";
        $batchscript = $batchscript.'   </dict>'."\n";
        $batchscript = $batchscript.'</array>'."\n";
        $batchscript = $batchscript.'</plist>'."\n";

        $flag_script = fopen($xgridscript, 'w');
        
    }
   
    if (((strcmp($xgridsearch,'1') == 0) OR (strcmp($sgesearch,'1') == 0) OR (strcmp($condorsearch,'1') == 0)) AND ($safemode >= 1)) {
        fwrite($flag_script, $batchscript);
        fclose($flag_script);
    }
    
    chdir($init_dir);

    return $flag_script;

}

?>




