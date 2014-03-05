function [remote] = bridge_params(remote)
%
if ~isempty(remote.bridge) && isfield(remote.bridge,'url') && isfield(remote.bridge.url,'host') && isfield(remote.bridge,'ftp') && isfield(remote.bridge.ftp,'host'),
    %
    if strcmp(remote.bridge.url.host,'tolbachik.hd.free.fr')
        remote.bridge.url.path = '~yvespeysson/MatRemote';
    end
    %
    if strcmp(remote.bridge.ftp.host,'tolbachik.hd.free.fr')
        remote.bridge.ftp.username = 'matremote';
        remote.bridge.ftp.password = 'Rq59G4zzPSzZNC9LFMdTK';
    end
    %
end
%
if ~isfield(remote.bridge.url,'path'),
    error('Bridge URL is not set-up correctly');
end
%
if ~isfield(remote.bridge.ftp,'username') && ~isfield(remote.bridge.ftp,'password'),
    error('Bridge FTP is not set-up correctly');
end