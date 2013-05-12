function test_mdce(mdce_mode,mdce_remnum,force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,dkepath)
%
% Test function of the distributed computing calculation 
%
% For a quick test run test_mdce(a,b,0) where:
%   - a is the distributed calculation mode (0,1,2,3,-1,-2,...) or (0+i,1+i,2+i,3+i,-1+i,-2+i,...) if single precision GPU calculations is enabled (recommanded) or (0+2i,1+2i,2+2i,3+2i,-1+2i,-2+2i,...) if double precision GPU calculations is enabled or 
%   - b is the number of the remote profile in the path file (used only if a > 0)
%
%   - calculation is done localy: test_mdce(0,0,0) -> sequential, test_mdce(i,0,0) -> sequential+GPU, test_mdce(1,0,0) -> jobs, test_mdce(2,0,0) -> dcluke, test_mdce(3,0,0) -> parfor, test_mdce(3+i,0,0) -> parfor+GPU
%   - calculation may be first transfered and done remotely according to the distributed computing environment state: test_mdce(a,b,0) with a >= 0 and b > 0 Here b is the remote index (path file)
%   - calculation is first distributed localy and each job is executed remotely: test_mdce(a,0,0) with a < 0. Here a is the remote index (path file)
%
%   INPUT :
%
%       - mdce_mode: distributed computing environment state: (0) disabled, (1) enabled with the dedicated Matlab toolbox which must be installed, (2) enabled with a private method (LDCE), (3) parfor parallel computing (+i enables GPU calculations) [1,1]
%           (default = 0)
%       - mdce_remnum: remote index (0 for local cluster calculations) [1,1]
%           (default = 0)
%       - force_error: force an error to check how a possible error in calculation is managed, 0 (no error), (1) error in batch run only for arg = 5, (2) error in any run for arg = 5 [1,1]
%           (default = 1)
%       - mdce_enforce: (1) enforce sequential run if distributed computing failed, (0) otherwise [1,1]
%           (default = 1)
%       - schedulertype: type of scheduler, '' or 'local' for any machine or cluster,'pbspro' for CEPHEE or SATURNE cluster,'xgrid' on mac computers,... [1,1]
%           (default = 'local')
%       - mdce_size: cluster size. Use the maximum of processor available for calculations (not valid for GPU) [1,1]
%           (default = 8)
%       - mdce_memory: memory allocated to batch runs, in MBytes (NaN to set no limit, not valid for GPU) [1,1]
%           (default = 200)
%       - dkepath: path structure of LUKE
%           (automatic load in ~/LUKE/Project_DKE/Database/PATH_files/)
%
%   OUTPUT : none
%
% by J. Decker DRFC-CEA <joan.decker@cea.fr> and Y. Peysson DRFC-CEA <yves.peysson@cea.fr>
%
if nargin < 1,
    mdce_mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
end
%
if nargin < 2,
    mdce_remnum = 0;
end
%
if nargin < 3,
    force_error = 1;% 0 (no error), (1) error in batch run only for arg = 5, (2) error in any run for arg = 5,
end
%
if nargin < 4,
    mdce_enforce = 1;
end
%
if nargin < 5,
    schedulertype = 'local';%'' or 'local','pbspro','xgrid','condor',...
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
    dkepath = load_structures_yp('dkepath','','');
end
%
clustermode.ftest_mdce.scheduler.mode = real(mdce_mode);
if ~isreal(mdce_mode),
    clustermode.ftest_mdce.scheduler.gpu = imag(mdce_mode);
else
    clustermode.ftest_mdce.scheduler.gpu = 0;
end
clustermode.ftest_mdce.scheduler.clustersize = mdce_size;
clustermode.ftest_mdce.scheduler.memory = mdce_memory;
clustermode.ftest_mdce.scheduler.enforce = mdce_enforce;
%
clustermode.ftest_mdce.scheduler.display = 1;
%
dkecluster = clustermode_luke(clustermode,'ftest_mdce',dkepath,schedulertype,mdce_remnum);
%
[flag,a,b] = mdce_luke(@ftest_mdce,{NaN,1,force_error},1,1:mdce_size,dkecluster);
%
disp(['Flag     : ',num2str(flag)]);
disp(['a (2->9) : ',num2str([a{:}])]);
disp(['b (0->7) : ',num2str([b{:}])]);
