clear;close('all')
survey_day=datetime(2023,12,9)
fs=char(datetime(survey_day,'Format','MM-dd-yyyy'))
fs2=char(datetime(survey_day,'Format','yyyyMMdd'))

addpath('F:\GDriveICS\My Drive\IntegratedCoastalSolutions\SoftwareDevelopment\Yellowfin\ExampleDataPro\ProcessingScripts')
data_dir=pwd

odir=[data_dir '\matfiles_'  fs2 '\'];% location of matfiles that are stored in processing
godir=[data_dir '\image_files_'  fs2 '\'];% location of  graphics files that are generated in processing
mkdir(odir)
mkdir(godir)

%% reads NMEA gps data written to rasbpi logger
% these should be in dirstr = .\Data\nmeadata\MM-dd-yyyy\
% where data_dir =pwd is the location of this script
dirstr=[data_dir '\Data\nmeadata\' fs]
%s1_readNMEAfiles
% no figures

%% reads s500 sonar data written to rasbpi logger
keep('survey_day','fs','fs2','odir','godir','data_dir')
% these should be in dirstr =  [data_dir '\Data\s500\MM-dd-yyyy\']
% where data_dir =pwdis the location of this script
dirstr=[data_dir '\Data\s500\' fs]
use_txt_depth_strings=0
int_pro=0  % processing of full intensity profile, usually should be zero . built in bed detection is usually suffcient
system_default_sound_speed=1500;
%measured_sound_speed=1480;
d=2
p = 101.325+1025*9.81*d/1000
measured_sound_speed=c_water(5,p,0)
use_txt_depth_strings=0

%s2_read_s500sonar
% with profiles on creates figure 1 to 4. Otherwise just 5

%% Set Start and End time for processing and assings NMEA GGA sentence based time stamps to sonar data 
% this should eliminate any issues with data logger time set incorrectly
keep('survey_day','fs','fs2','odir','godir','data_dir')

YF_timezone='America/New_York' % set the time zone of the rasbpi data logger

% GPS based start is when gps drops below GPS_thresh m MSL, end is when goes above GPS_thresh m MSL
GPS_thresh=18

% Sonar based start is when std(depth) drops below SONAR_thresh m , end is when it
% goes above SONAR_thresh. It is very noisy out of the water so std is high
SONAR_thresh=2
% you can change these manually by editing the generated
% s3_START_END_TIMES_*.mat mat file
sonar_start_time_adjust=minutes(3);% delay the start5
sonar_end_time_adjust=-minutes(22);% advance  the end
%sonar_end_time_adjust=-minutes(4.5);% advance  the end

processing_time=seconds(.7);
s3_Set_start_end_time_sync
% makes figures(6) and 7
%%  Merge NMEA GPS DATA and Sonar Data. Sonar Data is cleaned here  
% look at lines 29 thru 81 for 3 stages of time series cleaning
%  look at lines 156 177 for rejection of outlier from a spatiall smoothed
%  solution
keep('survey_day','fs','fs2','odir','godir','data_dir')
make_maps=1; %This needs to be 1 for the next step to work
spatial_filter_rejection=0;
s4_MergeNMEA_GPS_s500
% makes figures(8) to (13)

%% Load PPK GNSS data
keep('survey_day','fs','fs2','odir','godir','data_dir')
% LLH data from emlid studio should be in:
% and PPK *.pos data in :dirnm=[data_dir '\YF3-reach-m_' fs2 '*']

dirnm=[data_dir '\YF3-reach-m_' fs2 '*']


% The PPK data should have 10 header lines with the
% the 10th having variable names as defined by Emlid Studio
% and PPK *.pos data in . The PPK data should have 10 header lines with the
% the 10th having variable names as defined by Emlid Studio
% and should be in the foloowing directory:


%the below can be used to convert ellopsiodal height data to othrometric
%height with some small error due to spatialvariablity if geoid
%Emlid data from Emlid studio is usually output in ellopsiodal height
ell2ortho= 29.028 % in meters. from https://vdatum.noaa.gov/vdatumweb/
%ell2navd88 = 0 % the MArtha's Vineyard example data was processed in orthemetric height

s5_read_emlid_LLH_PPK
% makes figures(14) to (15)

%% Merge PPK GNSS data with 4 stage cleaned Sonar Data
% another time sync step is perfromed here by sliding corelation of heave
% in both sonar and PPK GNSS data
% This is done on lines 11 through 64
% the variable use_resync =1 will enable this feature, 
% gps_leap_offset =0 will disable this and use zero lag shift. 
% The top panal of figure(21) will show if this is ok as sonar and GNSS
% heave should line up 

% gps_leap_offset = 18 seconds and  a processing delay of 0.7 should lead
% zero lags. The processing delay of 0.7 might need to be adjusted slightly
% to get 0 lags and allow disabling this resyncing.  other values are
% accepatble as the code will use non-zero values. 
% Large values over 10 might  indicate a timing problem

keep('survey_day','fs','fs2','odir','godir','data_dir')
use_resync=0;
gps_leap_offset=seconds(18)
processing_delay=seconds(0)
sync_vert_offset=0; % to make figure(20) line  red and blue line overlap vertically
xl(1)=datetime(2023,12,9,18,0,0,'TimeZone','UTC');% pick a period with sonar variations due to heave not bed changes
xl(2)=datetime(2023,12,9,18,8,0,'TimeZone','UTC');% top plot fo figure(20) shows whole data set and bottom plot shows syncing region

make_maps_ppk=1;
s6_MergePPKGPS_sonar
% makes figures (16) to (24)