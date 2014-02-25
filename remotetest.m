function dataout = remotetest(datain)
%
testvar = getenv('TESTVAR');
%
dataout.strout = [datain.strin,testvar,' - running under matlab version : ',version];
%
pause(20)
%
