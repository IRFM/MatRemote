function remote = add_cea_users(remote,zone)
%
% add external users to CEA PARTENAIRES or INTRA zones
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
if strcmp(zone,'INTRA')
    %
    root_folder = '/Home/';
    %
elseif strcmp(zone,'PARTENAIRES')
    %
    root_folder = '/home/';
    %
else
    %
    disp(['This CEA zone : ',zone,' is unknown.'])
    return;
    %
end
%
%Jean-François Artaud, Marc Goniche, Jorge Morales, Tullio Barbui, Krzysiek Krol, Riccardo Saura, Patrick Maget, Samuele Mazzi, Pierre Manas, Théo Fonghetti
%
users = ['JA132999';'MG270985';'JM240179';'TB263881';'KK019865';'RS272879';'PM156629';'SM253778';'PM258588';'TF267414'];
%
for ii = 1:length(users)
    %
    % pbs pro
    %
    remote.pbs.(users(ii,:)) = remote.pbs.YP105119;
    remote.pbs.(users(ii,:)).remoteuser = users(ii,:);
    remote.pbs.(users(ii,:)).remotedatapath = [root_folder,users(ii,:),'/tmp/'];
    %
    if strcmp(zone,'PARTENAIRES')
        %
        remote.pbs.(users(ii,:)).bridge.ssh.host = '';
        remote.pbs.(users(ii,:)).bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
        %
    end
    %
    % direct
    %
    remote.direct.(users(ii,:)) = remote.direct.YP105119;
    remote.direct.(users(ii,:)).remoteuser = users(ii,:);
    remote.direct.(users(ii,:)).remotedatapath = [root_folder,users(ii,:),'/tmp/'];
    %
    if strcmp(zone,'PARTENAIRES')
        %
        remote.direct.(users(ii,:)).bridge.ssh.host = '';
        remote.direct.(users(ii,:)).bridge.ssh.remotepassword = '';%set password for the remote machine in startup.m or in session startup script
        %
    end
    %
end
%