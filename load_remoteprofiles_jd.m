function [remoteprofiles,profilestr] = list_remoteprofiles_jd(profilename,select,duplicate)
%
% This function loads remote profiles, identifies local cluster if it
% exists, and creates a user-friendly list including scheduler type
%
% A profile will be selected from the list is select == true
%
%   - INPUTS : 
%       - profilename : (char array) name of profile within remote cluster description (ex : joan, yves, ...)
%                       if the name is not specified or does not exist, default profile name is selected.
%       - select : (boolean) user-input selection from list of profiles
%       - duplicate : (boolean) duplicate local profile with and without empty host, to test both ways
%
%   - OUTPUTS :
%       - newremoteprofiles : (struct array) list of remote profile, or selection if select == true
%       - profilestr : (cell array) corresponding user-friendly title
%
if nargin < 3 || ~isscalar(duplicate) || (~islogical(duplicate) && ~isnumeric(duplicate)),
    duplicate = false;
end
if nargin < 2 || ~isscalar(select) || (~islogical(select) && ~isnumeric(select)),
    select = false;
end
if nargin < 1 || ~ischar(profilename),
    profilename = '';
end
%
% List all files from Matremote/Profiles directory of the form remote_[...].m that contain profiles
%
MatRemoteDir = fileparts(which(mfilename));
%
RemoteProfDirContents = dir([MatRemoteDir,filesep,'Profiles/remote_*m']);
nremotefiles = length(RemoteProfDirContents);
RemoteFileNames = cell(1,nremotefiles);
for ifile = 1:nremotefiles,
    RemoteFileNames{ifile} = RemoteProfDirContents(ifile).name(1:end-2);
end
%
% Load profiles with profilename and default scheduler
%
% - Identify local cluster or test connection with key-pair -
%
RemoteFileTest = false(1,nremotefiles);
LocalFileTest = false(1,nremotefiles);
%
[s,lochostname] = system('hostname -f');% local hostname
if s ~= 0,
    lochostname = getenv('hostname');%For remote computing (xgrid)
    if isempty(lhostname),
        error('local hostname could not be retrieved either from ''hostname -f'' or ''getenv(''hostname'')''');
    end
end
%
disp(' ');
disp('-------------------------------------------------------------------')
disp('                     TEST REMOTE CONNECTIONS                       ');
disp('-------------------------------------------------------------------')
%
for ifile = 1:nremotefiles,
    %
    remote = feval(RemoteFileNames{ifile},'',profilename);
    hostname = remote.hostname;
    %
    disp(' ');
    if any(strfind(lochostname,hostname)),% local cluster,
        %
        disp(['Local cluster identified : ',remote.host]);
        LocalFileTest(ifile) = true;
        disp(' ');
        %
    end
    % 
    % test connection with key-pair
    %
    disp(['Testing connection to ',remote.remoteuser,'@',remote.host,' ... ']);
    %
    remotecmd = 'echo test ok';
    remote.sshopts = '-o ConnectTimeout=10 -o BatchMode=yes';
    %
    [res,txt] = matremotecmd(remote,remotecmd);
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
        RemoteFileTest(ifile) = true;
    end        
    disp(['   ... ',msg]);
    %
end
%
% Put local profiles first
%
RemoteFileNames = [RemoteFileNames(LocalFileTest),RemoteFileNames(~LocalFileTest)];
RemoteFileTest = [RemoteFileTest(LocalFileTest),RemoteFileTest(~LocalFileTest)];
LocalFileTest = [LocalFileTest(LocalFileTest),LocalFileTest(~LocalFileTest)];
%
% Select local and remotely working profiles 
%
SelectedProfiles = LocalFileTest | RemoteFileTest;
RemoteFileNames = RemoteFileNames(SelectedProfiles);
LocalFileTest = LocalFileTest(SelectedProfiles);
RemoteFileTest = RemoteFileTest(SelectedProfiles);
%
% Load profiles with profilename including all schedulers
%
remoteprofiles = [];
localprofiletest = [];
remoteprofiletest = [];
%
for irem = 1:length(RemoteFileNames),
    newremoteprofiles = feval(RemoteFileNames{irem},NaN,profilename);
    %
    remoteprofiles = [remoteprofiles,newremoteprofiles];
    localprofiletest = [localprofiletest,repmat(LocalFileTest(irem),[1,length(newremoteprofiles)])];
    remoteprofiletest = [remoteprofiletest,repmat(RemoteFileTest(irem),[1,length(newremoteprofiles)])];
end
nrem = length(remoteprofiles);
%
% Duplicate (if duplicate==true) possible local profile(s);
% Generate user-friendly title
%
profilestr = {};
newremoteprofiles = [];
%
for irem = 1:nrem,
    %
    remote = remoteprofiles(irem);% remote profile selected
    %
    % remote profile host string
    %
    hoststr = remote.host;
    if iscell(hoststr),
        hoststr = hoststr{1};
    end
    %
    % remote profile cmd string
    %
    cmdstr = remoteprofiles(irem).cmd;
    if iscell(cmdstr),
        cmdstr = cmdstr{1};
    end
    cmdstr = cmdstr(1:min([end,find(cmdstr == ' ' | cmdstr == '_',1,'first') - 1]));
    %
    if localprofiletest(irem),% local cluster with empty host field
        %
        local = remote;
        local.host = '';
        newremoteprofiles = [newremoteprofiles,local];
        profilestr = [profilestr,['local batch calculation : ',cmdstr]];
        %
    end
    %
    if remoteprofiletest(irem) && (~localprofiletest(irem) || (localprofiletest(irem) && duplicate)),% remote cluster or local cluster with full host field (if duplicate == true)
        %
        newremoteprofiles = [newremoteprofiles,remote];% put remote profiles last
        profilestr = [profilestr,[hoststr,' : ',cmdstr]];
    end
    %
end
%
% List (& select if select == true) all valid remote (and local) profiles
%
nrem = length(profilestr);
%
disp(' ');
disp('-------------------------------------------------------------------')
disp('                     LOCAL & REMOTE PROFILES                       ');
disp('-------------------------------------------------------------------')
disp(' ');
for irem = 1:nrem,
    disp(['- ',num2str(irem),' : ',profilestr{irem}]);
end
disp(' ');
disp('-------------------------------------------------------------------')
disp(' ');
%
if select,
    irem = input_dke_yp('Select local or remote profile(s)',1,1:nrem);
else
    irem = 1:nrem;
end
%
remoteprofiles = newremoteprofiles(irem);
profilestr = profilestr(irem);
%

