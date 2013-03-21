function job = remote2job_jd(remote,job)
% Job parameters can be imposed by remote, either for optimization,
% limitations, or to avoid forbidden commands for cluster
%
% General rule :
%
%   If field left empty, left to user or enforced to default
%   If field is NAN, ignored in command
% 
% ALL PROTOCOLS
%
if isfield(remote,'remotedatapath') && ~isempty(remote.remotedatapath),
    job.remotedatapath = remote.remotedatapath;
elseif ~isfield(job,'remotedatapath'),
    job.remotedatapath = '';
end
%
% PBS and TORQUE only
%
if isfield(remote,'wait') && ~isempty(remote.wait),
    job.wait = remote.wait;%(0) return hand (1) wait for result
elseif ~isfield(job,'wait'),
    job.wait = 0;
end
%
if isfield(remote,'nodes') && ~isempty(remote.nodes), 
    job.nodes = remote.nodes;%Number of nodes required by remote cluster  
elseif ~isfield(job,'nodes'),
    job.nodes = 1;
end
%
if isfield(remote,'ppn') && ~isempty(remote.ppn), 
    job.ppn = remote.ppn;%Number of nodes required by remote cluster  
elseif ~isfield(job,'ppn') && isfield(job,'ncpus'),
    job.ppn = job.ncpus;
else
    job.ppn = 1;
end
%
if isfield(remote,'ncpus') && ~isempty(remote.ncpus), 
    job.ncpus = remote.ncpus;%Number of nodes required by remote cluster  
elseif ~isfield(job,'ncpus') && isfield(job,'ppn'),
    job.ncpus = job.ppn;
else
    job.ppn = 1;
end
%
if isfield(remote,'walltime') && ~isempty(remote.walltime),% time required (integers - in hours) - leave empty if no requirement
    job.walltime = remote.walltime;
elseif ~isfield(job,'walltime'),
    job.walltime = 1;
end
%
if isfield(remote,'memory') && ~isempty(remote.memory),
    job.memory = remote.memory;% requested memory specified in dkeparam
elseif ~isfield(job,'memory'),
    job.memory = 500;
end
%
