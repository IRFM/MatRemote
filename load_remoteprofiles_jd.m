function [remoteprofiles,profilestr] = load_remoteprofiles_jd(remoteid,scheduler,profilename,test,select,duplicate,display_mode)
    %
    % This function loads remote profiles, identifies local cluster if it
    % exists, and creates a user-friendly list including scheduler type
    %
    % The function can test the connection, and return either all profiles, all
    % valid profiles, profiles selected by user input, or profiles selected by function inputs
    %
    % If the profile selected by remoteid does not exist or test failed, empty remoteprofiles returned
    %
    %   - INPUTS : 
    %       - remoteid : (char array) identification of profile to be selected as remote_(remoteid).m 
    %           o If remoteid == '', load all profiles
    %           o If remoteid == 'local', identify and load local profile
    %       - scheduler : (char array - only if remoteid ~= '') identification of scheduler to be selected. 
    %           o If scheduler == '', load default scheduler
    %           o If scheduler == NaN (default), user input for scheduler
    %       - profilename : (NaN or char array) name of profile within remote cluster description (ex : joan, yves, ...)
    %           o if NaN (default), user input for profile name
    %           o if the name is not specified or does not exist, default profile name is selected.
    %       - test : (boolean) test loaded profiles
    %       - select : (boolean - used only if remoteid == '') if select == true, user-input selection from loaded list of profiles
    %       - duplicate : (boolean - used only if local profile among those selected) duplicate local profile with and without empty host, to test both ways
    %       - display_mode : (boolean) show information in command window 
    %
    %   - OUTPUTS :
    %       - newremoteprofiles : (struct array) list of remote profile, or selection if select == true
    %       - profilestr : (cell or char array) corresponding user-friendly title
    %
    %   - Ex : 
    %       - to load profile from remote_macpro_YVES_PEYSSON.m with scheduler 'xgrid', profile 'yves' and with connection test :
    %           >> remote = load_remoteprofiles_jd('macpro_YVES_PEYSSON','xgrid','yves',true);
    %
    %       - to find all profiles and schedulers with valid connection test, duplicate local profile, and choose among them, for profile 'joan' :
    %           >> remote = load_remoteprofiles_jd('','','joan',true,true,true);
    %
    %       - to load and return all profiles and scheduler with default profilename and without connection test or duplicate local profile, and also load user-friendly description :
    %           >> [remoteprofiles,profilestr] = load_remoteprofiles_jd;
    %
    if nargin < 7 || ~isscalar(display_mode) || (~islogical(display_mode) && ~isnumeric(display_mode)),
        display_mode = true;
    end
    if nargin < 6 || ~isscalar(duplicate) || (~islogical(duplicate) && ~isnumeric(duplicate)),
        duplicate = false;
    end
    if nargin < 5 || ~isscalar(select) || (~islogical(select) && ~isnumeric(select)),
        select = false;
    end
    if nargin < 4 || ~isscalar(test) || (~islogical(test) && ~isnumeric(test)),
        test = false;
    end
    if nargin < 3 
        profilename = NaN;% prompt user for profile name
    end
    if nargin < 2 || ~ischar(scheduler),
        scheduler = NaN;% prompt user for  scheduler
    end
    if nargin < 1 
        remoteid = '';% load all profiles
    end
    %
    if ~ischar(profilename),
        profilename = input_dke_yp('Identify Profile Name (ex : ''joan'',''yves'',...), or leave empty to use default for each remote profile','');
    end
    %
    remoteprofiles = [];
    profilestr = {};
    %
    % List all files from Matremote/Profiles directory of the form remote_[...].m that contain profiles
    %
    MatRemoteDir = fileparts(which(mfilename));
    %
    RemoteProfDirContents = dir([MatRemoteDir,filesep,'Profiles/remote_*.m']);
    nremotefiles = length(RemoteProfDirContents);
    RemoteFileNames = cell(1,nremotefiles);
    for ifile = 1:nremotefiles,
        RemoteFileNames{ifile} = RemoteProfDirContents(ifile).name(1:end-2);
    end
    %
    if ~isempty(remoteid) && ~strcmp(remoteid,'local'),
        %
        % case where profile was specified by function input
        %
        filename = ['remote_',remoteid];
        iselected = strcmp(RemoteFileNames,filename);
        %
        if ~any(iselected),
            disp(['WARNING : file ',filename,'.m not found on the matlab path. Empty remoteprofiles returned']);
            return
        end
        %
        if test && ~testremoteprofile_jd(feval(filename,'',profilename),display_mode),
            disp(['WARNING : connection test failed for ',filename,'.m. Empty remoteprofiles returned']);
            return
        end
        %
    else% other cases
        %
        % Read local hostname
        %
        [s,lochostname] = system('hostname -f');% local hostname
        if s ~= 0,
            lochostname = getenv('hostname');%For remote computing (xgrid)
            if isempty(lhostname),
                error('local hostname could not be retrieved either from ''hostname -f'' or ''getenv(''hostname'')''');
            end
        end
        %
        % Load profiles with profilename and default scheduler, and identify local cluster 
        %
        LocalFileTest = false(1,nremotefiles);
        %
        for ifile = 1:nremotefiles,
            %
            remote = feval(RemoteFileNames{ifile},'',profilename);
            hostname = remote.hostname;
            %
            if any(strfind(lochostname,hostname)),% local cluster,
                %
                if display_mode,
                    disp(' ')
                    disp(['Local cluster identified : ',remote.host]);
                end
                %
                LocalFileTest(ifile) = true;
                %
            end
        end
        %
        if strcmp(remoteid,'local'),% local cluster selected
            %
            if sum(LocalFileTest) == 0,
                disp('WARNING : no local cluster found among remote_*.m files. Empty remoteprofiles returned');
                return
            end
            %
            if sum(LocalFileTest) > 1,
                disp('WARNING : more than one local cluster found among remote_*.m files. First cluster selected.');
                return
            end
            %
            iselected = find(LocalFileTest,1,'first');
            %
        end
    end
    %
    if ~isempty(remoteid),
        %
        % case where profile was specified by function input
        %
        newremoteprofiles = feval(RemoteFileNames{iselected},scheduler,profilename);
        nrem = length(newremoteprofiles);
        %
        profilestr = cell(1,nrem);
        cmdstr = cell(1,nrem);
        %
        for irem = 1:nrem,
            if strcmp(remoteid,'local'),
                newremoteprofiles(irem).host = '';% local cluster
            end
            %
            [profilestr{irem},~,cmdstr{irem}] = getremotestr_jd(newremoteprofiles(irem));
            %
        end
        %
        if nrem > 1,
            %
            disp(' ')
            disp('Please select a scheduler type :');
            for irem = 1:nrem,               
                disp(['- ',num2str(irem),' : ',cmdstr{irem}]);
            end
            irem = input_dke_yp('',1,1:nrem);
        end
        %
        remoteprofiles = newremoteprofiles(irem);
        profilestr = profilestr(irem);
        %
        if display_mode,
            disp(' ')
            disp(['Profile selected : ',profilestr{1}]);
        end
        %
    else% other cases
        %
        RemoteFileTest = true(1,nremotefiles);
        %
        if test,
            %
            % test connections
            %
            if display_mode,
                %
                disp(' ');
                disp('-------------------------------------------------------------------');
                disp('                     TEST REMOTE CONNECTIONS                       ');
                disp('-------------------------------------------------------------------');
                %
            end
            %
            for ifile = 1:nremotefiles,
                RemoteFileTest(ifile) = testremoteprofile_jd(feval(RemoteFileNames{ifile},'',profilename),display_mode);
            end
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
            if localprofiletest(irem),% local cluster with empty host field
                %
                remote = remoteprofiles(irem);% remote profile selected
                remote.host = '';
                newremoteprofiles = [newremoteprofiles,remote];
                profilestr = [profilestr,getremotestr_jd(remote)];
                %
            end
            %
            if remoteprofiletest(irem) && (~localprofiletest(irem) || (localprofiletest(irem) && duplicate)),% remote cluster or local cluster with full host field (if duplicate == true)
                %
                remote = remoteprofiles(irem);% remote profile selected
                newremoteprofiles = [newremoteprofiles,remote];
                profilestr = [profilestr,getremotestr_jd(remote)];
                %
            end
            %
        end
        %
        % List (& select if select == true) all valid remote (and local) profiles
        %
        nrem = length(profilestr);
        %
        if display_mode || select,
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
        end
        %
        if select,
            irem = input_dke_yp('Select local or remote profile(s)',1,1:nrem);
            %
            profilestr = profilestr(irem);
            remoteprofiles = newremoteprofiles(irem);
            %
        end
    end
end
%
function [profilestr,hoststr,cmdstr] = getremotestr_jd(remote)
    %
    % remote profile host string
    %
    hoststr = remote.host;
    if isempty(hoststr),
        hoststr = 'local batch calculation';
    elseif iscell(hoststr),
        hoststr = hoststr{1};
    end
    %
    % remote profile cmd string
    %
    cmdstr = remote.cmd;
    if iscell(cmdstr),
        cmdstr = cmdstr{1};
    end
    cmdstr = cmdstr(1:min([end,find(cmdstr == ' ' | cmdstr == '_',1,'first') - 1]));
    %
    profilestr = [hoststr,' : ',cmdstr];    
end
%
function flag = testremoteprofile_jd(remote,display_mode)
    %
    if nargin < 2,
        display_mode = false;
    end
    % 
    % test connection with key-pair
    %
    if display_mode,
        disp(' ');
        disp(['Testing connection to ',remote.remoteuser,'@',remote.host,' ... ']);
    end
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
        flag = false;
        %
    else
        msg = ['completed with following result : ',txt];
        %
        flag = true;
    end        
    if display_mode,
        disp(['   ... ',msg]);
    end
    %
end
    

