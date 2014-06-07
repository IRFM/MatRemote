function flag = remotecvsupdate(remote,remotefunctions,display_mode,exclude)
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
%       - remotefunctions : list of functions (if ends by '.m') or name of environment variable for path to update. default values include
%           o select_LUKE -> MatTools
%           o load_remoteprofiles_jd -> MatTools
%
%       - display_mode : 
%           o 0 : no dispplay
%           o 1 : display result only
%           o 2 : display updated, removed, added, and conflicts
%           o 3 : also list files & folders outside CVS control.
%
%       - exclude : 
%           Ignore extensions from list of files outside CVS control (only used if display_mode >= 3)
%
%   - OUTPUTS : 
%       - flag : matrix of size (nrem x nfncs) with values :
%           o -2 if the remote process failed
%           o -1 if the cvs update process failed
%           o  0 if the cvs update succeeded without remote conflicts or remote modified files
%           o  1 if the cvs update succeeded without remote conflicts and with remote modified files
%           o  2 if the cvs update succeeded with remote conflicts
%
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
        job.remtimout = 5;% timeout in minutes
        %
        [err,jobparams,res,txt,workpath] = matremote_jd('cvsupdate_jd',{remotefunctions{ifnc},remoteprofiles(irem).cvsrights},remoteprofiles(irem),job);
        %
        if isempty(err),            
            %
            if res(1) ~= 0,
                flag(irem,ifnc) = -1;% failed cvs update
            else
                %
                isep = [0,find(txt{1} == 10)];
                %
                nseps = length(isep) - 1;
                %
                txts = cell(1,nseps);
                flag_C = false(1,nseps);
                flag_M = false(1,nseps);
                flag_A = false(1,nseps);
                flag_R = false(1,nseps);
                flag_U = false(1,nseps);
                flag_O = false(1,nseps);
                %
                for iisep = 1:nseps,
                    txts{iisep} = txt{1}(isep(iisep)+1:isep(iisep+1)-1);
                    %
                    % CVS outputs
                    %
                    if txts{iisep}(1) == 'C',
                        flag_C(iisep) = true;
                    elseif txts{iisep}(1) == 'M',
                        flag_M(iisep) = true;
                    elseif txts{iisep}(1) == 'A',
                        flag_A(iisep) = true;
                    elseif txts{iisep}(1) == 'R',
                        flag_R(iisep) = true;
                    elseif txts{iisep}(1) == 'U' || txts{iisep}(1) == 'P',
                        flag_U(iisep) = true;
                    end
                    %
                    % elements outside CVS control
                    %
                    if txts{iisep}(1) == '?' && display_mode >= 3,
                        %
                        flag_excl = false;
                        for iext = 1:nexts,
                            if (length(txts{iisep})-length(exclude{iext})+1 > 0) && strcmp(exclude{iext},txts{iisep}(end-length(exclude{iext})+1:end)),
                                flag_excl = true;
                                break
                            end
                        end
                        %
                        if ~flag_excl,
                            flag_O(iisep) = true;
                        end
                        %
                    end
                end
                %
                nC = sum(flag_C);
                nM = sum(flag_M);
                nA = sum(flag_A);
                nR = sum(flag_R);
                nU = sum(flag_U);
                nO = sum(flag_O);
                %
                if nC > 0,
                    flag(irem,ifnc) = 2;% files in conflict on remote folder
                elseif nM > 0,
                    flag(irem,ifnc) = 1;% files modified and not commited on remote folder
                else
                    flag(irem,ifnc) = 0;% cvs udpate OK
                end                    
            end
            %
            if display_mode >= 1,
                disp(' ');
                disp('------------------------------------------------------------------');
                disp(' ');
                if res(1) == 0,
                    disp(['CVS update successful for folder ',workpath]);
                    %
                    if ~isnan(res(2)),
                        %
                        if res(2) == 0,
                            disp(['CVS rights successfully set up for folder ',workpath]);
                        else
                            disp(['CVS rights setup failed : ',txt{2}]);
                        end
                    end
                    %
                else
                    disp(['CVS update failed : ',txt{1}]);
                end
            end
            %
            if display_mode >= 2 && res(1) == 0,
                %
                % display results
                %
                disp(' ');
                disp('    -----------------------');
                disp(['    - Files in conflict : ',num2str(nC)]);
                disp(' ');
                %
                for iisep = find(flag_C),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp(' ');
                disp('    ------------------------------');
                disp(['    - Files with modifications : ',num2str(nM)]);
                disp(' ');
                %
                for iisep = find(flag_M),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp(' ');
                disp('    -----------------');
                disp(['    - Files added : ',num2str(nA)]);
                disp(' ');
                %
                for iisep = find(flag_A),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp(' ');
                disp('    -------------------');
                disp(['    - Files removed : ',num2str(nR)]);
                disp(' ');
                %
                for iisep = find(flag_R),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp(' ');
                disp('    -------------------');
                disp(['    - Files updated : ',num2str(nU)]);
                disp(' ');
                %
                for iisep = find(flag_U),
                    disp(['        o ',txts{iisep}]);
                end
                %
                if display_mode >= 3,
                    disp(' ');
                    disp('    ----------------------------------------');
                    disp(['    - Selected files & folders outside CVS control : ',num2str(nO)]);
                    disp(' ');
                    %
                    for iisep = find(flag_O),
                        disp(['        o ',txts{iisep}]);
                    end
                end
                %
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



