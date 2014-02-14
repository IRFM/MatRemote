function remote = testremoteprofile_jd(remote,bridge_enforce,display_mode)
    %
    if nargin < 3,
        display_mode = false;
    end
    if nargin < 2,
        bridge_enforce = false;
    end
    %
    if isempty(remote.host), %local calculation
        return
    end
    %
    remotecmd = 'echo test ok';
    %
    % test bridged connection
    %
    flag_bridge = false;
    %
    if ~isempty(remote.bridge) && ~isempty(remote.bridge.url.host),% test bridge connection
        %
        if display_mode,
            disp(' ');
            disp(['Testing bridge connection to ',remote.host,' via  ',remote.bridge.url.host,' ... ']);
        end
        %
        % TODO
        %
        res = 0;% temporary
        txt = 'test ok';% temporary
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
        flag_ssh = true;
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
