% 
% /////////////////////////////////////////
%
% Software name : MatRemote, part of LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [txt_url,res_url] = matremoteurl(remote,job,remotecmd,filename)
%
if strfind(remote.host,':')
	remote.host = remote.host(1:strfind(remote.host,':')-1);%no specific port for url 
end
%
if isempty(remotecmd) && ~isempty(filename)
    php_post{1} = 'filename';%php variable
    php_post{2} = filename;
    %
    php_post = phppostremotejob(remote,job,php_post);%add extra data for php filtering
    %
    [txt_url,res_url] = bridgeurl(remote,php_post,'scp_getfile.php');
end
%
if ~isempty(remotecmd) && isempty(filename)
    php_post{1} = 'remotecmd';%php variable
    php_post{2} = remotecmd;
    %
    php_post = phppostremotejob(remote,job,php_post);%add extra data for php filtering
    %
    [txt_url,res_url] = bridgeurl(remote,php_post,'ssh.php');
end
%
if ~isempty(strfind(txt_url,'Non standard unix command in MatRemote')),
    error('Non standard unix command in matremoteurl.m. An automatic message has been sent to the administrator. Job aborted...');
end