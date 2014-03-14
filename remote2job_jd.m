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
if isfield(remote,'startuppath') && ~isempty(remote.startuppath),% path for startup
    job.env.MATLABPATH = remote.startuppath;
end
%
if isfield(remote,'debugmode'),
    job.debugmode = remote.debugmode;
elseif ~isfield(job,'debugmode'),
    job.debugmode = 0;
end
%
if isfield(remote,'clean') && ~isempty(remote.clean),
    job.clean = remote.clean;
elseif ~isfield(job,'clean'),
    job.clean = 2;
end
%
if isfield(remote,'funcopy') && ~isempty(remote.funcopy),
    job.funcopy = remote.funcopy;
elseif ~isfield(job,'funcopy'),
    job.funcopy = 0;
end
%
if isfield(remote,'bridge_enforce') && ~isempty(remote.bridge_enforce),
    job.bridge_enforce = remote.bridge_enforce;
elseif ~isfield(job,'bridge_enforce'),
    job.bridge_enforce = false;
end
%
if isfield(remote,'env') && ~isempty(remote.env),
    job.env = conc_struct_jd(job.env,remote.env);
end
%
% XGRID only
%
if isfield(remote,'hostname') && ~isempty(remote.hostname),
    job.hostname = remote.hostname;
elseif ~isfield(job,'hostname'),
    job.hostname = '';
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
if isfield(remote,'select') && ~isempty(remote.select), 
    job.select = remote.select;%Number of nodes required by remote cluster  
elseif ~isfield(job,'select'),
    job.select = 1;
end
%
if isfield(remote,'ppn') && ~isempty(remote.ppn), 
    job.ppn = remote.ppn;%Number of nodes required by remote cluster  
elseif ~isfield(job,'ppn') 
    if isfield(job,'ncpus'),
        job.ppn = job.ncpus;
    else
        job.ppn = 1;
    end
end
%
if isfield(remote,'ncpus') && ~isempty(remote.ncpus), 
    job.ncpus = remote.ncpus;%Number of nodes required by remote cluster  
elseif ~isfield(job,'ncpus')
    if isfield(job,'ppn'),
        job.ncpus = job.ppn;
    else
        job.ppn = 1;
    end
end
%
if isfield(remote,'walltime') && ~isempty(remote.walltime),% time required (integers - in hours) - leave empty if no requirement
    job.walltime = remote.walltime;
elseif ~isfield(job,'walltime'),
    job.walltime = 1;
end
%
if ~isfield(job,'memory'),
    job.memory = [];% default value in mb
end
if isfield(remote,'memory') && ~isempty(remote.memory),
    if any(isnan(remote.memory)),
        job.memory = NaN;
    elseif ~isempty(job.memory) && remote.memory(end) < job.memory,% remote(end) is max memory on remote computer
        disp('WARNING : memory request limited by remote host')
        job.memory = remote.memory(end);
    elseif isempty(job.memory) && length(remote.memory) > 1,% remote(1) is default memory on remote computer
        job.memory = remote.memory(1);
    end
end
%
if isfield(remote,'remtimout') && ~isempty(remote.remtimout), 
    job.remtimout = remote.remtimout;%Number of nodes required by remote cluster  
elseif ~isfield(job,'remtimout')
    job.remtimout = Inf;
end
%
if isfield(remote,'rempause') && ~isempty(remote.rempause), 
    job.rempause = remote.rempause;%Number of nodes required by remote cluster  
elseif ~isfield(job,'rempause')
    job.rempause = 1/6;
end
%
