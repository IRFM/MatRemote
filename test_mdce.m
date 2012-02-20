function test_mdce(mdce_mode,dkepath,schedulertype)
%
if nargin < 1,
    mdce_mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
end
if nargin < 2,
    dkepath = load_structures_yp('dkepath','','');
end
if nargin < 3,
    schedulertype = 'local';%'pbspro';%
end
%
force_error = 1;% 0 (no error), (1) error in batch run only for arg = 5 [cephee only], (2) error in any run for arg = 5,
%
mdce_size = 8;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
mdce_memory = 200;%memory allocated to batch runs, in MB
mdce_enforce = 1;%enforce sequential run if distributed computing failed
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
