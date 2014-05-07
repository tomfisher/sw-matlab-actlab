function [channel1,channel2,channel3,time,frequency] = xlsconverterplus(filename) 
%samplecall: [channel1,channel2,channel3,time,frequency] = xlsconverterplus('Marcel_water_20060607.xls');
%dir = 'D:\Daten\ETH\Studienarbeit\Dehnungssensor\Messungen\07.06.2006'; %enter local data directory here

[dir filename] = fileparts(filename);

format long 
time = xlsread([dir,filesep,filename],'C1:IV1');
channel1 = xlsread([dir,filesep,filename],'C2:IV2');
channel2 = xlsread([dir,filesep,filename],'C3:IV3');
channel3 = xlsread([dir,filesep,filename],'C4:IV4');

j = '7';
for i= 0:38,
    time = [time,xlsread([dir,filesep,filename],['B',j,':IV',j])];
    channel1 = [channel1,xlsread([dir,filesep,filename],['B',int2str(strread(j)+1),':IV',int2str(strread(j)+1)])];
    channel2 = [channel2,xlsread([dir,filesep,filename],['B',int2str(strread(j)+2),':IV',int2str(strread(j)+2)])];
    channel3 = [channel3,xlsread([dir,filesep,filename],['B',int2str(strread(j)+3),':IV',int2str(strread(j)+3)])];
    j = int2str(strread(j)+6);
end

frequency = 10199/time(10199); %just a mean value cause of small machine-sample-rate deviations
format short
