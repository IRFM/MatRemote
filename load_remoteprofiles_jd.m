function [remoteprofiles,profilestr] = load_remoteprofiles_jd(remote,test,inter,scheduler,profilename,duplicate,display_mode,link_mode)
    %
    % This function loads remote profiles, identifies local cluster if it exists, and creates a user-friendly list including scheduler type
    %
    % The function can test the connection, and return either all profiles, all
    % valid profiles, profiles selected by user input, or profiles selected by function inputs
    %
    % If the profile selected by remote does not exist or test failed, empty remoteprofiles returned
    %
    %   - INPUTS : 
    %       - remote : 
    %           o (NaN)     : load all profiles and ask for user selection 
    %           o (struct)  : profile contained in structure or structure array 'remote' 
    %           o (string)  : identification of profile to be selected as remote_(string).m 
    % (default) o ('')      : load & return all profiles 
    %           o ('local') : idendify and return local cluster
    %       - test : (boolean) test loaded profiles
    %       - inter : (boolean) (1) interactive mode (for remote profile, scheduler and profile name) or (0) automatic mode
    %       - scheduler : (char array - only if remote ~= '') identification of scheduler to be selected. 
    %           o If scheduler == '', load default scheduler
    %           o If scheduler == NaN (default), user input for scheduler (if inter == 1, or default scheduler)
    %       - profilename : (NaN or char array) name of profile within remote cluster description (ex : joan, yves, ...)
    %           o if NaN (default), user input for profile name (if inter == 1, or default profile name)
    %           o if the name is not specified or does not exist, default profile name is selected.
    %       - duplicate : (boolean - used only if local profile among those selected) duplicate local profile with and without empty host, to test both ways
    %       - display_mode : (boolean) show information in command window 
    %       - link_mode : connection mode prescription
    %           o NaN : (default) use value from remote.link_mode
    %           o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
    %           o 0   : ssh key pair enforced
    %           o 1   : ssh bridge enforced
    %           o 2   : url/ftp bridge enforced
    %
    %   - OUTPUTS :
    %       - newremoteprofiles : (struct array) list of remote profile, or selection if select == true
    %       - profilestr : (cell or char array) corresponding user-friendly title
    %
    %   - Ex : 
    %       - to load profile from remote_macpro_YVES_PEYSSON.m with scheduler 'condor', profile 'yves' and with connection test :
    %           >> remote = load_remoteprofiles_jd('macpro_YVES_PEYSSON','condor','yves',true);
    %
    %       - to find all profiles and schedulers with valid connection test, duplicate local profile, and choose among them, for profile 'joan' :
    %           >> remote = load_remoteprofiles_jd('','','joan',true,true,true);
    %
    %       - to load and return all profiles and scheduler with default profilename and without connection test or duplicate local profile, and also load user-friendly description :
    %           >> [remoteprofiles,profilestr] = load_remoteprofiles_jd;
    %
    if nargin < 8,
        link_mode = NaN;% use value from remote.link_mode
    end
    if nargin < 7 || ~isscalar(display_mode) || (~islogical(display_mode) && ~isnumeric(display_mode)),
        display_mode = true;
    end
    if nargin < 6 || ~isscalar(duplicate) || (~islogical(duplicate) && ~isnumeric(duplicate)),
        duplicate = false;
    end
    if nargin < 5 
        profilename = NaN;% prompt user for profile name
    end
    if nargin < 3 || ~isscalar(inter) || (~islogical(inter) && ~isnumeric(inter)),
        inter = false;
    end
    if nargin < 2 || ~isscalar(test) || (~islogical(test) && ~isnumeric(test)),
        test = false;
    end
    if nargin < 1 || (~isstruct(remote) && ~ischar(remote) && (~isscalar(remote) || ~isnan(remote))),
        if inter,
            remote = '';% load all profiles
        else
            remote = 'local';% load all local profiles
        end
    end
    if nargin < 4 || ~ischar(scheduler),
        if inter,
            scheduler = NaN;% prompt user for  scheduler
        else
            scheduler = '';
        end
    end
    %
    MatRemoteDir = fileparts(which(mfilename));
    %
    remoteprofiles = [];
    profilestr = {};
    %
    if isstruct(remote),% case where structure or structure array was input
        for irem = 1:length(remote),
            %
            remoteprofile = testremoteprofile_jd(remote(irem),link_mode,test,display_mode);
            %
            if ~isempty(remoteprofile),
                remoteprofiles = [remoteprofiles,remoteprofile];
                profilestr = [profilestr,getremotestr_jd(remoteprofile)];
            else
                hoststr = remote(irem).host;
                if isempty(hoststr),
                    hoststr = 'Local batch calculation';
                elseif iscell(hoststr),
                    hoststr = hoststr{1};
                end
                if ~isempty(link_mode) && isnan(link_mode),
                    link_modestr = num2str(remote(irem).link_mode);
                else
                    link_modestr = num2str(link_mode);
                end
                if isempty(link_modestr),
                    link_modestr = 'empty link_mode';
                else
                    link_modestr = ['link_mode = ',link_modestr];
                end
                %
                disp(['WARNING : connection test failed for remote host : ',hoststr,' with ',link_modestr]);
            end
        end
        %
        return
        %
    end
    %
    if isscalar(remote) && isnan(remote),% load all profiles and prompt selection
        %
        remote = '';
        select = true;
        %
    else
        select = false;
    end
    %
    % List all files from Matremote/Profiles directory of the form remote_[...].m that contain profiles
    %
    RemoteProfDirContents = dir([MatRemoteDir,filesep,'Profiles/remote_*.m']);
    nremotefiles = length(RemoteProfDirContents);
    RemoteFileNames = cell(1,nremotefiles);
    for ifile = 1:nremotefiles,
        RemoteFileNames{ifile} = RemoteProfDirContents(ifile).name(1:end-2);
    end
    %
    if ~isempty(remote) && ~strcmp(remote,'local'),
        %
        % case where profile was specified by function input
        %
        filename = ['remote_',remote];
        iselected = strcmp(RemoteFileNames,filename);
        %
        if ~any(iselected),
            disp(['WARNING : file ',filename,'.m not found on the matlab path. Empty remoteprofiles returned']);
            return
        end
        %
    else% other cases
        %
        % Read local hostname
        %
        lochostname = hostname_jd;
        %
        % Load profiles with profilename and default scheduler, and identify local cluster 
        %
        LocalFileTest = false(1,nremotefiles);
        %
        for ifile = 1:nremotefiles,
            %
            remoteprofile = feval(RemoteFileNames{ifile});
            hostname = remoteprofile.hostname;
            %
            if any(strfind(lochostname,hostname)),% local cluster,
                %
                if display_mode,
                    disp(' ')
                    disp(['Local cluster identified : ',remoteprofile.host]);
                end
                %
                LocalFileTest(ifile) = true;
                %
            end
        end
        %
        if strcmp(remote,'local'),% local cluster selected
            %
            if sum(LocalFileTest) == 0,
                disp('WARNING : no local cluster found among remote_*.m files. Empty remoteprofiles returned');
                return
            end
            %
            if sum(LocalFileTest) > 1,
                disp('WARNING : more than one local cluster found among remote_*.m files. First cluster selected.');
            end
            %
            iselected = find(LocalFileTest,1,'first');
            %
        end
    end
    %
    if ~ischar(profilename),
        if inter,
            profilenamelist = {};
            if ~isempty(remote),% case where a specified remote file is requested
                %
                fullremote = feval(RemoteFileNames{iselected},'all');% all schedulers & profilenames
                default = fullremote.default;
                schedulerlist = fieldnames(rmfield(fullremote,'default'));
                profilenamelist = {};
                for isched = 1:length(schedulerlist),
                    profilenamelist = unique([profilenamelist,fieldnames(fullremote.(schedulerlist{isched})).']);
                end
                iprof = find(strcmp(profilenamelist,default.profile));
                profilenamelist = profilenamelist([iprof,1:iprof-1,iprof+1:end]);
                %
            end
            if ~isempty(profilenamelist),
                profilename = profilenamelist{iselect_jd(profilenamelist,'Select profile name : ',0,struct,1)};
            else
             	profilename = input_dke_yp('Identify profile name such as ''yves'', ''joan'', ... or leave empty to use default.','');
            end
        elseif strcmp(remote,'local'),
            profilename = 'local';
        else
            profilename = '';
        end
    end
    %
    if ~isempty(remote),
        %
        % case where profile was specified by function input
        %
        remoteprofilefortest = feval(RemoteFileNames{iselected},'',profilename);
        if strcmp(remote,'local'),
            remoteprofilefortest.host = '';% local cluster
        end
        testedprofile = testremoteprofile_jd(remoteprofilefortest,link_mode,test,display_mode);
        if isempty(testedprofile),
            disp(['WARNING : connection test failed for ',RemoteFileNames{iselected},'.m. Empty remoteprofiles returned']);
            return
        end
        %
        newremoteprofiles = feval(RemoteFileNames{iselected},scheduler,profilename);
        nrem = length(newremoteprofiles);
        %
        for irem = 1:nrem,
            newremoteprofiles(irem).host = testedprofile.host;% host from test output
            newremoteprofiles(irem).hosts = testedprofile.hosts;% hosts list from test output
            newremoteprofiles(irem).link_mode = testedprofile.link_mode;% link_mode from test output
        end    
        %
        profilestr = cell(1,nrem);
        cmdstr = cell(1,nrem);
        schedulerstr = cell(1,nrem);
        %
        for irem = 1:nrem,
            if strcmp(remote,'local'),
                newremoteprofiles(irem).host = '';% local cluster
            end
            %
            [profilestr{irem},~,cmdstr{irem},schedulerstr{irem}] = getremotestr_jd(newremoteprofiles(irem));
            %
        end
        %
        if nrem > 1,
            %
            disp(' ')
            disp('Please select a scheduler type :');
            for irem = 1:nrem,               
                disp(['- ',num2str(irem),' : ',schedulerstr{irem},' (',cmdstr{irem},')']);
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
        TestedLinkModes = zeros(1,nremotefiles);
        %
        % test connections
        %
        if test && display_mode,
            %
            disp(' ');
            disp('-------------------------------------------------------------------');
            disp('                     TEST REMOTE CONNECTIONS                       ');
            disp('-------------------------------------------------------------------');
            %
        end
        %
        for ifile = 1:nremotefiles,
            testedprofile = testremoteprofile_jd(feval(RemoteFileNames{ifile},'',profilename),link_mode,test,display_mode);
            RemoteFileTest(ifile) = ~isempty(testedprofile);
            if RemoteFileTest(ifile) && ~isempty(testedprofile.link_mode),
                TestedLinkModes(ifile) = testedprofile.link_mode;
            else
                TestedLinkModes(ifile) = link_mode;
            end
        end
        %
        % Put local profiles first
        %
        RemoteFileNames = [RemoteFileNames(LocalFileTest),RemoteFileNames(~LocalFileTest)];
        RemoteFileTest = [RemoteFileTest(LocalFileTest),RemoteFileTest(~LocalFileTest)];
        TestedLinkModes = [TestedLinkModes(LocalFileTest),TestedLinkModes(~LocalFileTest)];
        LocalFileTest = [LocalFileTest(LocalFileTest),LocalFileTest(~LocalFileTest)];
        %
        % Select local and remotely working profiles 
        %
        SelectedProfiles = LocalFileTest | RemoteFileTest;
        RemoteFileNames = RemoteFileNames(SelectedProfiles);
        LocalFileTest = LocalFileTest(SelectedProfiles);
        RemoteFileTest = RemoteFileTest(SelectedProfiles);
        TestedLinkModes = TestedLinkModes(SelectedProfiles);
        %
        % Load profiles with profilename including all schedulers
        %
        remoteprofiles = [];
        localprofiletest = [];
        remoteprofiletest = [];
        %
        for irem = 1:length(RemoteFileNames),
            newremoteprofiles = feval(RemoteFileNames{irem},scheduler,profilename);
            %
            for iirem = 1:length(newremoteprofiles),
                newremoteprofiles(iirem).link_mode = TestedLinkModes(irem);
            end
            remoteprofiles = [remoteprofiles,newremoteprofiles];
            localprofiletest = [localprofiletest,repmat(LocalFileTest(irem),[1,length(newremoteprofiles)])];
            remoteprofiletest = [remoteprofiletest,repmat(RemoteFileTest(irem),[1,length(newremoteprofiles)])];
        end
        nrem = length(remoteprofiles);
        %
        % Duplicate (if duplicate==true) possible local profile(s);
        % Generate user-friendly title
        %
        newremoteprofiles = [];
        %
        for irem = 1:nrem,
            %
            if localprofiletest(irem) && isempty(remoteprofiles(irem).link_mode),% local cluster with empty host field
                %
                remoteprofile = remoteprofiles(irem);% remote profile selected
                remoteprofile.host = '';
                newremoteprofiles = [newremoteprofiles,remoteprofile];
                %
            end
            %
            if remoteprofiletest(irem) && (~localprofiletest(irem) || (localprofiletest(irem) && duplicate)),% remote cluster or local cluster with full host field (if duplicate == true)
                %
                newremoteprofiles = [newremoteprofiles,remoteprofiles(irem)];% remote profile selected
                %
            end
            %
        end
        %
        % List (& select if select == true) all valid remote (and local) profiles
        %
        nrem = length(newremoteprofiles);
        %
        profilestr = cell(1,nrem);
        for irem = 1:nrem,
            profilestr{irem} = getremotestr_jd(newremoteprofiles(irem));
        end
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
        else
            %
            remoteprofiles = newremoteprofiles;
            %
        end
    end
end
%
function [profilestr,hoststr,cmdstr,schedulerstr] = getremotestr_jd(remote)
    %
    % remote profile host string
    %
    hoststr = remote.host;
    if isempty(hoststr),
        hoststr = 'Local batch calculation';
    elseif iscell(hoststr),
        hoststr = hoststr{1};
    end
    %
    % scheduler profile string
    %
    schedulerstr = remote.scheduler;
    if iscell(schedulerstr),
        schedulerstr = schedulerstr{1};
    end
    schedulerstr = schedulerstr(1:min([end,find(schedulerstr == ' ' | schedulerstr == '_',1,'first') - 1]));
    %
    % remote profile cmd string
    %
    cmdstr = remote.cmd;
    if iscell(cmdstr),
        cmdstr = cmdstr{1};
    end
    cmdstr = cmdstr(1:min([end,find(cmdstr == ' ' | cmdstr == '_',1,'first') - 1]));
    %
    % bridge (url or ssh)
    % 
    if remote.link_mode == 1,
        bridgestr = [' via SSH: ',remote.bridge.ssh.host];
    elseif remote.link_mode == 2,
        bridgestr = [' via URL: ',remote.bridge.url.host,' and FTP: ',remote.bridge.ftp.host];
    else
        bridgestr = '';
    end
    %
    % remote user
    %
    userstr = remote.remoteuser;
    %
    if length(remote.filename) > 8,
        remote_env = [remote.filename(8:end),' : '];
    else
        remote_env = '';
    end
    %
    %profilestr = [remote_env,hoststr,' : ',schedulerstr,' (',cmdstr,')',bridgestr,' as user ',userstr]
    profilestr = [remote_env,schedulerstr,' (',cmdstr,')',bridgestr,' as user ',userstr];
end
%