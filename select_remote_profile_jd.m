function remote_profile = select_remote_profile_jd(remote,default,schedulername,profilename)
%
% the scheduler and profile names specified as inputs are selected.
% if these are not specified or nonexistant, default values are selected.
% if these are NaN, all values are selected
%
% select scheduler name(s)
%
if nargin < 3 || (ischar(schedulername) && ~isfield(remote,schedulername)),
    schedulername = default.scheduler;% default schedulername
end
%
if isnan(schedulername),% select all schedulernames
    schedulernames = fieldnames(remote);
else
    schedulernames = {schedulername};
end
%
% select profile name(s)
% 
nschedulers = length(schedulernames);
profilenames = cell(1,nschedulers);
for ischeduler = 1:nschedulers,
    fnames = fieldnames(remote.(schedulernames{ischeduler}));
    if nargin < 4,
        profilenames{ischeduler}{1} = default.profile;% default profile name
    elseif ~ischar(profilename),
        profilenames{ischeduler} = fnames;% all profile names
    elseif isfield(remote.(schedulernames{ischeduler}),profilename)
        profilenames{ischeduler}{1} = profilename;% specific profile name
    elseif ischar(profilename) && strcmp(profilename,'local'),% select local user
        profilenames{ischeduler}{1} = default.profile;% default profile name if no remoteuser match
        for iname = 1:length(fnames),
            if strcmp(remote.(schedulernames{ischeduler}).(fnames{iname}).remoteuser,getenv('USER')),
                profilenames{ischeduler}{1} = fnames{iname};% local user profile name
                break
            end
        end        
    else
        profilenames{ischeduler}{1} = default.profile;% default profile name
    end
end
%
% make remote profiles list
%
irem = 0;
for ischeduler = 1:nschedulers,
    for iprofile = 1:length(profilenames{ischeduler}),
        irem = irem + 1;
        remote_profile(irem) = remote.(schedulernames{ischeduler}).(profilenames{ischeduler}{iprofile});
        %
    end
end


