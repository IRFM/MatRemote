function [res,txt] = matremoteput(remote,job)
%
% upload batch dir to the remote computer (through the bridge)
%
if ~isempty(remote.host),       
    %
    if remote.link_mode > 0,
        %        
        [res1,txt1] = upload2bridge(remote,job);%file transfer from the client to the bridge
        %
        [res2,txt2] = bridge2remote(remote,job);%file transfer from the bridge to the remote
        %
        txt = strcat(txt1,';',txt2);
        %
        res = res1*res2;
    else
        [res,txt] = scp2remote_yp(remote.remoteuser,remote.host,job.save_id,job.localdatapath,job.remotedatapath);%transfer data from the local batch dir to the remote batch dir
        %
    end
    %
elseif ~strcmp(job.localdatapath,job.remotedatapath),
    %	
    if strcmp(job.save_id(end),filesep),% to avoid cp problems on MAC OSX
        save_id = job.save_id(1:end-1);
    else
        save_id = job.save_id;
    end
    %
    [res,txt] = unix(['cp -r ',job.localdatapath,save_id,' ',job.remotedatapath]);%transfer data from the local batch dir to the local batch dir
    %
else
    res = 0;
    txt = '';
end
%
