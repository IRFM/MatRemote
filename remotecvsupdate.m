function remotecvsupdate(remote,remotefunctions)
%
% This function cvs updates the folders containing the functions listed in remotefunctions 
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
%       - remotefunctions : list of functions. default values include
%           o select_LUKE_jd -> MatTools
%           o load_remoteprofiles_jd -> MatTools
%
if nargin < 2,
    remotefunctions = {'select_LUKE_jd','load_remoteprofiles_jd'};
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
%
for irem = 1:nrem,
    %
    disp(' ');
    disp('------------------------------------------------------------------');
    disp(['updating remote profile :',profilestr{irem}]);
    disp('------------------------------------------------------------------');
    disp(' ');
    %
    [err,res,txt] = matremote_jd('cvsupdate_jd',{remotefunctions},remoteprofiles(irem));
    %
    if isempty(err),
        %
        for ifnc = 1:nfncs,
            remotefnc = remotefunctions{ifnc};
            if res.(remotefnc) == 0,
                disp(['CVS update successful for folder containing : ',remotefnc]);
            else
                disp(['CVS update failed : ',txt.(remotefnc)]);
            end
        end
        %
    else
        %
        disp('Remote call failed : ');
        disperr_jd(err);
        %
    end
end



