



dd=dir([dirstr '\*.dat'])
for ii=1:length(dd)
    disp([num2str(ii) ' ' (dd(ii).name)])
end
ji=0;
pnmea = nmeaParser("MessageIDs", 'GGA')
for fi=2:length(dd) %5  20201218-101925265.bin ios new 500 khz
    disp([dirstr '\' dd(fi).name])
    %fid=fopen([dirstr dd(fi).name]);
    lns=readlines([dirstr '\' dd(fi).name]);
    for ii=1:length(lns);

        ln=lns{ii};
        if ~isempty(ln)
            datestring=ln(4:29);
            try
            dt(ii)=datetime(char(datestring),'InputFormat','yyyy-MM-dd HH:mm:ss.SSSSSS');
            catch
                continue
            end

            nmcode=ln(31:35);
            nmdata=ln(30:end);
            ggaData=pnmea(     nmdata);
            %         if strmatch(nmcode,'GNRMC')
            %             ji=ji+1;
            %             Str=ln(30:end);
            %             str1 = regexprep(Str,'[,;=]', ' ');
            %         str2 = regexprep(regexprep(str1,'[^- 0-9.eE(,)/]',''), ' \D* ',' ');
            %         str3 = regexprep(str2, {'\.\s','\E\s','\e\s','\s\E','\s\e'},' ');
            %         str4=regexprep(str3,'E','');
            %         numArray = str2num(str4);
            %         if length(numArray)>=3
            %         gps_time(ji)=numArray(1);
            %         lat(ji)=floor(numArray(2)/100)+(numArray(2)-floor(numArray(2)/100)*100)./60;
            %         lon(ji)=floor(numArray(3)/100)+(numArray(3)-floor(numArray(3)/100)*100)./60;
            %         pc_time_gga(ji)=dt(ii);


            if ggaData.Status==0
                ji=ji+1;
                gps_utc_time(ji)=datetime(ggaData.UTCTime,'TimeZone','UTC');% this is UTC

                lat(ji)=ggaData.Latitude;
                lon(ji)=ggaData.Longitude;
                altWGS84(ji)=ggaData.Altitude-ggaData.GeoidSeparation;
                altMSL(ji)=ggaData.Altitude;
                GeoidSeparation(ji)=ggaData.GeoidSeparation;
                pc_time_gga(ji)=dt(ii);% this is pc(rasbpi) time when gga sentences are recived
                gps_utc_time(ji).Year=year(dt(ii));
                gps_utc_time(ji).Month=month(dt(ii));
                gps_utc_time(ji).Day=day(dt(ii));

            end
        end
    end
end



%%
if 0 
lat(lat==0)="NaN";
lon(lon==0)="NaN";

figure(1);clf
plot(lon,lat,'o-')
figure(2);clf
plot(pc_time_gga,altWGS84,'.-')
hold on
plot(pc_time_gga,altMSL,'.-')
figure(3)
subplot(211)
plot(pc_time_gga,gps_time,'.')

subplot(212)
plot(seconds(datetime(pc_time_gga,'TimeZone','America/New_York')-gps_time),'.')
end
fs2=char(datetime(survey_day,'Format','yyyyMMdd'))

outname=[odir 's1_NMEA_GNSS_DATA_' fs2]
save(outname,'pc_time_gga','gps_utc_time','lat','lon','altMSL','altWGS84','GeoidSeparation')

%%


