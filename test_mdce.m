function test_mdce(mdce_mode,force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,dkepath)
%
%Test function of the distributed computing calculation 
%
%   INPUT :
%
%       - mdce_mode: distributed computing environment state: (0) disabled, (1) enabled with the dedicated Matlab toolbox which must be installed, (2) enabled with a private method (LDCE), (3) parfor parallel computing [1,1]
%           (default = 1)
%       - force_error: force an error to check how a possible error in calculation is managed, 0 (no error), (1) error in batch run only for arg = 5, (2) error in any run for arg = 5 [1,1]
%           (default = 1)
%       - mdce_enforce: (1) enforce sequential run if distributed computing failed, (0) otherwise [1,1]
%           (default = 1)
%       - schedulertype: type of scheduler, '' or 'local' for any machine or cluster,'pbspro' for CEPHEE or SATURNE cluster,'xgrid' on mac computers,... [1,1]
%           (default = 'local')
%       - mdce_size: cluster size. Use the maximum of processor available for calculations [1,1]
%           (default = 8)
%       - mdce_memory: memory allocated to batch runs, in MBytes (200 for pbspro scheduler on CEPHEE cluster) [1,1]
%           (default = NaN)
%       - dkepath: path structure of LUKE
%           (automatic load in ~/LUKE/Project_DKE/Database/PATH_files/)
%   OUTPUT : none
%
% by J. Decker DRFC-CEA <joan.decker@cea.fr>  and Y. Peysson DRFC-CEA <yves.peysson@cea.fr>
%
if nargin < 1,
    mdce_mode = 1;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
    force_error = 1;% 0 (no error), (1) error in batch run only for arg = 5, (2) error in any run for arg = 5,
    mdce_enforce = 1;
    schedulertype = 'local';%'' or 'local','pbspro','xgrid','condor',...
	mdce_size = 8;
    mdce_memory = NaN;
    dkepath = load_structures_yp('dkepath','','');
end
%
if nargin == 1,
    force_error = 1;% 0 (no error), (1) error in batch run only for arg = 5, (2) error in any run for arg = 5,
    mdce_enforce = 1;
    schedulertype = 'local';%'' or 'local','pbspro','xgrid','condor',...
	mdce_size = 8;
    mdce_memory = NaN;
    dkepath = load_structures_yp('dkepath','','');
end
if nargin < 3,
    schedulertype = 'local';%'pbspro';%
end
%
if nargin == 2,
    mdce_enforce = 1;
    schedulertype = 'local';%'' or 'local','pbspro','xgrid','condor',...
	mdce_size = 8;
    mdce_memory = NaN;
    dkepath = load_structures_yp('dkepath','','');
end
%
if nargin == 3,
    schedulertype = 'local';%'' or 'local','pbspro','xgrid','condor',...
	mdce_size = 8;
    mdce_memory = NaN;
    dkepath = load_structures_yp('dkepath','','');
end
%
if nargin == 4,
	mdce_size = 8;
    mdce_memory = NaN;
    dkepath = load_structures_yp('dkepath','','');
end
%
if nargin == 5,
    mdce_memory = NaN;
    dkepath = load_structures_yp('dkepath','','');
end
%
if nargin == 6,
    dkepath = load_structures_yp('dkepath','','');
end
%
clustermode.ftest_mdce.scheduler.mode = mdce_mode;
clustermode.ftest_mdce.scheduler.clustersize = mdce_size;
clustermode.ftest_mdce.scheduler.memory = mdce_memory;
clustermode.ftest_mdce.scheduler.enforce = mdce_enforce;
%
dkecluster = clustermode_luke(clustermode,'ftest_mdce',dkepath,schedulertype);
%
[flag,a,b] = mdce_luke(@ftest_mdce,{NaN,1,force_error},1,1:mdce_size,dkecluster);
%
disp(['Flag     : ',num2str(flag)]);
disp(['a (2->9) : ',num2str([a{:}])]);
disp(['b (0->7) : ',num2str([b{:}])]);
