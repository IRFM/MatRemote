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
function [res,txt] = upload2bridge(remote,job)
%
res = 0;
txt = '';
%
[remote] = bridge_params(remote);
%
if remote.link_mode == 2,
    %
    flag_curl_ftp = testcurl('ftp');
    %
    if flag_curl_ftp,%ftp over curl method
        %
        filelist = dir(job.batch_dir(1:end-1));
        for ii = 1:length(filelist),
            if ~strcmp(filelist(ii).name,'.') && ~strcmp(filelist(ii).name,'..')
                if ~isdir([job.batch_dir,filelist(ii).name])
                    cmd = ['curl --cacert ',job.batch_dir,filelist(ii).name,' --ftp-create-dirs -T ',job.batch_dir,filelist(ii).name,' -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' ftp://',remote.bridge.ftp.host,'/ftp/transfer/',job.batch_dir,filelist(ii).name,' -Q ''SITE UMASK 000'''];%for transfering files
                else
                    cmd = ['curl --cacert ',job.batch_dir,filelist(ii).name,'/. --ftp-create-dirs -T ',job.batch_dir,filelist(ii).name,'/. -u ',remote.bridge.ftp.username,':',remote.bridge.ftp.password,' ftp://',remote.bridge.ftp.host,'/ftp/transfer/',job.batch_dir,filelist(ii).name,'/',' -Q ''SITE UMASK 000'''];%for creating an empty directory
                end
                %
                [res,txt] = unix(cmd);
            end
        end
    end
    %
    if res~= 0, 
       disp(['WARNING: ',txt,' -> upload2bridge is done by Matlab FTP, and not FTP over curl. Check the curl version called by Matlab: curl --version and compare it to the same command in a terminal. The library may have to be changed in Matlab.'])
    end
    %
    if ~flag_curl_ftp || res~= 0,%ftp embedded in matlab (not necessarily operational)
        %
        res = 0;
        txt = '';
        %
        try
            %
            f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
            mput(f,job.batch_dir(1:end-1));%Transfer data from the local batch dir to the bridge batch dir
            close(f);
            %
        catch err
            %
            res = 1;
            txt = err.message;
        end
    end
    %
elseif remote.link_mode == 1,
    %
    if isfield(remote.bridge.ssh,'password') && ~isempty(remote.bridge.ssh.password)
        remote.bridge.ssh.sshcmd = ['sshpass -p ''',remote.bridge.ssh.password,''' ',remote.bridge.ssh.sshcmd];%remote sshpass (must be installed and accessible)
        remote.bridge.ssh.sshcmd = strrep(remote.bridge.ssh.sshcmd,'yes','no');%BatchMode=no
        %
        remote.bridge.ssh.scpcmd{1} = ['sshpass -p ''',remote.bridge.ssh.password,''' ',remote.bridge.ssh.scpcmd{1}];%remote sshpass (must be installed and accessible)
        remote.bridge.ssh.scpcmd{1} = strrep(remote.bridge.ssh.scpcmd{1},'yes','no');%BatchMode=no
    end
    %
    [res,txt] = scp2remote_yp(remote.bridge.ssh.sshcmd,remote.bridge.ssh.scpcmd,job.save_id,job.localdatapath,remote.bridge.ssh.temppath);%transfer data from the local batch dir to the remote batch dir
    %
end