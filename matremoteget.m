function [res,txt] = matremoteget(job,remote,debugmode)
%
% download batch dir from the remote computer (through the bridge)
%
if nargin < 3, 
    debugmode = '0';
end
%
if ~isempty(remote.host),
    %
    if isfield(remote.bridge,'ftp') && ~isempty(remote.bridge.ftp.host) > 0,
        %
        if job.xgridsearch,%Files must be first transfered from xgrid temp directory to the job folder on the remote computer before being transfered back to the local computer
            %
            [res,txt] = scp_over_php(job,remote,[job.batch_dir,'output_file'],debugmode);
            %
            if res ~= 0,
                return
            end            
            %
            %
            [res,txt] = scp_over_php(job,remote,[job.batch_dir,'error_file'],debugmode);
            %
            if res ~= 0,
                return
            end
        end
        %
        [res,txt] = scp_over_php(job,remote,job.load_id,debugmode);
        %
        f = ftp(remote.bridge.ftp.host,remote.bridge.ftp.username,remote.bridge.ftp.password);%ftp access to the bridge
        mget(f,job.load_id);%Transfer ouput data from the bridge batch dir to the local batch dir
        close(f);
        %
    elseif isfield(remote,'remote'),
        %
        % TODO    
        %
    else
        %
        if job.xgridsearch,%Files must be first transfered from xgrid temp directory to the job folder on the remote computer before being transfered back to the local computer
            %
            [res,txt] = unix(['scp -r ',remote.remoteuser,'@',remote.host,':',job.remotedatapath,job.batch_dir,'output_file ',job.localdatapath,job.batch_dir,'output_file']);
            %
            if res ~= 0,
                return
            end            
            %
            [res,txt] = unix(['scp -r ',remote.remoteuser,'@',remote.host,':',job.remotedatapath,job.batch_dir,'error_file ',job.localdatapath,job.batch_dir,'error_file']);
            %
            if res ~= 0,
                return
            end
        end
        %
        [res,txt] = unix(['scp -r ',remote.remoteuser,'@',remote. host,':',job.remotedatapath,job.load_id,' ',job.localdatapath,job.load_id]);
        %
    end
elseif ~strcmp(job.localdatapath,job.remotedatapath),
    %
    if job.xgridsearch,%data must be first transfered from xgrid temp folder to the job folder
        %
        if ~isfield(remote,'password') || isempty(remote.password),
            remotecmd = [remoteset_jobid{1},job.hostname,remoteset_jobid{6},job.id,' -out ',job.remotedatapath,job.batch_dir];
        else
            remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password{1},remoteset_jobid{6},job.id,' -out ',job.remotedatapath,job.batch_dir];
        end
        %
        [res,txt] = unix(remotecmd);
        %           
        if res ~= 0,
            return
        end            
        %
        [res,txt] = unix(['cp -r ',job.remotedatapath,job.batch_dir,'output_file ',job.localdatapath,job.batch_dir,'output_file']);
        %
        if res ~= 0,
            return
        end            
        %
        [res,txt] = unix(['cp -r ',job.remotedatapath,job.batch_dir,'error_file ',job.localdatapath,job.batch_dir,'error_file']);
        %
        if res ~= 0,
            return
        end
        %
    end
    %
    [res,txt] = unix(['cp -r ',job.remotedatapath,job.load_id,' ',job.localdatapath,job.load_id]);        
    %
else
    res = 0;
    txt = '';
end
end
%
function [res,txt] = scp_over_php(job,remote,filename,debugmode)
    %
    [txt_url,res_url] = matremoteurl(remote,job,'',filename,debugmode);
    %
    ie = strfind(txt_url,'scp2php_error:');%the 'scp2php_error:' separates the scp output from the error in scp.php
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
end
