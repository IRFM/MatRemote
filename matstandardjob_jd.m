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
if isfield(remote,'scriptcopy'),
    job.scriptcopy = remote.scriptcopy;% copy the distributed function script to the worker
else
    job.scriptcopy = true;
end
%
