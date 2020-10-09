% IT IS THE SECOND STEP FOR ECMWF DATA TO BE AVALIABLE PLEASE DO NOT FORGET
% TO DO NECESSARY CHANGES IN THE CODE
% BY CAN OZSOY

clc
clear
close all
tic

%% INPUTS
st_date=datenum('2020-10-02 00','yyyy-mm-dd HH');                           % ENTER START DATE AS SAME FORMAT
end_date=datenum('2020-10-03 23','yyyy-mm-dd HH');                          % ENTER END DATE AS SAME FORMAT
data_type=2;                                                                % (1):ERA-Interim; (2):ERA5
output_folder_name='outputforfiles';                                        % ENTER OUTPUT FOLDER NAME
%% CALCULATIONS

load('lon.mat');
load('lat.mat');
name2='%5.2fN%5.2fE';
time_inc=1/24;
k=1;

for i=st_date:end_date
    name1=datestr(i,'yyyy-mm-dd');
    load(name1);
    for j=1:(1/time_inc)
        u_cmb(:,:,k)=u_temp(:,:,j);
        v_cmb(:,:,k)=v_temp(:,:,j);
        k=k+1;
    end
end

clear k
mkdir(output_folder_name)
cd(output_folder_name)
[~,~,t]=size(u_cmb);

for i=1:numel(lat)
    for j=1:numel(lon)
        for k=1:t
            u_cmbT(:,:,k)=transpose(u_cmb(:,:,k));                          % FOR CFSR IT IS NEEDED
            v_cmbT(:,:,k)=transpose(v_cmb(:,:,k));                          % SAME AS ABOVE
            temp_u(1,k)=u_cmbT(i,j,k);
            temp_v(1,k)=v_cmbT(i,j,k);
        end
        filename2=sprintf(name2,lat(i),lon(j));
        file=sprintf([filename2,'.mat']);
        data(:,1)=temp_u';
        data(:,2)=temp_v';
        save(file,'data');
        clear data temp_u temp_v
    end
end


cd ..\
toc