function [ip,id] = connections_params(user)
%
% by Y. Peysson IRFM-CEA <yves.peysson@cea.fr>
%
[~,hostname] = unix('hostname');
[~,whoami] = unix('whoami');
%
ip = deblank(hostname);
id = deblank(whoami);
%
if nargin > 0
    %
    % Uncomment the lines below to customize internet access
    %
    %if strcmp(user,'user')
    %    id = {'hostname1','hostname2'};%hostname
    %    ip = {'IP1','IP2'};%address
    %end
    %
    % Add 
    %
end
%