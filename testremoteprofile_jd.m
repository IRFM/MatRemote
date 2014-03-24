function remote = testremoteprofile_jd(remote,bridge_enforce,display_mode)
    %
    % This function tests connections for the remote profile 'remote'.
    %  - If test not OK, return empty profile
    %  - If ssh key pair selected, return empty remote.bridge
    %
    % If bridge_enforce = NaN : (default) use value from remote.bridge_enforce
    % If bridge_enforce = []  : tests both modes and give priority to ssh key pair
    % If bridge_enforce = 0   : tests only ssh key pair,
    % If bridge_enforce = 1   : tests only bridge mode
    %
    if nargin < 3,
        display_mode = false;
    end
    %
    if nargin < 2,
        bridge_enforce = NaN;
    end
    if isnan(bridge_enforce),
        bridge_enforce = remote.bridge_enforce;
    end
    %
    if isempty(remote.host), %local calculation
        %
        if any(bridge_enforce == 1),
            remote = [];% no bridge mode without host
            %
            return
        end
        %
        remote.bridge = [];
        %
        xgridsearch = iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'xgrid')));
        if xgridsearch, 
            if ~isempty(getenv('XGRID_PWD')),
                remote.password = getenv('XGRID_PWD');
            else
                disp('WARNING: XGRID password not set up. Create an environment variable ''XGRID_PWD''.')
                remote = [];
            end
        end
        %
        return
    end
    %
    remotecmd = 'echo test ok';
    %
    % test bridged connection
    %
    flag_bridge = false;
    %
    if ~isempty(remote.bridge) && ~any(bridge_enforce == 0),% test bridge connection (url or ssh)
        %
        if isfield(remote.bridge,'url') && isfield(remote.bridge.url,'host') && ~isempty(remote.bridge.url.host)  && isfield(remote.bridge,'ftp') && isfield(remote.bridge.ftp,'host') && ~isempty(remote.bridge.ftp.host),% test bridge connection via url
            %
            if display_mode,
                disp(' ');
                disp(['Testing bridge connection (url) to ',remote.host,' via ',remote.bridge.url.host,' ... ']);
            end
            %
            [txt_url,res_url] = matremoteurl(remote,'','ls','');
            %
            if res_url,
                res = 0;
            else
                res = 1;
                txt = txt_url;
            end
        end
        %
        if isfield(remote.bridge,'ssh') && isfield(remote.bridge.ssh,'host') && ~isempty(remote.bridge.ssh.host),
            %
            if display_mode,
                disp(' ');
                disp(['Testing bridge connection (ssh) to ',remote.host,' via ',remote.bridge.ssh.host,' ... ']);
            end
            %
            [txt,res] = matremotessh(remote,'ls');
            %

        end
        %
        if ~res,
            txt = 'test ok';
        end
        %
        if res ~= 0,% bridge connection failed,
            msg = ['failed with following message : ',txt];
        else
            msg = ['completed with following result : ',txt];
            flag_bridge = true;
        end
        %
        if display_mode,
            disp(['   ... ',msg]);
        end
        %                    
    end
    % 
    % test connection with key-pair
    %
    flag_ssh = false;
    %
    if ~any(bridge_enforce == 1),% test key-pair connection
        %
        if display_mode,
            disp(' ');
            disp(['Testing ssh key pair connection to ',remote.remoteuser,'@',remote.host,' ... ']);
        end
        %
        xgridsearch = iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'xgrid')));
        %
        if ~xgridsearch || ~isempty(getenv('XGRID_PWD')),
            %
            remote.sshopts = '-o ConnectTimeout=10 -o BatchMode=yes';
            %
            [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh   
            %
            if res ~= 0,
                %
                if any(strfind(txt,'Connection timed out')),
                    msg = 'failed : connection timed out (10s)';
                elseif any(strfind(txt,'Permission denied')) || any(strfind(txt,'Host key verification failed')),
                    msg = 'failed : ssh key pairing not set up or not working';
                else
                    msg = ['failed with following message : ',txt];            
                end
                %
            else
                msg = ['completed with following result : ',txt];
                %
                if xgridsearch,
                    remote.password = getenv('XGRID_PWD');
                end
                %
                flag_ssh = true;
            end
        elseif xgridsearch, 
            msg = 'XGRID password not set up'; 
        end
        if display_mode,
            disp(['   ... ',msg]);
        end
    end
    %
    if flag_ssh,
        if ~flag_bridge,
            msg = 'connection in ssh key pair mode OK';
        else
            msg = 'connection in ssh key pair mode enforced';
        end
        remote.bridge = [];
    elseif flag_bridge,
        msg = 'connection in bridge mode OK';
    else
        msg = 'no valid connection mode';
        remote = [];
    end
    %
    if display_mode,
        disp(['test output : ',msg]);
        disp(' ');
    end
    %
end
