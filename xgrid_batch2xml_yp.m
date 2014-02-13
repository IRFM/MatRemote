function [filename] = xgrid_batch2xml_yp(job)
%
%LUKE - This function creates dynamically the xml batch file for remote
%calculations on a Mac cluster with Xgrid scheduler (can generate multiple
%jobs under the same timeid)
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
key = 0;%first job
%
filename = ['xgrid_batch_matlab_',job.timeid,'.plist'];
fileid = fopen([job.localdatapath,job.batch_dir,filename],'w');
%
env = fieldnames(rmfield(job.env,{'remotebatch_matlabprefdir'}));%fixed syntax imposed by Matlab for prefdir, see below
%
fprintf(fileid,['<?xml version="1.0" encoding="UTF-8"?>','\n']);
fprintf(fileid,['<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">','\n']);
fprintf(fileid,['<plist version="1.0">','\n']);
fprintf(fileid,['<array>','\n']);
fprintf(fileid,['	<dict>','\n']);
fprintf(fileid,['		<key>name</key>','\n']);
fprintf(fileid,['		<string>matlab_job_',job.timeid,'</string>','\n']);
fprintf(fileid,['		<key>taskSpecifications</key>','\n']);
fprintf(fileid,['		<dict>','\n']);
fprintf(fileid,['			<key>',int2str(key),'</key>','\n']);
fprintf(fileid,['			<dict>','\n']);
fprintf(fileid,['				<key>arguments</key>','\n']);
fprintf(fileid,['				<array>','\n']);
fprintf(fileid,['					<string>',job.remotedatapath,job.batch_dir,job.script,'</string>','\n']);
fprintf(fileid,['				</array>','\n']);
fprintf(fileid,['				<key>command</key>','\n']);
fprintf(fileid,['				<string>/bin/sh</string>','\n']);
fprintf(fileid,['				<key>environment</key>','\n']);
fprintf(fileid,['				<dict>','\n']);
%
for ienv = 1:length(env),
    fprintf(fileid,['					<key>',env{ienv},'</key>','\n']);
    fprintf(fileid,['					<string>',job.env.(env{ienv}),'</string>','\n']);
end
%
fprintf(fileid,['					<key>jobtimeid</key>','\n']);
fprintf(fileid,['					<string>',job.timeid,'</string>','\n']);
fprintf(fileid,['					<key>debugmode</key>','\n']);
fprintf(fileid,['					<string>',num2str(job.debugmode),'</string>','\n']);
fprintf(fileid,['					<key>hostname</key>','\n']);
fprintf(fileid,['					<string>',job.hostname,'</string>','\n']);
fprintf(fileid,['					<key>remotebatchdir</key>','\n']);
fprintf(fileid,['					<string>',job.remotedatapath,job.batch_dir,'</string>','\n']);
fprintf(fileid,['					<key>MATLAB_PREFDIR</key>','\n']);
fprintf(fileid,['					<string>',job.env.remotebatch_matlabprefdir,'</string>','\n']);
fprintf(fileid,['				</dict>','\n']);
fprintf(fileid,['			</dict>','\n']);
fprintf(fileid,['		</dict>','\n']);
fprintf(fileid,['	</dict>','\n']);
fprintf(fileid,['</array>','\n']);
fprintf(fileid,['</plist>','\n']);
%
fclose(fileid);