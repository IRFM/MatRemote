function test_allmdce(remote,debugmode,link_mode,displaymode)
%
% This function tests the MDCE toolbox
%
% INPUTS : 
%
%   - remote : 
% (default)	o ('local') : idendify and return local cluster
%           o (NaN)     : load all profiles and ask for user selection 
%           o (struct)  : profile contained in structure 'remote' 
%           o (string)  : identification of profile to be selected as remote_(string).m 
%           o ('')      : load & return all profiles 
%
%   - debugmode 
% (default)	o (0) no debug info
%           o (1) provides step by step information, and save diary file in remote job folder
%
%   - link_mode : connection mode prescription
% (default)	o NaN : use value from remote.link_mode
%           o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
%           o 0   : ssh key pair enforced
%           o 1   : ssh bridge enforced
%           o 2   : url/ftp bridge enforced
%
%   - displaymode : 
%           o (0) display results only, 
% (default)	o (1) display job status evolution 
%           o (2) display step by step
%

if nargin < 4,
    displaymode = 1;% display job status evolution 
end
%
if nargin < 3,
    link_mode = NaN;% use value from remote.link_mode
end
%
if nargin < 2,
    debugmode = 0;% default mode is direct use of remoterunbatch and remotegetbatch
end
%
if nargin < 1,
    remote = 'local';% test all profiles
end
%
force_error = 0;
mdce_enforce = 0;
schedulertype = 'local';
mdce_size = 8;
mdce_memory = 200;%MB
%
if isempty(link_mode)
    link_modestr = '_empty_link_mode';
    link_modestr2 = 'empty link mode';
elseif isnan(link_mode),
    link_modestr = '_link_mode_NaN';
    link_modestr2 = 'link mode = NaN';
else
    link_modestr = ['_link_mode_',num2str(link_mode)];
    link_modestr2 = ['link mode = ',num2str(link_mode)];
end
%
testdate = datestr(now,29);
%
diaryname = ['res_testallmdce_',matversion_yp,'_',testdate,link_modestr,'.log'];
%
if input_dke_yp(['Do you want to save the results in the log file ',diaryname,' ? (y/n)'],'y',{'y','n'}) == 'y',
    %
    if exist(diaryname,'file'),
        delete(diaryname);
    end
    %
    diary(diaryname);
    %
else
    diaryname = '';
end
%
disp(' ');
disp('-------------------------------------------------------------------')
disp('                     TEST MDCE');
disp(' ');
disp([' test on ',testdate,' with ',link_modestr2,' from guest ',hostname_jd,' running Matlab version ',version]);
disp(' ');
disp('-------------------------------------------------------------------')
disp(' ');
%
% Select local and remote profiles to be tested
%
[remoteprofiles,profilestr] = load_remoteprofiles_jd(remote,true,true,NaN,NaN,true,debugmode,link_mode);
%
nrem = length(remoteprofiles);
%
locflag = NaN(3,1);
remflag = NaN(5,nrem); 
%
disp(' ');
disp('-------------------------------------------------------------------')
disp(' ---> Testing local MDCE');
disp('-------------------------------------------------------------------')
disp(' ');
%
disp(' -> test sequential calculations');
disp(' ');
locflag(1) = test_mdce(0,{},force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode);
disp(' ');
%
disp(' -> test jobcomputing calculations');
disp(' ');
locflag(2) = test_mdce(1,{},force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode);
disp(' ');
%
disp(' -> test parcomputing calculations');
disp(' ');
locflag(3) = test_mdce(2,{},force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode);
disp(' ');
%
for irem = 1:nrem,
    %
    disp(' ');
    disp('-------------------------------------------------------------------')
    disp([' ---> Testing profile [',profilestr{irem},']']);
    disp('-------------------------------------------------------------------')
    disp(' ');
    %
    remote = remoteprofiles(irem);
    %
    disp([' -> test remcomputing calculations towards machine',profilestr{irem}]);
    disp(' ');
    remflag(1,irem) = test_mdce(remote,{},force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode);
    disp(' ');
    %
    disp([' -> test sequential calculations on machine',profilestr{irem}]);
    disp(' ');
    remflag(2,irem) = test_mdce(0,{remote},force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode);
    disp(' ');
    %
    disp([' -> test jobcomputing calculations on machine',profilestr{irem}]);
    disp(' ');
    remflag(3,irem) = test_mdce(1,{remote},force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode);
    disp(' ');
    %
    disp([' -> test parcomputing calculations on machine',profilestr{irem}]);
    disp(' ');
    remflag(4,irem) = test_mdce(2,{remote},force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode);
    %
    disp([' -> test remcomputing calculations on machine',profilestr{irem}]);
    disp(' ');
    remflag(5,irem) = test_mdce(3,{remote},force_error,mdce_enforce,schedulertype,mdce_size,mdce_memory,debugmode,displaymode);
    disp(' ');
    %
end
%
disp(' ');
disp('-------------------------------------------------------------------')
disp(' ---> RESULTS (flags)');
disp('-------------------------------------------------------------------')
disp(' ');
disp(' Local MDCE [mode,1]');
disp(' ');
disp(locflag);
disp(' ');
disp(' Remote MDCE with remcomputing [1,remprofile]');
disp(' ');
disp(remflag(1,:));
disp(' ');
disp(' Remote MDCE with mdce_remote [mode,remprofile]');
disp(' ');
disp(remflag(2:5,:));
%
if ~isempty(diaryname),
    diary off
end







