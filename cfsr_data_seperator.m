clc
clear
close all
tic

%% INPUTS -- OPTIONS

dataType=1;                                                                 % (1): SINGLE VARIABLE (2): MULTIPLE VARIABLES
varName1='u10';                                                             % ENTER VARIABLE NAME 1 (PANOPLY CAN BE USED TO LOOK FOR THE NAME OR MATLAB CODES CAN BE USED)
varName2='v10';                                                             % ENTER VARIABLE NAME 2 (IF NOT EXIST USE '')

%% INPUTS -- SINGLE FILE

fileName = 'singleFileExample.nc';                                                    % ENTER FILENAME IF SINGLE FILE

%% INPUTS -- MULTIPLE FILE

fileNameFormat='wnd10m.cdas1.%d%02d.grb2.nc';                               % ENTER FILENAME IF THE FILENAME FORMAT IF MULTIPLE FILES
dataNum=22;                                                                 % DATA NUMBER IN ONE DAY
stDate=2016;                                                                % ENTER START DATE FOR MULTIPLE FILES
endDate=2018;                                                               % ENTER END DATE FOR MULTIPLE FILES
stMonth=1;
endMonth=12;

%% MAIN CODE

kk=1;
switch dataType
    case 1
        u = ncread(fileName, varName1);
        v = ncread(fileName, varName2);
        time = double(ncread(fileName, 'time'));
        lat = ncread(fileName, 'latitude');
        lon= ncread(fileName, 'longitude');
        save('lon.mat','lon');
        save('lat.mat','lat');
        [row, ~] = size(time);
        time = time./24 + datenum(1900, 1, 1);                              % In this data type date starts at 1900-1-1
        
        for i = 1 : row
            if i == 1
                k = 1;
                [yyyy, mm, dd] = datevec(double(time(i,:)));
                timeVecNow = [yyyy, mm, dd];
                [yyyy, mm, dd] = datevec(double(time(i + 1, :)));
                timeVecFut = [yyyy, mm, dd];
                u_temp(:, :, k) = u(:, :, i);
                v_temp(:, :, k) = v(:, :, i);
                k = k + 1;
            elseif isequal(timeVecNow, timeVecFut)
                u_temp(:, :, k) = u(:, :, i);
                v_temp(:, :, k) = v(:, :, i);
                if i == row
                    date = datestr(double(time(i - 1, :)), 'yyyy-mm-dd');
                    save(date, 'u_temp', 'v_temp');
                    clear u_temp v_temp
                else
                    k = k + 1;
                    timeVecNow = timeVecFut;
                    [yyyy, mm, dd] = datevec(double(time(i + 1, :)));
                    timeVecFut = [yyyy, mm, dd];
                end
            else
                date = datestr(double(time(i - 1, :)), 'yyyy-mm-dd');
                save(date, 'u_temp', 'v_temp');
                clear u_temp v_temp
                k = 1;
                timeVecNow = timeVecFut;
                [yyyy, mm, dd] = datevec(double(time(i, :)));
                timeVecFut = [yyyy, mm, dd];
                u_temp(:, :, k) = u(:, :, i);
                v_temp(:, :, k) = v(:, :, i);
                k = k + 1;
            end
        end         
    case 2
        for i=stDate:endDate
            for j=stMonth:endMonth
                dateFormat=sprintf('%d-%02d-01 00:00:00',i,j);
                fileName=sprintf(fileNameFormat,i,j);
                if exist(fileName,'file')==0
                    continue;
                end
                if kk==1
                    ncdisp(fileName);
                end
                all_u=ncread(fileName,varName1);
                all_v=ncread(fileName,varName2);
                tmp=size(all_u);
                [row,col]=size(tmp);
                if col==3
                    t=tmp(3);
                    for ii=1:t
                        u(:,:,kk)=all_u(:,:,ii);
                        v(:,:,kk)=all_v(:,:,ii);
                        taym(kk,:)=taym(kk-1,:)+1/dataNum;
                        kk=kk+1;
                    end
                else
                    t=1;
                    lon=ncread(fileName,'lon');
                    lat=ncread(fileName,'lat');
                    save('lon.mat','lon');
                    save('lat.mat','lat');
                    u(:,:,kk)=all_u;
                    v(:,:,kk)=all_v;
                    prev_time=ncread(fileName,'valid_date_time');
                    year=str2double(prev_time(1:4,:)');
                    month=str2double(prev_time(5:6,:)');
                    day=str2double(prev_time(7:8,:)');
                    hour=str2double(prev_time(9:10,:)');
                    min=0;
                    all_time=datenum([year,month,day,hour,min,min]);
                    taym(kk,:)=all_time;
                    kk=kk+1;
                end
                [tt,~]=size(taym);
                
                
                
                %                 if i==stDate && j==stMonth
                %                     lon=ncread(fileName,'lon');
                %                     lat=ncread(fileName,'lat');
                %
                %                     save('lon.mat','lon');
                %                     save('lat.mat','lat');
                %                 end
                %                 for ii=1:dataNum:(t-dataNum+1)
                %                     for k=1:dataNum
                %                         u(:,:,k)=all_u(:,:,ii+k-1);
                %                         v(:,:,k)=all_v(:,:,ii+k-1);
                %                         time=all_time(ii,:);
                %                     end
                %                     date=datestr(time,'yyyy-mm-dd');
                %                     save(date,'u','v');
                %                 end
            end
        end
        taym=taym+seconds(60);
        for ii=1:dataNum:(tt-dataNum+1)
            for jj=1:dataNum
                u_temp(:,:,jj)=u(:,:,ii+jj-1);
                v_temp(:,:,jj)=v(:,:,ii+jj-1);
            end
            date=datestr(taym(ii,:),'yyyy-mm-dd');
            save(date,'u_temp','v_temp');
        end
end

toc




