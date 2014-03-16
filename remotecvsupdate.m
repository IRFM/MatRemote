function remotecvsupdate(remote,remotefunctions,display_mode,exclude)
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
%           o select_LUKE_jd -> MatTools
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
if nargin < 4,
    exclude = {};
end
%
if nargin < 3,
    display_mode = 0;
end
%
if nargin < 2,
    remotefunctions = {'select_LUKE_jd.m','load_remoteprofiles_jd.m'};
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
for irem = 1:nrem,
    %
    disp(' ');
    disp('------------------------------------------------------------------');
    disp(['updating remote profile : ',profilestr{irem}]);
    disp('------------------------------------------------------------------');
    disp(' ');
    %
    [err,res,txt] = matremote_jd('cvsupdate_jd',{remotefunctions},remoteprofiles(irem));
    %
    if isempty(err),
        %
        for ifnc = 1:nfncs,
            remotefnc = remotefunctions{ifnc};
            %
            if length(remotefnc) > 2 && strcmp(remotefnc(end-1:end),'.m'),%case of function within folder
                remotefnc = remotefnc(1:end-2);
                msg = 'containing ';
            else
                msg = 'set by environment variable ';
            end
            %
            if display_mode >= 1,
                if res.(remotefnc) == 0,
                    disp(['CVS update successful for folder ',msg,': ',remotefnc]);
                else
                    disp(['CVS update failed : ',txt.(remotefnc)]);
                end
            end
            %
            if display_mode >= 2,
                %
                isep = [0,find(txt.(remotefnc) == 10)];
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
                    txts{iisep} = txt.(remotefnc)(isep(iisep)+1:isep(iisep+1)-1);
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
                            if strcmp(exclude{iext},txts{iisep}(end-length(exclude{iext})+1:end)),
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
                % display results
                %
                disp('    -----------------------');
                disp(['    - Files in conflict : ',num2str(nC)]);
                disp(' ');
                %
                for iisep = find(flag_C),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp('    ------------------------------');
                disp(['    - Files with modifications : ',num2str(nM)]);
                disp(' ');
                %
                for iisep = find(flag_M),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp('    -----------------');
                disp(['    - Files added : ',num2str(nA)]);
                disp(' ');
                %
                for iisep = find(flag_A),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp('    -------------------');
                disp(['    - Files removed : ',num2str(nR)]);
                disp(' ');
                %
                for iisep = find(flag_R),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp('    -------------------');
                disp(['    - Files updated : ',num2str(nU)]);
                disp(' ');
                %
                for iisep = find(flag_U),
                    disp(['        o ',txts{iisep}]);
                end
                %
                disp('    ----------------------------------------');
                disp(['    - Selected files outside CVS control : ',num2str(nO)]);
                disp(' ');
                %
                for iisep = find(flag_O),
                    disp(['        o ',txts{iisep}]);
                end
                %
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



