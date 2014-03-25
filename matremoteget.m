function [res,txt] = matremoteget(remote,job)
%
% download batch dir from the remote computer (through the bridge)
%
if ~isempty(remote.host),
    %
    if remote.link_mode == 2,
        %
        if job.xgridsearch,%Files must be first transfered from xgrid temp directory to the job folder on the remote computer before being transfered back to the local computer
            %
            [res,txt] = scp_over_php(remote,job,[job.batch_dir,'output_file']);
            %
            if res ~= 0,
                return
            end            
            %
            %
            [res,txt] = scp_over_php(remote,job,[job.batch_dir,'error_file']);
            %
            if res ~= 0,
                return
            end
        end
        %
        [res,txt] = scp_over_php(remote,job,job.load_id);
        %
        [res,txt] = download2client(remote,job);
        %
    elseif remote.link_mode == 1,
        %
        [remote] = bridge_params(remote);
        %
        if job.xgridsearch,%Files must be first transfered from xgrid temp directory to the job folder on the remote computer before being transfered back to the local computer
            %
            remotecmd = ['scp -r ',remote.remoteuser,'@',remote.host,':',job.remotedatapath,job.batch_dir,'output_file ',remote.bridge.ssh.temppath,'/',job.batch_dir,'output_file'];
            [res,txt] = unix(['ssh ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' "',remotecmd,'"']);
            %
            if res ~= 0,
                return
            end            
            %
            remotecmd = ['scp -r ',remote.remoteuser,'@',remote.host,':',job.remotedatapath,job.batch_dir,'error_file ',remote.bridge.ssh.temppath,'/',job.batch_dir,'error_file'];
            [res,txt] = unix(['ssh ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' "',remotecmd,'"']);
            %
            if res ~= 0,
                return
            end           
        end
        %
        remotecmd = ['scp -r ',remote.remoteuser,'@',remote. host,':',job.remotedatapath,job.load_id,' ',remote.bridge.ssh.temppath,'/',job.load_id];%download from remote to bridge
        [res,txt] = unix(['ssh ',remote.bridge.ssh.username,'@',remote.bridge.ssh.host,' "',remotecmd,'"']);
        %
        [res,txt] = download2client(remote,job);        
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
            remotecmd = [remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password,remoteset_jobid{6},job.id,' -out ',job.remotedatapath,job.batch_dir];
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
function [res,txt] = scp_over_php(remote,job,filename)
    %
    [txt_url,res_url] = matremoteurl(remote,job,'',filename);
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
