function [res,txt] = matremotecmd(remote,remotecmd,debugmode)
%
if nargin < 3, 
    debugmode = '0';
end
%
if ~isempty(remote.host),
    %
    if isfield(remote.bridge,'url') && ~isempty(remote.bridge.url.host) > 0,
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
            %
            if strfind(remotecmd,'xgrid')
                if strfind(error_txt,'ulimit:'),%wrong error
                    res = 0;%force standard unix error.
                else
                    res = 1;%force standard unix error.
                end          
            else
                res = 1;%force standard unix error.
            end
            %
            txt = error_txt;     
        end
        %
    elseif isfield(remote,'remote'),
        %
        % TODO    
        %
    else
        %
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh 
        %
    end
else
    %
    [res,txt] = unix(remotecmd);%execute the local command
    %
    if ~res && (strcmp(remotecmd(1:6),'export') || strcmp(remotecmd(1:6),'setenv')),%PID identification
        i0 = strfind(remotecmd,'remotebatchdir=');
        i1 = strfind(remotecmd,';');
        remotebatchdir = remotecmd(23:i1(1)-1);
        pidsearch = {};
        tstart = tic;
        minTime = 10;
        while isempty(strfind(pidsearch,'pid')),
            pidsearch = ls(remotebatchdir);
            if min(toc(tstart),minTime) == minTime,error('Error in matremotecmd.m: Process ID file not found');end
        end
        pidfile = ls([remotebatchdir,'pid_*']);
        txt = [remote.get_jobid{1},pidfile(length(remotebatchdir)+5:end-5)];
        unix(['rm ',pidfile]);
    end
    %
end   
%
