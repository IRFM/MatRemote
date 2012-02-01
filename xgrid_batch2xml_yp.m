function [filename] = xgrid_batch2xml_yp(luketimeid,appid,jobname,userid,matlabroot,remoteprefdir,lukepath,lukedatapath,hostname,key)
%
%LUKE - This function creates dynamically the xml batch file for remote
%calculations on a Mac cluster with Xgrid scheduler (can generate multiple
%jobs under the same timeid)
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 9,error('Not enough input arguments in xgrid_batch2xml_yp.m');end
%
if nargin < 10,
    key = 0;%first job
end
%
filename = ['xgrid_batch_matlab_',luketimeid,'.plist'];
fileid = fopen(filename,'w');
%
fprintf(fileid,['<?xml version="1.0" encoding="UTF-8"?>','\n']);
fprintf(fileid,['<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">','\n']);
fprintf(fileid,['<plist version="1.0">','\n']);
fprintf(fileid,['<array>','\n']);
fprintf(fileid,['	<dict>','\n']);
fprintf(fileid,['		<key>applicationIdentifier</key>','\n']);
fprintf(fileid,['		<string>',appid,'</string>','\n']);
fprintf(fileid,['		<key>name</key>','\n']);
fprintf(fileid,['		<string>',jobname,'</string>','\n']);
fprintf(fileid,['		<key>submissionIdentifier</key>','\n']);
fprintf(fileid,['		<string>',userid,'</string>','\n']);
fprintf(fileid,['		<key>taskSpecifications</key>','\n']);
fprintf(fileid,['		<dict>','\n']);
fprintf(fileid,['			<key>',int2str(key),'</key>','\n']);
fprintf(fileid,['			<dict>','\n']);
fprintf(fileid,['				<key>arguments</key>','\n']);
fprintf(fileid,['				<array>','\n']);
fprintf(fileid,['					<string>',lukepath,'mrunluke_batch_xgrid.sh</string>','\n']);
fprintf(fileid,['				</array>','\n']);
fprintf(fileid,['				<key>command</key>','\n']);
fprintf(fileid,['				<string>/bin/sh</string>','\n']);
fprintf(fileid,['				<key>environment</key>','\n']);
fprintf(fileid,['				<dict>','\n']);
fprintf(fileid,['					<key>LUKE_timeid</key>','\n']);
fprintf(fileid,['					<string>',luketimeid,'</string>','\n']);
fprintf(fileid,['					<key>LUKE_path</key>','\n']);
fprintf(fileid,['					<string>',lukepath,'</string>','\n']);
fprintf(fileid,['					<key>LUKE_matlabroot</key>','\n']);
fprintf(fileid,['					<string>',matlabroot,'</string>','\n']);
fprintf(fileid,['					<key>USER</key>','\n']);
fprintf(fileid,['					<string>',userid,'</string>','\n']);
fprintf(fileid,['					<key>LUKE_datapath</key>','\n']);
fprintf(fileid,['					<string>',lukedatapath,'</string>','\n']);
fprintf(fileid,['					<key>LUKE_hostname</key>','\n']);
fprintf(fileid,['					<string>',hostname,'</string>','\n']);
fprintf(fileid,['					<key>LUKE_xgrid</key>','\n']);
fprintf(fileid,['					<string>1</string>','\n']);
fprintf(fileid,['					<key>MATLAB_PREFDIR</key>','\n']);
fprintf(fileid,['					<string>',remoteprefdir,'</string>','\n']);
fprintf(fileid,['				</dict>','\n']);
fprintf(fileid,['			</dict>','\n']);
fprintf(fileid,['		</dict>','\n']);
fprintf(fileid,['	</dict>','\n']);
fprintf(fileid,['</array>','\n']);
fprintf(fileid,['</plist>','\n']);
%
fclose(fileid);