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
remote.startuppath = [];%path to add for matlab startup
remote.matver = [];% list of matlab bin and corresponding prefdir locations. Ex : matver.mat705.root = '/applications/matlab_2007b/bin/';   matver.mat705.prefdir = '/home/sccp/gsem/decker/.matlab/R2007b';
remote.cvs = [];%CVS commands for code update
remote.password = [];% use if password is necessary (xgrid)
remote.remoteuser = [];% name on the remote cluster
remote.usermail = [];% mail adress of the user on the remote cluster
remote.bridge = [];% bridge address (url or ssh)
remote.link_mode = [];% connection mode prescription : ([]) give priority according to 0,1,2; (0) ssh key pair enforced, (1) ssh bridge enforced, (2) url/ftp bridge enforced
remote.cvsupdate = [];% boolean for cvs update
remote.cvsrights = [];% if not empty, execute command to set up rights after cvs update
remote.funcopy = [];% (-1) do not copy any executable, (0) copy all functions except the matlab function to be run remotely (1) also copy function to be run remotely
remote.condor = [];% condor specific parameters
remote.sge = [];% sun grid engine specific parameters
remote.scheduler = [];%scheduler type (because two identical cmd may correspond to different schedulers)
remote.shell = [];%shell type 
remote.rempause = [];% pause between job checks (in minutes)
%
% The following parameters are for qsub or torque only. Use NaN if option is forbidden 
%
remote.nodes = [];% use if ressources are specified by nodes=?:ppn=? 
remote.select = [];% use if ressources are specified by select=?:ncpus=?
remote.ppn = [];% use if ressources are specified by nodes=?:ppn=? 
remote.ncpus = [];% use if ressources are specified by ncpus=?
remote.walltime = [];% use if walltime necessary or one hour imposed
remote.wait = [];% use to specify if musy wait for job completion
remote.memory = [];% [a,b] or [b] where "a" is the default value and "b" is the max value (in mb)
remote.shclean = [];% use for job output file syntax (put '0' if .sh appears in job output files)
remote.queue = [];% queue mode
