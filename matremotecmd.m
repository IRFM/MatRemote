function [res,txt] = matremotecmd(remote,remotecmd)
%
if isfield(remote,'url'),
    %
    % TODO    
    %
elseif isfield(remote,'remote'),
    %
    % TODO    
    %
else
    %
    if ~isempty(remote.host),
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);
    else
        [res,txt] = unix(remotecmd);
    end
    %
end   
%
