% 
% /////////////////////////////////////////
%
% Software name : MatRemote, part of LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
    if ~isempty(remote.bridge) && isfield(remote.bridge.ssh,'remotepassword') && ~isempty(remote.bridge.ssh.remotepassword) && isfield(remote,'hosts') && ~isempty(remote.hosts) && length(remote.hosts) > 1
        %
        remote.ssh.sshcmd = strrep(remote.ssh.sshcmd,[remote.remoteuser,'@',remote.hosts{1}],[remote.remoteuser,'@',remote.hosts{2}]);% choose the external IP since connected from outside
        remote.host = remote.hosts{2};% choose the external IP since connected from outside
        % 
    end
    %
    if ~isempty(remote.bridge) && isfield(remote.bridge.ssh,'remotepassword') && ~isempty(remote.bridge.ssh.remotepassword)
        remote.ssh.sshcmd = ['sshpass -p ''',remote.bridge.ssh.remotepassword,''' ',remote.ssh.sshcmd];%remote sshpass (must be installed and accessible)
        remote.ssh.sshcmd = strrep(remote.ssh.sshcmd,'yes','no');%BatchMode=no
        %
    end
    %
    if ~isempty(remote.bridge) && isfield(remote.bridge.ssh,'password') && ~isempty(remote.bridge.ssh.password)
        remote.bridge.ssh.sshcmd = ['sshpass -p ''',remote.bridge.ssh.password,''' ',remote.bridge.ssh.sshcmd];%remote sshpass (must be installed and accessible)
        remote.bridge.ssh.sshcmd = strrep(remote.bridge.ssh.sshcmd,'yes','no');%BatchMode=no
        %
    end
    %
    if ~isempty(remote.bridge) 
        [res,txt] = unix([remote.bridge.ssh.sshcmd,' "',remote.ssh.sshcmd,' ''',remotecmd,'''"',ssh_opts]);%execute the remote command by ssh
    else
        [res,txt] = unix([remote.ssh.sshcmd,' ''',remotecmd,'''',ssh_opts]);
    end
    if res == 0 && any(strfind(txt,'Rejected')),
        res = 1;
    end
else
    %
    txt = '';
    res = 1;
    %
end
