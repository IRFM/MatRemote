% 
% /////////////////////////////////////////
%
% Software name : MatRemote, part of LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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