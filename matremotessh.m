function [txt,res] = matremotessh(remote,remotecmd,ssh_opts)
%
if nargin < 3,
    ssh_opts = '';
end
%
if exist('private_bridge_parameters.m','file')
    %
    [remote] = bridge_params(remote);
    %
    if isfield(remote.bridge.ssh,'remotepassword') && ~isempty(remote.bridge.ssh.remotepassword)
        remote.ssh.sshcmd = ['sshpass -p ''',remote.bridge.ssh.remotepassword,''' ',remote.ssh.sshcmd];%remote sshpass (must be installed and accessible)
        remote.ssh.sshcmd = strrep(remote.ssh.sshcmd,'yes','no');%BatchMode=no
    end
    %
    if isfield(remote.bridge.ssh,'password') && ~isempty(remote.bridge.ssh.password)
        remote.bridge.ssh.sshcmd = ['sshpass -p ''',remote.bridge.ssh.password,''' ',remote.bridge.ssh.sshcmd];%remote sshpass (must be installed and accessible)
        remote.bridge.ssh.sshcmd = strrep(remote.bridge.ssh.sshcmd,'yes','no');%BatchMode=no
    end
    %
    [res,txt] = unix([remote.bridge.ssh.sshcmd,' "',remote.ssh.sshcmd,' ''',remotecmd,'''"',ssh_opts]);%execute the remote command by ssh
    %
    if res == 0 && any(strfind(txt,'Rejected')),
        res = 1;
    end
else
    %
    txt = '';
    res = 1;
    %
end
