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
function [res,txt] = bridge2remote(remote,job)
%
res = 0;
txt = '';
%
if remote.link_mode == 2,
    %
    if strfind(remote.host,':')
        remote.host = remote.host(1:strfind(remote.host,':')-1);%no specific port for url 
    end
    %
    php_post = phppostremotejob(remote,job);%add extra data for php filtering
    %
    [txt_url,res_url] = bridgeurl(remote,php_post,'scp_putdir.php');
    %
    if ~isempty(strfind(txt_url,'Non standard script file command in MatRemote')),
        error('Non standard script file command in MatRemote. An automatic message has been  send to the administrator. Job aborted...');
    end
    %
    ie = strfind(txt_url,'scp2php_error:');%the 'scp2php_error:' separates the scp output from the error in scp.php
    error_txt = txt_url(ie+15:end);
    %
    if isempty(error_txt),
        res1 = 0;%force standard unix error.
        txt1 = strtrim(txt_url(1:ie-1));
    else
        res1 = 1;%force standard unix error.
        txt1 = error_txt;
    end
    %
    remotecmd = ['chmod -R 777 ',job.remotedatapath,job.save_id];%because all files in the bridge have low level rights
    %
    [txt_url,res_url] = matremoteurl(remote,job,remotecmd,'');
    %
    ie = strfind(txt_url,'ssh2php_error:');%the 'ssh2php_error:' separates the ssh output from the error in ssh.php
    error_txt = txt_url(ie+15:end);
    %
    if isempty(error_txt),
        res2 = 0;%force standard unix error.
        txt2 = strtrim(txt_url(1:ie-1));
    else
        %
        res2 = 1;%force standard unix error.
        %
        txt2 = error_txt;     
    end
    %
    txt = strcat(txt1,';',txt2);
    %
    res = res1*res2;
    %
elseif remote.link_mode == 1,
    %
    [remote] = bridge_params(remote);
    %
    remotecmd = [remote.ssh.scpcmd{1},' ',remote.bridge.ssh.temppath,'/',job.save_id,' ',remote.ssh.scpcmd{2},':',job.remotedatapath];
    %
    if isfield(remote.bridge.ssh,'remotepassword') && ~isempty(remote.bridge.ssh.remotepassword)
        remotecmd = ['sshpass -p ''',remote.bridge.ssh.remotepassword,''' ',remotecmd];%remote sshpass (must be installed and accessible)
        remotecmd = strrep(remotecmd,'yes','no');%BatchMode=no
    end
    %
    if isfield(remote.bridge.ssh,'password') && ~isempty(remote.bridge.ssh.password)
        remote.bridge.ssh.sshcmd = ['sshpass -p ''',remote.bridge.ssh.password,''' ',remote.bridge.ssh.sshcmd];%remote sshpass (must be installed and accessible)
        remote.bridge.ssh.sshcmd = strrep(remote.bridge.ssh.sshcmd,'yes','no');%BatchMode=no
    end
    %    
    [res1,txt1] = unix([remote.bridge.ssh.sshcmd,' "',remotecmd,'"']);
    %
    remotecmd = ['chmod -R 777 ',job.remotedatapath,job.save_id];%because all files in the bridge have low level rights
    %
    [txt2,res2] = matremotessh(remote,remotecmd);  
    %
    txt = strcat(txt1,';',txt2);
    %
    res = res1*res2;
end