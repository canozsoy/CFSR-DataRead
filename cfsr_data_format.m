clc
clear
close all
tic

%% INPUTS

stDate=datenum('2017-01-01 00','yyyy-mm-dd HH');                            % ENTER START DATE
endDate=datenum('2018-12-31 23','yyyy-mm-dd HH');                           % ENTER END DATE
timeInc=1/24;                                                               % ENTER TIME INCREMENT
load 31.18N21.07E.mat                                                       % ENTER POINT NAME

%% MAIN CODE

formatOut='yyyymmddHH';
time=stDate:timeInc:endDate;
timeStr=str2num(datestr(time,formatOut));
timeseries(:,1)=timeStr;
timeseries(:,2)=data(:,1);
timeseries(:,3)=data(:,2);
timeseries(:,4)=sqrt(timeseries(:,2).^2+timeseries(:,3).^2);
timeseries(:,5)=atan2(timeseries(:,2),timeseries(:,3)).*(180/pi());
temp=timeseries(:,5);
temp(temp<0)=temp(temp<0)+360;
timeseries(:,7)=temp;
timeseries(:,6)=mod(round(timeseries(:,5)./22.5),16)+9;
temp=timeseries(:,6);
temp(temp>=17)=temp(temp>=17)-16;
timeseries(:,6)=temp;
timeseries(:,7)=(timeseries(:,6)-1)*22.5;
temp=timeseries(:,6);
temp2=timeseries(:,7);
temp2(temp==0)=temp(temp==0);
save('output.mat','timeseries');

toc;




