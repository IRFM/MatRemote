<?php 
//test
function login($remotehost,$remoteuser) {

  if ($remotehost == 'andromede1.partenaires.cea.fr') {

    $remote_host = $remotehost;
    $pbssearch = 1;
    $condorsearch = 0;
    $xgridsearch = 0;
    $directsearch = 1;
    $sgesearch = 0;

    //if ($remoteuser == 'JD211098') {
    //   $remote_login = 'JD211098';
    //   $remote_password = '!!Platypus76';
    //} else {
    $remote_login = 'YP105119';
    $remote_password = 'g9Ft]fKrspHuNiYi6';
    //}

  }

  if ($remotehost == 'shenma.ipp.ac.cn') {
     $remote_host = $remotehost;
     $remote_login = 'PEYSSON';
     $remote_password = 'ij4ca4+EM';%
     $pbssearch = 1;
     $condorsearch = 0;
     $xgridsearch = 0;
     $directsearch = 1;
     $sgesearch = 0;
  }

  if ($remotehost == 'loki') {
     $remote_host = $remotehost;
     $remote_login = 'ypeysson';
     $remote_password = 'hjpmNZx38oDUsLyfEH';
     $pbssearch = 1;
     $condorsearch = 0;
     $xgridsearch = 0;
     $directsearch = 1;
     $sgesearch = 0;
  }

  if ($remotehost == 'lohan14.gat.com') {
     $remote_host = $remotehost;
     $remote_login = 'peyssony';
     $remote_password = 'lNjBl0OYjdo,OfGXJVpwTjtB7PR';
     $pbssearch = 1;
     $condorsearch = 0;
     $xgridsearch = 0;
     $directsearch = 1;
     $sgesearch = 0;
  }

  if ($remotehost == 'g01.efda-itm.eu') {
     $remote_host = $remotehost;
     $remote_login = 'yvesp';
     $remote_password = 'qF4VQuAAXCZ4p';
     $pbssearch = 0;
     $condorsearch = 0;
     $xgridsearch = 0;
     $directsearch = 1;
     $sgesearch = 1;
  }

  if ($remotehost == 'tolbachik.hd.free.fr') {
     $remote_host = $remotehost;
     $remote_login = 'yvespeysson';
     $remote_password = 'ghm93';
     $pbssearch = 0;
     $condorsearch = 1;
     $xgridsearch = 1;
     $directsearch = 1;
     $sgesearch = 0;
  }

  if ($remotehost == 'cluster02.swip.ac.cn') {
     $remote_host = $remotehost;
     $remote_login = 'Yves';
     $remote_password = '123456Aa';
     $pbssearch = 1;
     $condorsearch = 0;
     $xgridsearch = 0;
     $directsearch = 1;
     $sgesearch = 0;
  }

    if ($remotehost == 'abacus.tok.ipp.cas.cz') {
     $remote_host = $remotehost;
     $remote_login = 'peysson';
     $remote_password = 'nxcpQQ4zHJ2rRA';
     $pbssearch = 1;
     $condorsearch = 0;
     $xgridsearch = 0;
     $directsearch = 1;
     $sgesearch = 0;
  }

  return array($remote_host,$remote_login,$remote_password,$pbssearch,$condorsearch,$xgridsearch,$directsearch,$sgesearch);

}

function ftprootdir() {

  //echo "Bridge hostname: ".gethostname()."<br>";

  if (strcmp(gethostname(),"raspberrypi1") == 0) {
    $ftp_rootdir = '/home/matremote/ftp/transfer/';
  }

  if (strcmp(gethostname(),"macproyves") == 0) {
    $ftp_rootdir = '/Users/ftp/VirtualUsers/matremote/';
  }  

  return $ftp_rootdir;

}

function safemode($remotehost) {

  
 if ($remotehost == 'andromede1.partenaires.cea.fr') {
    $safemode = 1;// 0: unsafe mode, 1: partial safe mode (transfer of *.m files and the job script file), 2: safe mode: keep only the MAT_RUN_$timeid.mat input file and the *m files, 3: full safe mode: keep only the MAT_RUN_$timeid.mat input file

  }

  if ($remotehost == 'shenma.ipp.ac.cn') {
    $safemode = 1;// 0: unsafe mode, 1: partial safe mode (transfer of *.m files and the job script file), 2: safe mode: keep only the MAT_RUN_$timeid.mat input file and the *m files, 3: full safe mode: keep only the MAT_RUN_$timeid.mat input file
 }

 if ($remotehost == 'cluster02.swip.ac.cn') {
    $safemode = 1;// 0: unsafe mode, 1: partial safe mode (transfer of *.m files and the job script file), 2: safe mode: keep only the MAT_RUN_$timeid.mat input file and the *m files, 3: full safe mode: keep only the MAT_RUN_$timeid.mat input file
 }

  if ($remotehost == 'g01.efda-itm.eu') {
    $safemode = 1;// 0: unsafe mode, 1: partial safe mode (transfer of *.m files and the job script file), 2: safe mode: keep only the MAT_RUN_$timeid.mat input file and the *m files, 3: full safe mode: keep only the MAT_RUN_$timeid.mat input file
  }

  if ($remotehost == 'tolbachik.hd.free.fr') {
    $safemode = 1;// 0: unsafe mode, 1: partial safe mode (transfer of *.m files and the job script file), 2: safe mode: keep only the MAT_RUN_$timeid.mat input file and the *m files, 3: full safe mode: keep only the MAT_RUN_$timeid.mat input file
 }

   if ($remotehost == 'abacus.tok.ipp.cas.cz') {
    $safemode = 1;// 0: unsafe mode, 1: partial safe mode (transfer of *.m files and the job script file), 2: safe mode: keep only the MAT_RUN_$timeid.mat input file and the *m files, 3: full safe mode: keep only the MAT_RUN_$timeid.mat input file
 }

 if ($remotehost == 'loki') {
    $safemode = 1;// 0: unsafe mode, 1: partial safe mode (transfer of *.m files and the job script file), 2: safe mode: keep only the MAT_RUN_$timeid.mat input file and the *m files, 3: full safe mode: keep only the MAT_RUN_$timeid.mat input file
 }

 if ($remotehost == 'lohan14.gat.com') {
    $safemode = 1;// 0: unsafe mode, 1: partial safe mode (transfer of *.m files and the job script file), 2: safe mode: keep only the MAT_RUN_$timeid.mat input file and the *m files, 3: full safe mode: keep only the MAT_RUN_$timeid.mat input file
 }


  return $safemode;

}

function mailadresslist($remoteuser) {

  $mailadress[0] = 'ypeysson@gmail.com';//sender

  if ($remoteuser == 'JD211098') {
        $mailadress[1] = 'joan.decker@gmail.com';//destination
  } else {
        $mailadress[1] = 'ypeysson@free.fr';//destination
  }
 
  return $mailadress;

}


function keyslist() {

  $keys = array('remotehost','remotecmd','debugmode','remoteuser','remotedatapath',
    'batch_dir','timeid','id','pbssearch','condorsearch','xgridsearch','directsearch',
    'sgesearch','nodes','ppn','memory','walltime','ncpus','matlabroot',
    'funcopy','remtimout','rempause','wait','script','savefcn','loadfcn','testvar','matlabfun',
    'matlabpath','remotematfnc','condorscript','condorconfig','condorpath','xgridscript',
    'sgescript','hostname','usermail','nbatchscriptparams','shell','password',
    'lukeroot','whoami','git','cd');
  
  return $keys;

}

?>

 



