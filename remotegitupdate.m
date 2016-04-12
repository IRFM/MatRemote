function flag = remotegitupdate(remote,remotefunctions,display_mode,exclude,debugmode)
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
%           o load_remoteprofiles_jd -> MatTools
%
%       - display_mode : 
%           o 0 : no dispplay
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
%       - flag : matrix of size (nrem x nfncs) with values :
%           o -2 if the remote process failed
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
    display_mode = 0;
end
%
if nargin < 2,
    remotefunctions = {'select_LUKE.m','load_remoteprofiles_jd.m'};
end
%
if nargin < 1,
    remote = '';
end
%
[remoteprofiles,profilestr] = load_remoteprofiles_jd(remote,true,false,NaN,NaN,false,false);
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
    for ifnc = 1:nfncs,
        %
        job = matstandardjob_jd('runmat');
        job.remtimout = 30;% timeout in minutes
        %
        remoteprofiles(irem).sshopts = ['-o ConnectTimeout=',int2str(job.remtimout),' -o BatchMode=yes'];
        %
        [err,jobparams,res,txt,workpath] = matremote_jd('gitupdate_yp',{remotefunctions{ifnc},remoteprofiles(irem).gitmode,debugmode},remoteprofiles(irem),job);
        %
        if isempty(err),            
            %
            if display_mode >= 1,
                disp(' ');
                disp('------------------------------------------------------------------');
                disp(' ');
                if res(1) == 0,
                    for itxt = 1:length(txt),
                        disp(['Successful ',txt{itxt}(1:end-1), ' from primary Git repository']);
                    end
                    flag(irem,ifnc) = 0;
                    %
                else
                    for itxt = 1:length(txt),
                        disp(['Git update failed : ',txt{itxt}(1:end-1)]);
                    end
                    flag(irem,ifnc) = -1;% failed git update
                end
            end
            %
        else
            %
            flag(irem,ifnc) = -2;
            %
            disp(' ');
            disp('Remote call failed : ');
            disperr_jd(err);
            %
        end
    end
end



