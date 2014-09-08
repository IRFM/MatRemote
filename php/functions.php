<?php 

// functions for scp over php for MatRemote Matlab library
// by Y. Peysson and J. Decker CEA/IRFM
// 

function filter_cmd($post){ //filter allowed commands transfered by the bridge (security enforced)

    $keys = keyslist();

    foreach ($keys as $key)  {
        $$key = $post[$key];//only preset keys are loaded (security)
    }

    list($remote_host,$remote_login,$remote_password) = login($remotehost,$remoteuser);
    
    $safemode = safemode($remotehost);

    // generic commands

    $localcmd[0] = "ls";
    $localcmd[1] = "test -d ".$remotedatapath;
    $localcmd[2] = "chmod -R 777 ".$remotedatapath.$batch_dir;
    $localcmd[3] = "ls ".$remotedatapath.$batch_dir;
    $localcmd[4] = "rm -fr ".$remotedatapath.$batch_dir;

    if (strcmp($remote_host,"tolbachik.hd.free.fr") == 0) {

		if (strcmp($condorsearch,"1") == 0) {

        	$localcmd[5] = "export CONDOR_CONFIG=".$condorconfig."; export PATH=".$condorpath."; export jobtimeid=".$timeid."; export debugmode=".$debugmode."; condor_submit ".$remotedatapath.$batch_dir.$condorscript." -v";
            $localcmd[6] = "export CONDOR_CONFIG=".$condorconfig."; export PATH=".$condorpath."; condor_q ".$id;

            $localcmd[7] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
            $localcmd[8] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
            $localcmd[9] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
            $localcmd[10] = "date +%Y%m%d%H%M%S";

    	} elseif (strcmp($xgridsearch,"1") == 0) {

        	if (strlen($password) > 0) {
  
            	$localcmd[5] = "xgrid -h ".$hostname." -p ".$remote_password." -job batch ".$remotedatapath.$batch_dir.$xgridscript;
            	$localcmd[6] = "xgrid -h ".$hostname." -p ".$remote_password." -job attributes -id ".$id;
           	    $localcmd[7] = "xgrid -h ".$hostname." -p ".$remote_password." -job results -id ".$id." -se ".$remotedatapath.$batch_dir."error_file -so ".$remotedatapath.$batch_dir."output_file -out";
				$localcmd[8] = "xgrid -h ".$hostname." -p ".$remote_password." -job results -id ".$id." -out ".$remotedatapath.$batch_dir;
				$localcmd[9] = "xgrid -h ".$hostname." -p ".$remote_password." -job delete -id ".$id;

                $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
                $localcmd[11] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
                $localcmd[12] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
                $localcmd[13] = "date +%Y%m%d%H%M%S";

        	} else {

            	$localcmd[5] = "xgrid -h ".$hostname." -job batch ".$remotedatapath.$batch_dir.$xgridscript;
            	$localcmd[6] = "xgrid -h ".$hostname." -job attributes -id ".$id;
            	$localcmd[7] = "xgrid -h ".$hostname." -job results -id ".$id." -se ".$remotedatapath.$batch_dir."error_file -so ".$remotedatapath.$batch_dir."output_file -out";
            	$localcmd[8] = "xgrid -h ".$hostname." -job results -id ".$id." -out ".$remotedatapath.$batch_dir;
            	$localcmd[9] = "xgrid -h ".$hostname." -job delete -id ".$id;

                $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
                $localcmd[11] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
                $localcmd[12] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
                $localcmd[13] = "date +%Y%m%d%H%M%S";

        	}

		} elseif (strcmp($directsearch,"1") == 0) {

        	$localcmd[5] = "export remotebatchdir=".$remotedatapath.$batch_dir."; export debugmode=".$debugmode."; export jobtimeid=".$timeid;

            if (strlen($lukeroot) > 0) $localcmd[5] = $localcmd[5]."; export luke_root=".$lukeroot;
            if (strlen($matlabroot) > 0) $localcmd[5] = $localcmd[5]."; export remotebatch_matlabroot=".$matlabroot;
            if (strlen($remotematfnc) > 0) $localcmd[5] = $localcmd[5]."; export remotematfnc=".$remotematfnc;
            if (strlen($testvar) > 0) $localcmd[5] = $localcmd[5]."; export TESTVAR=".$testvar;
            if (strlen($matlabfun) > 0) $localcmd[5] = $localcmd[5]."; export remotebatch_matlabfun=".$matlabfun;
            
            $localcmd[5] = $localcmd[5]."; nohup ".$remotedatapath.$batch_dir.$script." `</dev/null` >nohup.out 2>&1 &";

            $localcmd[6] = "ps -p ".$id;
        	$localcmd[7] = "cd ".$remotedatapath.$batch_dir.";rm pid_".$id.".mat";
        	$localcmd[8] = "rm -f nohup.out";

            $localcmd[9] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
            $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
            $localcmd[11] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
            $localcmd[12] = "date +%Y%m%d%H%M%S";
            $localcmd[13] = "cat ".$remotedatapath.$batch_dir."pid_".$timeid;

        }

    } elseif ((strcmp($remote_host,"shenma.ipp.ac.cn") == 0) || (strcmp($remote_host,"cluster02.swip.ac.cn") == 0)  || (strcmp($remote_host,"abacus.tok.ipp.cas.cz") == 0)) {

        if (strcmp($directsearch,"1") == 0) {

            $localcmd[5] = "export remotebatchdir=".$remotedatapath.$batch_dir."; export debugmode=".$debugmode."; export jobtimeid=".$timeid;
            if (strlen($lukeroot) > 0)  $localcmd[5] = $localcmd[5]."; export luke_root=".$lukeroot;
            $localcmd[5] = $localcmd[5]."; export remotebatch_matlabroot=".$matlabroot."; export remotematfnc=".$remotematfnc;
            if (strlen($testvar) > 0) $localcmd[5] = $localcmd[5]."; export TESTVAR=".$testvar;
            $localcmd[5] = $localcmd[5]."; export remotebatch_matlabfun=".$matlabfun."; nohup ".$remotedatapath.$batch_dir.$script." `</dev/null` >nohup.out 2>&1 &";

            $localcmd[6] = "ps -p ".$id." -o comm=";
            $localcmd[7] = "rm -f nohup.out";

            $localcmd[8] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
            $localcmd[9] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
            $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
            $localcmd[11] = "date +%Y%m%d%H%M%S";
            $localcmd[12] = "cat ".$remotedatapath.$batch_dir."pid_".$timeid;

        } elseif (strcmp($pbssearch,"1") == 0) {


            $cmdextras = "";

            if ((strcmp($remote_host,"cluster02.swip.ac.cn") == 0) && (strcmp($walltime,"00:15") == 0)) {
                $cmdextras = "debug";
            }
            if ((strcmp($remote_host,"cluster02.swip.ac.cn") == 0) && (strcmp($walltime,"05:00") == 0)) {
                $cmdextras = "express";
            }
            if ((strcmp($remote_host,"cluster02.swip.ac.cn") == 0) && (strcmp($walltime,"10:00") == 0)) {
                $cmdextras = "small";
            }
            if ((strcmp($remote_host,"cluster02.swip.ac.cn") == 0) && (strcmp($walltime,"24:00") == 0)) {
                $cmdextras = "medium";
            }
            if ((strcmp($remote_host,"cluster02.swip.ac.cn") == 0) && (strcmp($walltime,"168:00") == 0)) {
                $cmdextras = "long";
            }
            if ((strcmp($remote_host,"cluster02.swip.ac.cn") == 0) && (strcmp($walltime,"360:00") == 0)) {
                $cmdextras = "verylong";
            }


        	if (strcmp($wait,"1") == 0) {
            	$cmdextras = $cmdextras." -W block=true";
        	}

            if (strcmp($remote_host,"shenma.ipp.ac.cn") == 0) {
                $localcmd[5] = "qsub -q batch".$cmdextras." -l nodes=".$nodes.":ppn=".$ppn." -l ncpus=".$ncpus;
                $localcmd[6] = "qstat ".$id;
            } elseif (strcmp($remote_host,"cluster02.swip.ac.cn") == 0) {
                $localcmd[5] = "qsub -q ".$cmdextras." -l nodes=".$nodes.":ppn=".$ppn." -l ncpus=".$ncpus;
                $localcmd[6] = "qstat ".$id;
            } elseif (strcmp($remote_host,"abacus.tok.ipp.cas.cz") == 0) {
                $localcmd[5] = "qsub ".$cmdextras." -l nodes=".$nodes.":ppn=".$ppn." -l ncpus=".$ncpus;
                $localcmd[6] = "qstat ".$id.".abacus";
            }

            if (strlen($memory) > 0) $localcmd[5] = $localcmd[5]." -l mem=".$memory."mb";
            $localcmd[5] = $localcmd[5]." -l walltime=".$walltime.":00 -v jobtimeid=".$timeid.",debugmode=".$debugmode.","."remotebatchdir=".$remotedatapath.$batch_dir.",remotebatch_matlabfun=".$matlabfun;
            if (strlen($testvar) > 0) $localcmd[5] = $localcmd[5].",TESTVAR=".$testvar;
            $localcmd[5] = $localcmd[5].",remotematfnc=".$remotematfnc.",remotebatch_matlabroot=".$matlabroot;
            if (strlen($lukeroot) > 0) $localcmd[5] = $localcmd[5].",luke_root=".$lukeroot;
            $localcmd[5] = $localcmd[5]." ".$remotedatapath.$batch_dir.$script;

			$localcmd[7] = "rm -f ".$script.".e".$id." ".$script.".o".$id;

            $localcmd[8] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
            $localcmd[9] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
            $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
			$localcmd[11] = "date +%Y%m%d%H%M%S";

        }


    } elseif (strcmp($remote_host,"g01.efda-itm.eu") == 0) {

    	if (strcmp($directsearch,"1") == 0) {

        	$localcmd[5] = "export remotebatchdir=".$remotedatapath.$batch_dir."; export debugmode=".$debugmode."; export jobtimeid=".$timeid;
            if (strlen($lukeroot) > 0)  $localcmd[5] = $localcmd[5]."; export luke_root=".$lukeroot;
            $localcmd[5] = $localcmd[5]."; export remotebatch_matlabroot=".$matlabroot."; export remotematfnc=".$remotematfnc;
            if (strlen($testvar) > 0) $localcmd[5] = $localcmd[5]."; export TESTVAR=".$testvar;
            //$localcmd[5] = $localcmd[5]."; export remotebatch_matlabfun=".$matlabfun."; nohup ".$remotedatapath.$batch_dir.$script." `</dev/null` >nohup.out 2>&1 &";
            $localcmd[5] = $localcmd[5]."; export remotebatch_matlabfun=".$matlabfun."; ".$remotedatapath.$batch_dir.$script." &";

            $localcmd[6] = "ps -p ".$id." -o comm=";
        	$localcmd[7] = "rm -f nohup.out";

        	$localcmd[8] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
            $localcmd[9] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
            $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
			$localcmd[11] = "date +%Y%m%d%H%M%S";
            $localcmd[12] = "cat ".$remotedatapath.$batch_dir."pid_".$timeid;


        } elseif (strcmp($sgesearch,"1") == 0) {

        	$localcmd[5] = "qsub ".$remotedatapath.$batch_dir.$sgescript;
        	$localcmd[6] = "qstat -j ".$id;
        	$localcmd[7] = "rm -f ".strstr($script,'.',true).".e".$id." ".strstr($script,'.',true).".o".$id;

            $localcmd[8] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
            $localcmd[9] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
            $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
			$localcmd[11] = "date +%Y%m%d%H%M%S";

    	}

    } elseif (strcmp($remote_host,"andromede1.partenaires.cea.fr") == 0) {

		if (strcmp($directsearch,"1") == 0) {

        	$localcmd[5] = "setenv remotebatchdir ".$remotedatapath.$batch_dir."; setenv debugmode ".$debugmode;
            $localcmd[5] = $localcmd[5]."; setenv jobtimeid ".$timeid;
            if (strlen($lukeroot) > 0)  $localcmd[5] = $localcmd[5]."; setenv luke_root ".$lukeroot;
            $localcmd[5] = $localcmd[5]."; setenv remotebatch_matlabroot ".$matlabroot;
            $localcmd[5] = $localcmd[5]."; setenv remotematfnc ".$remotematfnc;
            if (strlen($testvar) > 0) $localcmd[5] = $localcmd[5]."; setenv TESTVAR ".$testvar;
            $localcmd[5] = $localcmd[5]."; setenv remotebatch_matlabfun ".$matlabfun."; ".$remotedatapath.$batch_dir.$script;

        	$localcmd[6] = $localcmd[5]." &";

        	$localcmd[7] = "ps -p ".$id." -o comm=";
        	$localcmd[8] = "rm -f nohup.out";

            $localcmd[9] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
            $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
            $localcmd[11] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
			$localcmd[12] = "date +%Y%m%d%H%M%S";
            $localcmd[13] = "cat ".$remotedatapath.$batch_dir."pid_".$timeid;


   		}  elseif (strcmp($pbssearch,"1") == 0) {

       		if (strcmp($wait,"1") == 0) {
            	$cmdextras = " -W block=true";
        	} else {
            	$cmdextras = "";
        	}			

            $localcmd[5] = "qsub".$cmdextras." -l nodes=".$nodes.":ppn=".$ppn." -l ncpus=".$ncpus;
            if (strlen($memory) > 0) $localcmd[5] = $localcmd[5]." -l mem=".$memory."mb";
            $localcmd[5] = $localcmd[5]." -l walltime=".$walltime.":00 -v jobtimeid=".$timeid.",debugmode=".$debugmode.","."remotebatchdir=".$remotedatapath.$batch_dir.",remotebatch_matlabfun=".$matlabfun;
            if (strlen($testvar) > 0) $localcmd[5] = $localcmd[5].",TESTVAR=".$testvar;
            $localcmd[5] = $localcmd[5].",remotematfnc=".$remotematfnc.",remotebatch_matlabroot=".$matlabroot;
            if (strlen($lukeroot) > 0) $localcmd[5] = $localcmd[5].",luke_root=".$lukeroot;
            $localcmd[5] = $localcmd[5]." ".$remotedatapath.$batch_dir.$script;

            $localcmd[6] = "qstat ".$id.'.andromede1';
        	$localcmd[7] = "rm -f ".$script.".e".$id." ".$script.".o".$id;

            $localcmd[8] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."pid_".$timeid;
            $localcmd[9] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_OUT_".$timeid.".mat";
            $localcmd[10] = "python -c \"import os,time,sys; print time.strftime(sys.argv[1],time.gmtime(os.path.getmtime(sys.argv[2])))\" %Y%m%d%H%M%S ".$remotedatapath.$batch_dir."MAT_RUN_".$timeid.".mat";
			$localcmd[11] = "date +%Y%m%d%H%M%S";
       }

    }

    $flag = 1;

    for ($i = 0; $i < count($localcmd); $i++) {
        if (strcmp($localcmd[$i],$remotecmd) == 0) {
            $flag = 0; 
            break;  	
        }
    }

    if (((strcmp($remotedatapath,"*") == 0) || (strcmp($remotedatapath,"*.") == 0) || (strcmp($remotedatapath,"*.*") == 0)) AND ($safemode == 1)) $flag = 1;
    if (((strcmp($batch_dir,"*.*") == 0) || (strcmp($batch_dir,".*") == 0) || (strcmp($batch_dir,"*") == 0)) AND ($safemode == 1)) $flag = 1;

    
    $txt = "send command: \n".$remotecmd."\n";

    for ($i = 0; $i < count($localcmd); $i++) {
        $txt = $txt."bridge command (".$i."): \n".$localcmd[$i]."\n";
    }

    
    if ($safemode == 0) {
        $flag = 0;//disable the filtering
    }
    

    return array($flag,$txt);
} 

function sendmail($remotehost,$remotecmd,$remoteuser){ 


    $mailadress = mailadresslist($remoteuser);

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


function make_batch_script($post,$bridgetype){

    $keys = keyslist();

    foreach ($keys as $key)  {
        $$key = $post[$key];//only preset keys are loaded (security)
    }


    list($remote_host,$remote_login,$remote_password) = login($remotehost,$remoteuser);

    $safemode = safemode($remotehost);

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


        $batchscript = $batchscript."#!/bin/bash\n";
        $batchscript = $batchscript."#$ -l h_rt=".$walltime.":00:00\n";
        $batchscript = $batchscript."#$ -l h_vmem=".$memory."M\n";
        $batchscript = $batchscript."#$ -cwd\n";
        $batchscript = $batchscript."#$ -N ".strstr($script,'.',true)."\n";
        $batchscript = $batchscript."#$ -M ".$usermail."\n";
        $batchscript = $batchscript."#$ -m e\n";
        $batchscript = $batchscript."#$ -notify\n";

        $i = 1; 

        while ($i <= $nbatchscriptparams) {

            $cmd = $post["batchscriptparams".$i];
            
            $batchscript = $batchscript.$cmd."\n";

            $i = $i + 1;
            
        }

        $batchscript = $batchscript.$envcmdbase1.'jobtimeid'.$envcmdbase2.$timeid."\n";

		if (strlen($debugmode) > 0) $batchscript = $batchscript.$envcmdbase1.'debugmode'.$envcmdbase2.$debugmode."\n";

        $batchscript = $batchscript.$envcmdbase1.'remotebatch_matlabfun'.$envcmdbase2.$matlabfun."\n";
        
        if (strlen($testvar) > 0) $batchscript = $batchscript.$envcmdbase1.'TESTVAR'.$envcmdbase2.$testvar."\n";
        $batchscript = $batchscript.$envcmdbase1.'remotematfnc'.$envcmdbase2.$remotematfnc."\n";

        $batchscript = $batchscript.$envcmdbase1.'remotebatch_matlabroot'.$envcmdbase2.$matlabroot."\n";

        if (strlen($lukeroot) > 0) $batchscript = $batchscript.$envcmdbase1.'luke_root'.$envcmdbase2.$lukeroot."\n";

        $batchscript = $batchscript.'cd '.$remotedatapath.$batch_dir."\n";
        $batchscript = $batchscript.$remotedatapath.$batch_dir.$script."\n";
        
        $flag_script = fopen($bridgetype.$sgescript,'w');
        $script_name = $sgescript;

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

        $jobenvstr = "remotebatch_matlabfun=".$matlabfun;
        
        if (strlen($testvar) > 0) $jobenvstr = $jobenvstr.";TESTVAR=".$testvar;
        if (strlen($remotematfnc) > 0) $jobenvstr = $jobenvstr.";remotematfnc=".$remotematfnc;
        if (strlen($remotematfnc) > 0) $jobenvstr = $jobenvstr.";remotebatch_matlabroot=".$matlabroot;
        if (strlen($lukeroot) > 0) $jobenvstr = $jobenvstr.";luke_root=".$lukeroot;
        if (strlen($batch_dir) > 0) $jobenvstr = $jobenvstr.";remotebatchdir=".$remotedatapath.$batch_dir;

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

        $flag_script = fopen($bridgetype.$condorscript, 'w');
        $script_name = $condorscript;

    }

    if ((strcmp($xgridsearch,'1') == 0) AND ($safemode >= 1)) {
     
        $batchscript = '<?xml version="1.0" encoding="UTF-8"?>'."\n";
        $batchscript = $batchscript.'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'."\n";
        $batchscript = $batchscript.'<plist version="1.0">'."\n";
        $batchscript = $batchscript.'<array>'."\n";
        $batchscript = $batchscript.'<dict>'."\n";
        $batchscript = $batchscript.'<key>name</key>'."\n";
        $batchscript = $batchscript.'<string>matlab_job_'.$timeid.'</string>'."\n";
        $batchscript = $batchscript.'<key>taskSpecifications</key>'."\n";
        $batchscript = $batchscript.'<dict>'."\n";
        $batchscript = $batchscript.'<key>0</key>'."\n";//first job
        $batchscript = $batchscript.'<dict>'."\n";
        $batchscript = $batchscript.'<key>arguments</key>'."\n";
        $batchscript = $batchscript.'<array>'."\n";
        $batchscript = $batchscript.'<string>'.$remotedatapath.$batch_dir.$script.'</string>'."\n";
        $batchscript = $batchscript.'</array>'."\n";
        $batchscript = $batchscript.'<key>command</key>'."\n";
        $batchscript = $batchscript.'<string>/bin/sh</string>'."\n";
        $batchscript = $batchscript.'<key>environment</key>'."\n";
        $batchscript = $batchscript.'<dict>'."\n";
        $batchscript = $batchscript.'<key>remotebatch_matlabfun</key>'."\n";
        $batchscript = $batchscript.'<string>'.$matlabfun.'</string>'."\n";

        if (strlen($testvar) > 0) {
            $batchscript = $batchscript.'<key>TESTVAR</key>'."\n";
            $batchscript = $batchscript.'<string>'.$testvar.'</string>'."\n";
        }
        $batchscript = $batchscript.'<key>remotematfnc</key>'."\n";
        $batchscript = $batchscript.'<string>'.$remotematfnc.'</string>'."\n";
        
        $batchscript = $batchscript.'<key>remotebatch_matlabroot</key>'."\n";
        $batchscript = $batchscript.'<string>'.$matlabroot.'</string>'."\n";
        $batchscript = $batchscript.'<key>MATLABPATH</key>'."\n";
        $batchscript = $batchscript.'<string>'.$matlabpath.'</string>'."\n";
        if (strlen($lukeroot) > 0) {
            $batchscript = $batchscript.'<key>luke_root</key>'."\n";
            $batchscript = $batchscript.'<string>'.$lukeroot.'</string>'."\n";
        }
        $batchscript = $batchscript.'<key>jobtimeid</key>'."\n";
        $batchscript = $batchscript.'<string>'.$timeid.'</string>'."\n";
        $batchscript = $batchscript.'<key>debugmode</key>'."\n";
        $batchscript = $batchscript.'<string>'.$debugmode.'</string>'."\n";
        $batchscript = $batchscript.'<key>hostname</key>'."\n";
        $batchscript = $batchscript.'<string>'.$hostname.'</string>'."\n";
        $batchscript = $batchscript.'<key>remotebatchdir</key>'."\n";
        $batchscript = $batchscript.'<string>'.$remotedatapath.$batch_dir.'</string>'."\n";
        $batchscript = $batchscript.'</dict>'."\n";
        $batchscript = $batchscript.'</dict>'."\n";
        $batchscript = $batchscript.'</dict>'."\n";
        $batchscript = $batchscript.'</dict>'."\n";
        $batchscript = $batchscript.'</array>'."\n";
        $batchscript = $batchscript.'</plist>'."\n";

        $flag_script = fopen($bridgetype.$xgridscript, 'w');
        $script_name = $xgridscript;
        
    }
   
    if (((strcmp($xgridsearch,'1') == 0) OR (strcmp($sgesearch,'1') == 0) OR (strcmp($condorsearch,'1') == 0)) AND ($safemode >= 1)) {
        fwrite($flag_script, $batchscript);
        fclose($flag_script);
    }
    
    chdir($init_dir);

    return $script_name;

}

?>




