
/////////////////////////////////////////
Software name : MatRemote, part of LUKE
Authors : Yves Savoye-Peysson and Joan Decker
Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
/////////////////////////////////////////

These files must be put in /var/www/html/MatRemote folder of the computer which is used as a url/ftp bridge.

%
% Personal list of bridge parameters. Never commit. 
%
%bridge(1).url.host = '<HTTP(S)://XXX.YYY.ZZZ>';
%bridge(1).url.path = 'PATH';
%bridge(1).ftp.host = 'IP:PORT';
%bridge(1).ftp.username = 'USERNAME';
%bridge(1).ftp.password = 'PASSWORD';
%
%bridge(2).ssh.host = 'IP:PORT';
%bridge(2).ssh.username = 'USERNAME';%'matremote'
%bridge(2).ssh.temppath = 'PATH';
%bridge(2).ssh.keyfile = '';%id_rsa key