function job = matstandardjob_jd(remote,remotematfnc)
%
% Standard preparation for remote matlab job
%
job.env.luke_root = remote.luke_root;% luke path environment
job.env.remotematfnc = remotematfnc;
%
if isfield(remote,'hostname'),
    job.env.hostname = remote.hostname;% case where hostname needs to be passed on as variable
end
%
job.script = [job.env.luke_root,filesep,'Tools/matlablukebatch.sh'];
%
job.savefcn = 'matstandardsave';%'runlukesave';%
job.loadfcn = 'matstandardload';%'runlukeload';%
job.localdatapath = '';
%
% Job parameters can be imposed by remote
%
if isfield(remote,'remotedatapath') && ~isempty(remote.remotedatapath),
    job.remotedatapath = remote.remotedatapath;
else
    job.remotedatapath = '';
end
%
if isfield(remote,'wait'),% (0) return hand (1) wait for result
    job.wait = remote.wait;
else
    job.wait = 0;
end
%
if isfield(remote,'nodes'),%number of nodes required
    job.nodes = remote.nodes;
else
    job.nodes = 1;
end
%
if isfield(remote,'ppn'),%number of cores required
    job.ppn = remote.ppn;
else
    job.ppn = 2;
end
%
if isfield(remote,'walltime'),% time required (integers - in hours) - leave empty if no requirement
    job.walltime = remote.walltime;
else
    job.walltime = [];
end
%
if isfield(remote,'memory'),
    job.memory = remote.memory;% requested memory specified in dkeparam
else
    job.memory = [];
end
%

