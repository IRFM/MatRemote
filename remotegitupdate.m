function [profilestr,flag] = remotegitupdate(remote,remotefunctions,display_mode,exclude,debugmode)
%
% This function git updates the folders containing the functions listed in remotefunctions 
% over the profiles defined by remote
%
%   - INPUTS : 
%       - remote : 
%           o (NaN)     : load all profiles and ask for user selection 
%           o (struct)  : profile contained in structure or structure array 'remote' 
%           o (string)  : identification of profile to be selected as remote_(string).m 
% (default) o ('')      : load & return all profiles 
%           o ('local') : idendify and return local cluster
%
%       - remotefunctions : list of functions (if ends by '.m') or name of environment variable for path to update. default values include
%           o select_LUKE -> MatTools
%           o load_remoteprofiles_jd -> MatRemote
%           o make_help -> MatHelp
%           o lukegitupdate -> LUKE
%
%       - display_mode : 
%           o 0 : no display
%           o 1 : display result only
%           o 2 : display updated, removed, added, and conflicts
%           o 3 : also list files & folders outside Git control.
%
%       - exclude : 
%           Ignore extensions from list of files outside Git control (only used if display_mode >= 3)
%       
%       - debugmode: (0) debug mode not activated, (1) debug mode activated
%
%   - OUTPUTS : 
%       - profilestr : connection characteristics
%       - flag : matrix of size (nrem x nfncs) with values :
%           o -2 if the remote process or git update process failed
%           o -1 if the git update process failed
%           o  0 if the git update succeeded without remote conflicts or remote modified files
%
if nargin < 5,
    debugmode = 0;
end
if nargin < 4,
    exclude = {};
end
%
if nargin < 3,
    display_mode = 1;
end
%
if nargin < 2,
    remotefunctions = {'select_LUKE.m','load_remoteprofiles_jd.m','make_help.m','lukegitupdate.m'};
end
%
if nargin < 1,
    remote = '';
end
%
if exist('remotefunctions','var'),
    if isempty(remotefunctions),
        remotefunctions = {'select_LUKE.m','load_remoteprofiles_jd.m','make_help.m','lukegitupdate.m'};
    end
else
    remotefunctions = {'select_LUKE.m','load_remoteprofiles_jd.m','make_help.m','lukegitupdate.m'};
end
%
[remoteprofiles,profilestr] = load_remoteprofiles_jd(remote,true,false,'direct','',true,false);
%
dkepath = setpath_luke_jd('','','',0,0);
%
nrem = length(remoteprofiles);
nfncs = length(remotefunctions);
nexts = length(exclude);
%
flag = NaN(nrem,nfncs);
%
for irem = 1:nrem,
    %
    disp(' ');
    disp('------------------------------------------------------------------');
    disp(['updating remote profile : ',profilestr{irem}]);
    disp('------------------------------------------------------------------');
    %
    for jrem = 1:length(dkepath.remote)
        if strcmp(remoteprofiles(irem).hostname,dkepath.remote(jrem).hostname) && strcmp(dkepath.remote(jrem).scheduler,'direct'),
            if isfield(dkepath.remote(jrem),'gitupdate') && isfield(dkepath.remote(jrem),'gitmode')
                remoteprofile = dkepath.remote(jrem);
            end
        end
    end
    %
    if ~isfield(remoteprofile,'gitupdate') && isfield(remoteprofile,'gitmode'),
        disp('WARNING: gitupdate and gitmode are not set-up in dkepath. Please check ')
        break;
    end    
    %
    for ifnc = 1:nfncs,
        %
        [res,txt,project] = gitupdate_yp(remotefunctions{ifnc},remoteprofile.gitmode,remoteprofile,debugmode);
        %
        if ~res,            
            %
            if length(strfind(txt{1},'error')) ~= 0 | length(strfind(txt{1},'fatal')) ~= 0  | length(strfind(txt{1},'unable')) ~= 0  | length(strfind(txt{1},'No path')) ~= 0,
                flag(irem,ifnc) = -1;
            else
                flag(irem,ifnc) = 0;
            end
            %
            if display_mode >= 1,
                disp(' ');
                disp('------------------------------------------------------------------');
                disp(' ');
                %
                txt = txt{:};
                %
                if  flag(irem,ifnc) == -1,
                    disp(['WARNING: Git update for ',project,' failed ---> ',txt]);
                else
                    disp(['Successful Git update for ',project,' ---> ',txt]);                       
                end
            end
            %
        else
            %
            flag(irem,ifnc) = -2;
            %
            if display_mode >= 1,
                disp(' ');
                disp('------------------------------------------------------------------');
                disp(' ');
                disp('Remote call failed : ');
                disperr_jd(txt);
            end
            %
        end
    end
end
%
time0 = time;
time1 = strrep(time0,'   ','.');
diary(['gitpdate_summary_',time1,'.txt']);
disp('------------------------------------------------------------------');
disp('------------------------------------------------------------------');
disp(['Git update summary: ',time0]);
disp('------------------------------------------------------------------');
for irem = 1:nrem,
    comment = [profilestr{irem},': '];
    %
    for jflag = 1:size(flag,2),
        if jflag < size(flag,2),
            comment = [comment,int2str(flag(irem,jflag)),', '];
        else
            comment = [comment,int2str(flag(irem,jflag))];
        end
    end
    %
    disp(comment);
end
disp('------------------------------------------------------------------');
disp('------------------------------------------------------------------');
diary('off');
%



