function [remote] = bridge_params(remote)
%
if ~isempty(remote.bridge)
    %
    if exist('private_bridge_parameters.m','file')
        %
        private_bridge_parameters % load parameters of the bridge. Private file. Must be put in the path of MatRemote
        %
        for ii = 1:length(bridge)
            %
            if isfield(remote.bridge,'url') && isfield(remote.bridge.url,'host') && isfield(remote.bridge,'ftp') && isfield(remote.bridge.ftp,'host')
                %
                if isfield(bridge(ii),'url') && isfield(bridge(ii).url,'host') && strcmp(remote.bridge.url.host,bridge(ii).url.host)
                    %
                    remote.bridge.url.path = bridge(ii).url.path;
                    %
                    if isfield(bridge(ii),'ftp') && isfield(bridge(ii).ftp,'host') && strcmp(remote.bridge.ftp.host,bridge(ii).ftp.host)
                        %
                        remote.bridge.ftp.username = bridge(ii).ftp.username;
                        remote.bridge.ftp.password = bridge(ii).ftp.password;
                        %
                        break
                        %
                    end
                    %
                end
                %
            end
            %
            if isfield(remote.bridge,'ssh') && isfield(remote.bridge.ssh,'host')
                %
                if isfield(bridge(ii),'ssh') && isfield(bridge(ii).ssh,'host') && strcmp(remote.bridge.ssh.host,bridge(ii).ssh.host)
                    %
                    remote.bridge.ssh.username = bridge(ii).ssh.username;
                    remote.bridge.ssh.temppath = bridge(ii).ssh.temppath;
                    remote.bridge.ssh.keyfile = bridge(ii).ssh.keyfile;
                    %
                    remote.bridge.ssh = conc_struct_jd(remote.bridge.ssh,sshsetup_jd(remote.bridge.ssh.host,remote.bridge.ssh.username,remote.bridge.ssh.keyfile,remote.sshopts,remote.timeout,remote.password));% setup bridge specific ssh and scp commands
                    %
                    break
                    %
                end
                %
            end
            %
            if isfield(remote.bridge,'url') && ~isfield(remote.bridge.url,'path')
                %
                error('Bridge URL is not set-up correctly');
                %
            end
            %
            if isfield(remote.bridge,'ftp') && ~isfield(remote.bridge.ftp,'username') && ~isfield(remote.bridge.ftp,'password')
                %
                error('Bridge FTP is not set-up correctly');
                %
            end
            %
        end
    else
        %
        error('File with private bridge parameters is not found.');
        %
    end     
end
