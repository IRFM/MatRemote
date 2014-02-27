function remote = testremoteprofile_jd(remote,bridge_enforce,display_mode)
    %
    if nargin < 3,
        display_mode = false;
    end
    if nargin < 2 || isempty(remote.bridge_enforce),
        bridge_enforce = false;
    else
        bridge_enforce = remote.bridge_enforce;
    end
    %
    if isempty(remote.host), %local calculation
        xgridsearch = iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'xgrid')));
        if xgridsearch, 
            if ~isempty(getenv('XGRID_PWD')),
                remote.password = {getenv('XGRID_PWD')};
            else
                error('XGRID password not set up.')
            end
        end
        return
    end
    %
    remotecmd = 'echo test ok';
    %
    % test bridged connection
    %
    if isfield(remote,'bridge_enforce') && remote.bridge_enforce,
        flag_bridge_enforce = 1;
    elseif isfield(remote,'bridge_enforce') && ~remote.bridge_enforce,
        flag_bridge_enforce = 0;
    else
        flag_bridge_enforce = 1;
    end
    flag_bridge = false;
    %
    if ~isempty(remote.bridge) && ~isempty(remote.bridge.url.host) && flag_bridge_enforce,% test bridge connection
        %
        if display_mode,
            disp(' ');
            disp(['Testing bridge connection to ',remote.host,' via  ',remote.bridge.url.host,' ... ']);
        end
        %
        [txt_url,res_url] = matremoteurl(remote,'','ls','');
        %
        if res_url,
            res = 0;
            txt = 'test ok';
        else
            res = 1;
            txt = txt_url;
        end
        %
        if res ~= 0,% bridge connection failed,
            msg = ['failed with following message : ',txt];
        else
            msg = ['completed with following result : ',txt];
            flag_bridge = true;
        end
        if display_mode,
            disp(['   ... ',msg]);
        end
    end
    % 
    % test connection with key-pair
    %
    flag_ssh = false;
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
                remote.password = {getenv('XGRID_PWD')};
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
    %
    if flag_ssh,
        if ~flag_bridge,
            msg = 'connection in ssh key pair mode OK';
            remote.bridge = [];
        elseif bridge_enforce,
            msg = 'connection in bridge mode enforced';
        else
            msg = 'connection in ssh key pair mode enforced';
            remote.bridge = [];
        end
    elseif flag_bridge,
        msg = 'connection in bridge mode OK';
    else
        msg = 'no valid connection mode';
        remote = [];
    end
    %
    if display_mode,
        disp(' ');
        disp(['test output : ',msg]);
    end
    %
end
