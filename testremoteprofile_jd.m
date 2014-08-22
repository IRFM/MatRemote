function remote = testremoteprofile_jd(remote,link_mode,test,display_mode)
%
% This function tests connections for the remote profile 'remote'.
%
%   Inputs :
%       - remote : input remote structure
%       - link_mode : connection mode prescription
%           o NaN : (default) use value from remote.link_mode
%           o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
%           o 0   : ssh key pair enforced, or test fails
%           o 1   : ssh bridge enforced, or test fails
%           o 2   : url/ftp bridge enforced, or test fails
%       - test : (false/true) flag for testing connection (default = true)
%       - display_mode : (0) no display, (2) display test results
%
%   Outputs :
%       - remote : input remote structure
%           o If test OK     : remote.link_mode is specified (0,1 or 2) according to test results and priorities
%           o If test not OK : return empty profile
%
if nargin < 4,
    display_mode = 0;
end
if nargin < 3,
    test = true;
end
if nargin < 2,
    link_mode = NaN;%use value from remote.link_mode
end
if isempty(link_mode) || ~isnan(link_mode),% remote.link_mode enforced by input
    remote.link_mode = link_mode;
end
%
xgridsearch = iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'xgrid')));
%
if xgridsearch, 
    if ~isempty(getenv('XGRID_PWD')),
        remote.password = getenv('XGRID_PWD');
    else
        locdisp(display_mode,'Remote connection test failed : XGRID password not set up. Create an environment variable ''XGRID_PWD''.')
        %
        remote = [];
        return
    end
end
%
if isempty(remote.host), %local calculation
    if ~isempty(remote.link_mode),% local host not compatible with enforced link mode
        locdisp(display_mode,'Remote connection test failed : local host not compatible with enforced link mode.')
        %
        remote = [];% no connection mode without host
        %
    else
        locdisp(display_mode,'Remote connection test skipped : local calculation.')
    end
    %
    return
end
%
remotecmd = 'echo test ok';
%
% test ssh key-pair connection
%
if isempty(remote.link_mode) || remote.link_mode == 0,
    if test,% test ssh key-pair connection
        locdisp(display_mode,['Testing ssh key pair connection to ',remote.remoteuser,'@',remote.host,' ... '])
        %
        remote.sshopts = '-o ConnectTimeout=10 -o BatchMode=yes';
        %
        [res,txt] = unix(['ssh ',remote.sshopts,' ',remote.remoteuser,'@',remote.host,' ''',remotecmd,'''']);%execute the remote command by ssh   
        %
        if res ~= 0,
            if any(strfind(txt,'Connection timed out')),
                msg = 'failed : connection timed out (10s)';
            elseif any(strfind(txt,'Permission denied')) || any(strfind(txt,'Host key verification failed')),
                msg = 'failed : ssh key pairing not set up or not working';
            else
                msg = ['failed with following message : ',txt];            
            end
            %
            locdisp(display_mode,['   ... ',msg])
        else
            locdisp(display_mode,['   ... completed with following result : ',txt])
            locdisp(display_mode,' ---> ssh key-pair mode selected')
            %
            remote.link_mode = 0;% ssh key-pair mode selected
            return
        end
    else
        return
    end        
end
%
% test ssh bridge connection
%
if (isempty(remote.link_mode) || remote.link_mode == 1),
    if isfield(remote.bridge,'ssh') && isfield(remote.bridge.ssh,'host') && ~isempty(remote.bridge.ssh.host),
        if test,% test ssh bridge connection
            locdisp(display_mode,['Testing bridge connection (ssh) to ',remote.host,' via ',remote.bridge.ssh.host,' ... '])
            %
            [txt,res] = matremotessh(remote,'ls');
            %
            if res ~= 0,
                locdisp(display_mode,['   ... failed with following message : ',txt])
            else
                locdisp(display_mode,'   ... completed with following result : test ok')
                locdisp(display_mode,' ---> ssh bridge mode selected')
                %
                remote.link_mode = 1;% ssh bridge mode selected
                return
            end    
        else
            remote.link_mode = 1;% ssh bridge mode selected
            return
        end            
    else
        locdisp(display_mode,'ssh bridge mode connection not set up.')
    end
end
%
% test url/ftp bridge connection
%
if (isempty(remote.link_mode) || remote.link_mode == 2),
    if isfield(remote.bridge,'url') && isfield(remote.bridge.url,'host') && ~isempty(remote.bridge.url.host) &&...
       isfield(remote.bridge,'ftp') && isfield(remote.bridge.ftp,'host') && ~isempty(remote.bridge.ftp.host),% test bridge connection via url/ftp
        %
        if test,
            locdisp(display_mode,['Testing bridge connection (url/ftp) to ',remote.host,' via ',remote.bridge.url.host,' ... '])
            %
            [txt,res] = matremoteurl(remote,'','ls','');
            %
            if res == 0,
                locdisp(display_mode,['   ... failed with following message : ',txt])
            else
                locdisp(display_mode,'   ... completed with following result : test ok')
                locdisp(display_mode,' ---> url/ftp bridge mode selected')
                %
                remote.link_mode = 2;% ssh bridge mode selected
                return
            end    
        else
            remote.link_mode = 2;% ssh bridge mode selected
            return
        end
    else
        locdisp(display_mode,'url/ftp bridge mode connection not set up.')
    end
end
% 
% no valid connection mode
%
if isempty(remote.link_mode),
    msg = 'ssh key-pair, ssh bridge and url/ftp bridge modes not set up, or test failed.';
elseif remote.link_mode == 0,
    msg = 'ssh key-pair mode not set up, or test failed.';
elseif remote.link_mode == 1,
    msg = 'ssh bridge mode not set up, or test failed.';
elseif remote.link_mode == 2,
    msg = 'url/ftp bridge mode not set up, or test failed.';
end   
locdisp(display_mode,['Remote connection test failed : ',msg])
%
remote = [];
return
%
%
function locdisp(mode,s)
%
if mode > 1,
    disp(' ');
    disp(s)
end

