%
clear
%
force_error = 1;% 0 (no error), (1) error in batch run only for arg = 5 [cephee only], (2) error in any run for arg = 5,
mdce_mode = 2;%(0) sequential, (2) dcluke distributed
mdce_enforce = 1;%enforce sequential run if distributed computing failed
%
mdce_memory = 100;%memory allocated to batch runs, in MB
mdce_size = 8;
%
[dkepath] = load_structures_yp('dkepath','','');
%
dkecluster = clustermode_luke(mdce_mode,'',0,dkepath.remote,mdce_memory);
dkecluster.size = mdce_size;
dkecluster.enforce = mdce_enforce;%enforce sequential run if distributed computing failed
%
[flag,a,b] = mdce_luke(@ftest_mdce,{NaN,1,force_error},1,1:mdce_size,dkecluster);
%
disp(['Flag     : ',num2str(flag)]);
disp(['a (2->9) : ',num2str([a{:}])]);
disp(['b (0->7) : ',num2str([b{:}])]);
