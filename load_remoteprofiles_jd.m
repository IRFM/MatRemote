function [remoteprofiles,profilestr] = load_remoteprofiles_jd(remote,test,inter,scheduler,profilename,duplicate,display_mode,bridge_enforce)
    %
    % This function loads remote profiles, identifies local cluster if it
    % exists, and creates a user-friendly list including scheduler type
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
    %       - bridge_enforce : [NaN, empty, 0 or 1] if 1, provides step by step information, and save diary file in remote job folder 
    %           o NaN : (default) use value from remote.bridge_enforce
    %           o []  : tests both modes and give priority to ssh key pair
    %           o 0   : tests only ssh key pair,
    %           o 1   : tests only bridge mode
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
    if nargin < 8,
        bridge_enforce = NaN;% use value from remote.bridge_enforce
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
            remote = 'local';% load all profiles
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
    tmp_profiles = '';
    %
    if ~ischar(profilename) && ~isstruct(remote),
        %
        if ischar(remote) && ~isempty(remote) && ~strcmp(remote,'local'),% case where a specified remote file is requested
            %  
            if exist([MatRemoteDir,'/Profiles/remote_',remote,'.m'],'file')
                tmp_remote = eval(['remote_',remote,'(''all'')']);
                tmp_remote_fields = fieldnames(tmp_remote);
                %
                for itmprem = 1:length(tmp_remote_fields),
                     tmp_profile_fields = fieldnames(tmp_remote.(tmp_remote_fields{itmprem}));
                     for itmpprof = 1:length(tmp_profile_fields),
                        if isempty(strfind(tmp_profiles,tmp_profile_fields{itmpprof})),
                            if ~isempty(tmp_profiles),
                                tmp_profiles = [tmp_profiles,', ',tmp_profile_fields{itmpprof}];
                            else
                                 tmp_profiles = tmp_profile_fields{itmpprof};
                            end
                        end
                     end
                end
            end
        end
        %
        if inter,
            if ~isempty(tmp_profiles),
            	profilename = input_dke_yp(['Identify profile name in the list ''',tmp_profiles,''', or leave empty to use default remote profile'],'');
            else
             	profilename = input_dke_yp(['Identify profile name like ''yves, joan, ...'', or leave empty to use default for each remote profile'],'');
            end
        elseif strcmp(remote,'local'),
            profilename = 'local';
        else
            profilename = '';
        end
    end
    %
    remoteprofiles = [];
    profilestr = {};
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
    if isstruct(remote),% case where structure or structure array was input
        for irem = 1:length(remote),
            %
            if test,
                remoteprofile = testremoteprofile_jd(remote(irem),bridge_enforce,display_mode);
            else
                remoteprofile = remote(irem);
            end
            %
            if ~isempty(remoteprofile),
                if ~isnan(bridge_enforce),
                    remoteprofile.bridge_enforce = bridge_enforce;
                end
                remoteprofiles = [remoteprofiles,remoteprofile];
                profilestr = [profilestr,getremotestr_jd(remoteprofile)];
            else
                disp(['WARNING : connection test failed for structure remote : ',getremotestr_jd(remote(irem))]);
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
        if test && isempty(testremoteprofile_jd(feval(filename,'',profilename),bridge_enforce,display_mode)),
            disp(['WARNING : connection test failed for ',filename,'.m. Empty remoteprofiles returned']);
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
            remoteprofile = feval(RemoteFileNames{ifile},'',profilename);
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
    if ~isempty(remote),
        %
        % case where profile was specified by function input
        %
        newremoteprofiles = feval(RemoteFileNames{iselected},scheduler,profilename);
        nrem = length(newremoteprofiles);
        %
        flag = true(1,nrem);
        for irem = 1:nrem,
            if ~strcmp(remote,'local') && ~isnan(bridge_enforce),
                newremoteprofiles(irem).bridge_enforce = bridge_enforce;
                if any(bridge_enforce == 1) && isempty(newremoteprofiles(irem).bridge),% case appears when bridge mode not implemented for all schedulers
                    flag(irem) = false;
                end
            end
        end    
        newremoteprofiles = newremoteprofiles(flag);    
        %
        nrem = length(newremoteprofiles);
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
                RemoteFileTest(ifile) = ~isempty(testremoteprofile_jd(feval(RemoteFileNames{ifile},'',profilename),bridge_enforce,display_mode));
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
                remoteprofile = remoteprofiles(irem);% remote profile selected
                remoteprofile.host = '';
                newremoteprofiles = [newremoteprofiles,remoteprofile];
                profilestr = [profilestr,getremotestr_jd(remoteprofile)];
                %
            end
            %
            if remoteprofiletest(irem) && (~localprofiletest(irem) || (localprofiletest(irem) && duplicate)),% remote cluster or local cluster with full host field (if duplicate == true)
                %
                remoteprofile = remoteprofiles(irem);% remote profile selected
                newremoteprofiles = [newremoteprofiles,remoteprofile];
                profilestr = [profilestr,getremotestr_jd(remoteprofile)];
                %
            end
            %
        end
        %
        % List (& select if select == true) all valid remote (and local) profiles
        %
        nrem = length(profilestr);
        %
        % manage bridge mode
        %
        flag = true(1,nrem);
        for irem = 1:nrem,
            if ~isnan(bridge_enforce),
                newremoteprofiles(irem).bridge_enforce = bridge_enforce;
                if any(bridge_enforce == 1) && isempty(newremoteprofiles(irem).bridge),% case appears for local profiles or when bridge mode not implemented for all schedulers
                    flag(irem) = false;
                end
            end
        end    
        profilestr = profilestr(flag);
        newremoteprofiles = newremoteprofiles(flag);    
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
        hoststr = 'local batch calculation';
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
    % bridge
    % 
    if ~isempty(remote.bridge) && ~isempty(remote.bridge.url.host) && ~any(remote.bridge_enforce == 0),
        bridgestr = [' via ',remote.bridge.url.host];
    else
        bridgestr = '';
    end
    %
    % remote user
    %
    userstr = remote.remoteuser;
    %
    profilestr = [hoststr,' : ',schedulerstr,' (',cmdstr,')',bridgestr,' as user ',userstr];    
end
%
    

