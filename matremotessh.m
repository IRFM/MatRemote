function [txt,res] = matremotessh(remote,remotecmd,ssh_opts)
%
if nargin < 3,
    ssh_opts = '';
end
%
[remote] = bridge_params(remote);
%
[res,txt] = unix([remote.bridge.ssh.sshcmd,' "',remote.ssh.sshcmd,' ''',remotecmd,'''"',ssh_opts]);%execute the remote command by ssh
%
if res == 0 && any(strfind(txt,'Rejected')),
    res = 1;
end
