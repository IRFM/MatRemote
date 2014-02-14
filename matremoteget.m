function [res,txt] = matremoteget(job,remote,debugmode)
%
% download batch dir from the remote computer (through the bridge)
%
if nargin < 3, 
    debugmode = '0';
end
%
if isfield(remote.bridge,'ftp') && ~isempty(remote.bridge.ftp.host) > 0,
    %
    if ~ischar(debugmode) && abs(debugmode) >= 1, debugmode = '1';end
    if ~ischar(debugmode) && debugmode == 0, debugmode = '0';end
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
    if ~isempty(remote.host),
        %
        if job.xgridsearch,%Files must be first transfered from xgrid temp directory to the job folder on the remote computer before being transfered back to the local computer
            %
            [res,txt] = unix(['scp -r ',job.remotelogname,'@',remote.host,':',job.remotedatapath,job.batch_dir,'output_file ',job.localdatapath,job.batch_dir,'output_file']);
            %
            if res ~= 0,
                return
            end            
            %
            [res,txt] = unix(['scp -r ',job.remotelogname,'@',remote.host,':',job.remotedatapath,job.batch_dir,'error_file ',job.localdatapath,job.batch_dir,'error_file']);
            %
            if res ~= 0,
                return
            end
        end
        %
        [res,txt] = unix(['scp -r ',job.remotelogname,'@',remote. host,':',job.remotedatapath,job.load_id,' ',job.localdatapath,job.load_id]);
        %
    elseif ~strcmp(job.localdatapath,job.remotedatapath),
        %
        if job.xgridsearch,%data must be first transfered from xgrid temp folder to the job folder
            %
            [res,txt] = unix([remoteset_jobid{1},job.hostname,remote.cmd{2},remote.password{1},remoteset_jobid{6},job.id,' -out ',job.remotedatapath,job.batch_dir]);
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
end
%
function [res,txt] = scp_over_php(job,remote,filename,debugmode)
    %
    php_post{1} = 'remotehost';%php variable
    php_post{2} = remote.host;
    php_post{3} = 'remotedatapath';%php variable
    php_post{4} = job.remotedatapath;
    php_post{5} = 'filename';%php variable
    php_post{6} = filename;
    php_post{7} = 'debugmode';%php variable
    php_post{8} = debugmode;
    %
    [txt_url,res_url] = urlread(['http://',remote.bridge.url.host,'/',remote.bridge.url.path,'/scp_getfile.php'],'post',php_post);%transfer data from the bridge batch dir to the remote batch dir
    txt_url = strtrim(txt_url);
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
