function [res,txt] = matremoteclean(job,remote,remotecmd,debugmode)
%
if nargin < 4, 
    debugmode = '0';
end
%
if isfield(remote.bridge,'ftp') && ~isempty(remote.bridge.ftp.host) > 0,
    %
    f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
    listfiles = dir(f,job.batch_dir(1:end-1));%list all files in batch dir of the bridge
    for ilf = 1:length(listfiles),
    	delete(f,[job.batch_dir,listfiles(ilf).name]);%delete all files in batch dir of the bridge
    end
    if isempty(listfiles),
        rmdir(f,job.batch_dir(1:end-1));%delete batch dir of the bridge
    end
    close(f);
    %
    [txt_url,res_url] = matremoteurl(remote,'',remotecmd,'',debugmode);
    %
    ie = strfind(txt_url,'ssh2php_error:');%the 'ssh2php_error:' separates the ssh output from the error in ssh.php
    error_txt = txt_url(ie+15:end);
    %
    if isempty(error_txt),
        res = 0;%force standard unix error.
        txt = strtrim(txt_url(1:ie-1));
    else
        res = 1;%force standard unix error.
        txt = error_txt;
    end  
    %
elseif isfield(remote,'remote'),
    %
    % TODO    
    %
else
    %
    if ~isempty(remote.host),
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        [res,txt] = unix(remotecmd);%execute the local command
    else
        res = 0;
        txt = '';
    end
    %
end   
%
