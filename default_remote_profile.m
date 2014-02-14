function remote = default_remote_profile
%
remote.host = [];% adress of host. Ex : cephee15.intra.cea.fr
remote.hostname = [];% local name of host (from hostname -f command)
remote.sshopts = '';% ssh options
remote.nproc = [];% maximum number of processors. Ex : 48    
remote.cmd = [];% job submit command. Ex : qsub
remote.get_jobid = [];% syntax to read job number {str_before,str_after}. Ex : {'','.cephee'}
remote.set_jobid = [];% syntax to test job status {command,str_after,completed job tag}. Ex : {'qstat ','.cephee','Unknown Job Id'}
remote.env = [];% additional environment variables. Ex : env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}'
remote.remotedatapath = [];% path to save transfered data on remote cluster. Ex : '/Users/yvespeysson/condor/' 
remote.matver = [];% list of matlab bin and corresponding prefdir locations. Ex : matver.mat705.root = '/applications/matlab_2007b/bin/';   matver.mat705.prefdir = '/home/sccp/gsem/decker/.matlab/R2007b';
remote.cvs = [];%CVS commands for code update
remote.password = {};% use if password is necessary (xgrid)
remote.remoteuser = [];% name on the remote cluster
remote.bridge = [];% bridge address (url or ssh)
%
% The following parameters are for qsub only. Use NaN if option is forbidden 
%
remote.nodes = [];% use if ressources are specified by nodes=?:ppn=? 
remote.ppn = [];% use if ressources are specified by nodes=?:ppn=? 
remote.ncpus = [];% use if ressources are specified by ncpus=?
remote.walltime = [];% use if walltime necessary or one hour imposed
remote.wait = [];% use to specify if musy wait for job completion
remote.memory = [];% use to limit the maximum memory per job
remote.shclean = [];% use for job output file syntax (put '0' if .sh appears in job output files)

