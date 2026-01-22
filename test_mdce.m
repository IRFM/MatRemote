% 
% /////////////////////////////////////////
%
% Software name : MatRemote, part of LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function flag = test_mdce(mdce_mode,remote,force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode)
%
% Test function of the distributed computing calculation 
%
% For a quick test run test_mdce(a,b,0) where:
%   - a is the distributed calculation mode :
%       o (0) sequential (1) MDCE job scheduler (2) parfor
%       o (0+i,1+i,2+i) if single precision GPU calculations is enabled (recommanded)
%       o (0+2i,1+2i,2+2i) if double precision GPU calculations is enabled
%       o remote cluster identification (see "INPUTS") 
%   - b : if ~isempty(b), the calculation is sent (possibly recursively) to the remote host b{1} (using mdce_remote.m) and distributed there using the modes (a,b{2:end})
%
% Note that the use of mdce_remote.m [when ~isempty(b)] requires the MatRemote and MatTools toolboxes to be installed on the remote machine b{1,2,3...}
%
% ex : 
%   - to run locally and sequentially :
%       >> test_mdce(0)
%   - to run locally on GPU :
%       >> test_mdce(1i)
%   - to run locally using job scheduler :
%       >> test_mdce(1)
%   - to run locally using parfor :
%       >> test_mdce(2)
%   - to distribute to local cluster using remcomputing :
%       >> test_mdce(3)
%           or
%       >> test_mdce('local')
%   - to distribute to 'MACHINE' using remcomputing :
%       >> test_mdce('MACHINE')
%   - to distribute to the profile stored in the structure 'remote' using remcomputing :
%       >> test_mdce(remote)
%   - to select manually which remote profile you want to distribute the calculation :
%       >> test_mdce(NaN)
%   - to transfer the calculation to 'MACHINE' and distribute therein using parfor
%       >> test_mdce(2,{'MACHINE'})
%   - to transfer the calculation to 'MACHINE1' and then to 'MACHINE2' and distribute therein using remcomputing
%       >> test_mdce('local',{'MACHINE1','MACHINE2'})
%
%   INPUT :
%
%       - mdce_mode: distributed computing environment state: 
%           o (0)       : sequential
%           o (1)       : job scheduler (Matlab MDCE required)             (+i enables GPU calculations)
%           o (2)       : parfor parallel computing (Matlab MDCE required) (+i enables GPU calculations)
%           o (3)       : use of remcomputing with local cluster
%           o remote id : extended use of remcomputing (cluster identification, see below for details)
%           (default = 0)
%
%       - remote (cell array) : calculation sent to remote{1} using mdce_remote.m. 
%               Each cell contains cluster identification, see below for details
%           (default = {})
%        
%       cluster identification (mdce_mode or remote{irem})
%           o (struct)  : calculation distributed to the profile stored in the structure 'remote'
%           o (NaN)     : prompt user for profile
%           o ('local') : identifies and select local cluster
%           o (string)  : profile from remote_(remote).m (ex : 'macpro_YVES_PEYSSON')
%
%       - force_error: force an error to check how a possible error in calculation is managed, 0 (no error), (1) error in batch run only for arg = 5, (2) error in any run for arg = 5 [1,1]
%           (default = 1)
%       - mdce_enforce: (1) enforce sequential run if distributed computing failed, (0) otherwise [1,1]
%           (default = 1)
%       - schedulertype: type of scheduler, '' or 'local' for any machine or cluster,'pbs', 'slurm', 'condor',... [1,1]
%           (default = 'local')
%       - mdce_size: cluster size. Use the maximum of processor available for calculations (not valid for GPU) [1,1]
%           (default = 8)
%       - mdce_memory: memory allocated to batch runs, in MBytes (NaN to set no limit, not valid for GPU) [1,1]
%           (default = 200)
%       - debugmode : [0 or 1] if 1, provides step by step information, and save diary file in remote job folder 
%           (default = 0)
%       - displaymode : 
%           o (0) display results only, 
%           o (1) (default) display job status evolution 
%           o (2) display step by step
%           (default = 1)
%
%   OUTPUT : flag = flag(1);
%
% by J. Decker DRFC-CEA <joan.decker@cea.fr> and Y. Peysson DRFC-CEA <yves.peysson@cea.fr>
%
if nargin < 1 || (~isstruct(mdce_mode) && ~ischar(mdce_mode) && ~isempty(mdce_mode) && (~isscalar(mdce_mode) || (~any(real(mdce_mode) == 0:3) && ~isnan(mdce_mode)))),% test mdce_mode for valid formats
    mdce_mode = 0;
end
%
if nargin < 2,
    remote = {};
end
%
if nargin < 3,
    force_error = 0;% 0 (no error), (1) error in batch run only for arg = 5, (2) error in any run for arg = 5,
end
%
if nargin < 4,
    mdce_enforce = 1;
end
%
if nargin < 5,
    schedulertype = 'local';%'' or 'local','pbspro','condor',...
end
%
if nargin < 6,
	mdce_size = 8;
end
%
if nargin < 7,
    mdce_memory = 200;
end
%
if nargin < 8,
    debugmode = 0;
end
%
if nargin < 9,
    displaymode = 1;
end
%
if nargin >= 2, 
    disp('WARNING :The MatRemote toolbox must be up to date on the remote computer !')
end
%
if isnumeric(mdce_mode) && any(real(mdce_mode) == 0:2),
    param.mode = real(mdce_mode);
    param.gpu = imag(mdce_mode);
else
    param.mode = mdce_mode;
    param.gpu = 0;
end
param.remote = remote;
param.funcopy = true;% copy ftest_mdce to remote cluster
param.type = schedulertype;
param.inter = 1;% interactive mode for profile and/or cluster name selection enabled
%
param.clustersize = mdce_size;
param.memory = mdce_memory;
param.enforce = mdce_enforce;
param.debugmode = debugmode;
param.display = displaymode;
%
if debugmode,
    param.cleanmode = 0;  
end
%
dkecluster = mdce_clustermode(param);
%
% note that it would be equivalent to use :
% 
% >> clustermode.ftest_mdce.scheduler = param;
% >> dkecluster = mdce_clustermode(clustermode,'ftest_mdce');
%
[flag,a,b] = mdce_run(@ftest_mdce,{NaN,1,force_error},1,1:mdce_size,dkecluster);
%
if displaymode,
    if any(imag(flag) ~= 0),
        disp(['Rem Flag : ',num2str(real(flag))]);
        disp(['Loc Flag : ',num2str(imag(flag))]);
        disp(['a (2->9) : ',num2str([a{:}])]);
        disp(['b (0->7) : ',num2str([b{:}])]);
    else
        disp(['Flag : ',num2str(flag)]);
        disp(['a (2->9) : ',num2str([a{:}])]);
        disp(['b (0->7) : ',num2str([b{:}])]);
    end    
end
%
flag = flag(1);
