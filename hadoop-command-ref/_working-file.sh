REGISTER /dev_tools/pig_default/lib/piggybank.jar
DEFINE SUBSTRING org.apache.pig.piggybank.evaluation.string.SUBSTRING();
DEFINE TRIM org.apache.pig.piggybank.evaluation.string.Trim();


hadoop fs -put /dev_tools/tmp/big_data/* "hdfs://localhost/data/weather/"
hadoop fs -mkdir /dev_tools/tmp/big_data/* "hdfs://localhost/data/weather/cleansed"

raw_countries = LOAD 'hdfs://localhost/data/weather/country-list.txt'
                AS (row:chararray);

countries_filtered = FILTER raw_countries BY (NOT (INDEXOF(row, 'FIPS ID', 0) != -1));

countries_master = FOREACH countries_filtered  GENERATE
                    (chararray) TRIM(SUBSTRING(row, 0, 12)) AS country_id,
                    (chararray) TRIM(SUBSTRING(row, 12, 20)) AS country_name;


to_print = LIMIT countries_master 10;
DUMP to_print;

STORE countries_master INTO 'hdfs://localhost/data/weather/cleansed/countries_master.tsv';



raw_stations = LOAD 'hdfs://localhost/data/weather/ish-history.csv'
                USING PigStorage(',')
                AS (usaf:chararray,
                    wban:chararray,
                    st_name:chararray,
                    ctry:chararray,
                    fips:chararray,
                    state:chararray,
                    call:chararray,
                    lat:chararray,
                    lon:chararray,
                    elev:chararray);

stations_filtered = FILTER raw_stations BY (NOT (INDEXOF(usaf, '"USAF"', 0) != -1));

station_master = FOREACH stations_filtered  GENERATE
                    (int) TRIM(REPLACE(usaf, '"', '')) AS station_id,
                    (chararray) TRIM(REPLACE(st_name, '"', '')) AS st_name,
                    (chararray) TRIM(REPLACE(ctry, '"', '')) AS country,
                    (chararray) TRIM(REPLACE(fips, '"', '')) AS fips,
                    (chararray) TRIM(REPLACE(state, '"', '')) AS state,
                    (float) TRIM(REPLACE(lat, '"', '')) AS latitude,
                    (float) TRIM(REPLACE(lon, '"', '')) AS longitude,
                    (float) TRIM(REPLACE(elev, '"', '')) AS elevation;

#to_print = LIMIT station_master 10;
#DUMP to_print;

STORE station_master INTO 'hdfs://localhost/data/weather/cleansed/station_master.tsv';










raw_weather = LOAD 'hdfs://localhost/data/weather/gsod/20*/*'
                AS (row:chararray);

#raw_weather = LOAD 'hdfs://master1/user/ubuntu/data/staging/weather/gsod/{2000,2001,2002}'
#                AS (row:chararray);


weather_filtered = FILTER raw_weather BY (NOT (INDEXOF(row, 'STN--', 0) != -1));

weather_master = FOREACH weather_filtered  GENERATE
	      (int)TRIM(SUBSTRING(row, 0, 6)) AS station,
	      (int)TRIM(SUBSTRING(row, 7,12)) AS wban,
	      (int)TRIM(SUBSTRING(row, 14, 22)) AS ymd,
	      (float)TRIM(SUBSTRING(row, 24, 29)) AS temp_avg,
	      (float)TRIM(SUBSTRING(row, 102, 107)) AS temp_max,
	      (float)TRIM(SUBSTRING(row, 110, 115)) AS temp_min,
	      (float)TRIM(SUBSTRING(row, 78, 82)) AS windspeed_avg,
	      (float)TRIM(SUBSTRING(row, 95, 99)) AS windspeed_max,
	      (float)TRIM(SUBSTRING(row, 68, 72)) AS visibility,
	      (float)TRIM(SUBSTRING(row, 118, 122)) AS precipitation;

#to_print = LIMIT weather_master 10;
#DUMP to_print;

STORE weather_master INTO 'hdfs://localhost/data/weather/cleansed/weather_master.tsv';


hadoop fs -getmerge /reports/some_output /mnt/hdfs/reports/some_output.txt



hadoop fs -mkdir hdfs://localhost/data/weather/cleansed/final
hadoop fs -mv hdfs://localhost/data/weather/cleansed/final/

hadoop fs -ls hdfs://localhost/data/weather/

hadoop fs -ls hdfs://localhost/data/weather/cleansed/countries_master.tsv/part*
hadoop fs -ls hdfs://localhost/data/weather/cleansed/station_master.tsv/part*
hadoop fs -ls hdfs://localhost/data/weather/cleansed/weather_master.tsv/part*

hadoop fs -getmerge hdfs://localhost/data/weather/cleansed/countries_master.tsv/part* /tmp/countries_master.tsv
hadoop fs -getmerge hdfs://localhost/data/weather/cleansed/station_master.tsv/part* /tmp/stations_master.tsv
hadoop fs -getmerge hdfs://localhost/data/weather/cleansed/weather_master.tsv/part* /tmp/weather_master.tsv


hadoop fs -rm -r hdfs://localhost/data/weather/cleansed/
hadoop fs -rm -r hdfs://localhost/data/weather/cleansed/


hadoop fs -put /tmp/countries_master.tsv hdfs://localhost/data/weather/
hadoop fs -put /tmp/stations_master.tsv hdfs://localhost/data/weather/
hadoop fs -put /tmp/weather_master.tsv hdfs://localhost/data/weather/

hadoop fs -ls hdfs://localhost/data/weather/




########################################################################################################################
hadoop fs -mkdir hdfs://localhost/data/weather/raw
hadoop fs -put /dev_tools/bakup/weather/* "hdfs://localhost/data/weather/raw"

raw_countries = LOAD 'hdfs://localhost/data/weather/raw/country-list.txt' AS (row:chararray);
countries_headerless = FILTER raw_countries BY (NOT (INDEXOF(row, 'FIPS ID', 0) != -1));
countries_formatted = FOREACH countries_headerless  GENERATE
                    (chararray) TRIM(SUBSTRING(row, 0, 12)) AS country_code,
                    (chararray) TRIM(SUBSTRING(row, 12, 52)) AS country_name;
raw_stations = LOAD 'hdfs://localhost/data/weather/raw/isd-history.csv'
                USING PigStorage(',')
                AS (usaf:chararray,
                    wban:chararray,
                    st_name:chararray,
                    ctry:chararray,
                    state:chararray,
                    lat:chararray,
                    lon:chararray,
                    elev:chararray);
stations_headerless = FILTER raw_stations BY (NOT (INDEXOF(usaf, '"USAF"', 0) != -1));
stations_formatted = FOREACH stations_headerless  GENERATE
                    (chararray) TRIM(REPLACE(usaf, '"', '')) AS station_id,
                    (chararray) TRIM(REPLACE(st_name, '"', '')) AS st_name,
                    (chararray) TRIM(REPLACE(ctry, '"', '')) AS country_code,
                    (chararray) TRIM(REPLACE(state, '"', '')) AS state,
                    (float) TRIM(REPLACE(lat, '"', '')) AS latitude,
                    (float) TRIM(REPLACE(lon, '"', '')) AS longitude,
                    (float) TRIM(REPLACE(elev, '"', '')) AS elevation;

raw_weather = LOAD 'hdfs://localhost/data/weather/raw/193*/*' AS (row:chararray);
weather_headerless = FILTER raw_weather BY (NOT (INDEXOF(row, 'STN--', 0) != -1));
weather_formatted = FOREACH weather_headerless  GENERATE
	      (chararray)TRIM(SUBSTRING(row, 0, 6)) AS station_id,
	      (int)TRIM(SUBSTRING(row, 7,12)) AS wban,
	      (int)TRIM(SUBSTRING(row, 14, 22)) AS ymd,
	      (float)TRIM(SUBSTRING(row, 24, 29)) AS temp_avg,
	      (float)TRIM(SUBSTRING(row, 78, 82)) AS windspeed_avg,
	      (float)TRIM(SUBSTRING(row, 68, 72)) AS visibility,
	      (float)TRIM(SUBSTRING(row, 118, 122)) AS precipitation;

station_country_joined = JOIN countries_formatted by (country_code) , stations_formatted by (country_code);
station_country_weather_joined = JOIN station_country_joined by (station_id), weather_formatted by (station_id);


station_country_weather_projected = FOREACH station_country_weather_joined GENERATE
                                        weather_formatted::ymd,
                                        weather_formatted::temp_avg,
                                        weather_formatted::windspeed_avg,
                                        weather_formatted::visibility,
                                        weather_formatted::precipitation,
                                        countries_formatted::country_name,
                                        stations_formatted::st_name,
                                        stations_formatted::country_code,
                                        stations_formatted::state,
                                        stations_formatted::latitude,
                                        stations_formatted::longitude,
                                        stations_formatted::elevation;
weather_data = rank station_country_weather_projected;

STORE weather_data INTO 'hdfs://localhost/data/weather/staging';
quit;

echo -e 'RECORD_ID\tDATE\tTEMP\tWINDSPD\tVISIB\tPERCIP\tCOUNTRY\tSTATIONNAME\tCOUNTRYCODE\tSTATE\tLATITUDE\tLONGITUDE\tELEVATION' > /tmp/_weather_header;
hadoop fs -moveFromLocal /tmp/_weather_header hdfs://localhost/data/weather/staging;
hadoop fs -rm hdfs://localhost/data/weather/staging/_SUCCESS;
hadoop fs -ls hdfs://localhost/data/weather/staging;
hadoop fs -getmerge hdfs://localhost/data/weather/staging/* /tmp/weather_data.tsv;
more /tmp/weather_data.tsv;
hadoop fs -mkdir hdfs://localhost/data/weather/prod;
hadoop fs -moveFromLocal /tmp/weather_data.tsv hdfs://localhost/data/weather/prod;
hadoop fs -cat hdfs://localhost/data/weather/prod/weather_data.tsv | head;
hadoop fs -rmr hdfs://localhost/data/weather/staging;
hadoop fs -rmr hdfs://localhost/data/weather/raw;
hadoop fs -rm hdfs://localhost/data/weather/*.tsv;





to_print = LIMIT station_country_joined 50;
to_print = LIMIT station_country_weather_ranked 500;
to_print = LIMIT weather_data 100;
to_print = LIMIT  10;
to_print = LIMIT  10;
to_print = LIMIT  10;


DUMP to_print;



######################################################################################################
######################################################################################################
    ####    15-OCT-2014
######################################################################################################
######################################################################################################
hadoop fs -ls hdfs://master1/
hadoop fs -ls hdfs://master1/user/
hadoop fs -ls hdfs://master1/user/ubuntu


sudo update-alternatives --list hadoop-conf
sudo update-alternatives --install /etc/hadoop/conf hadoop-conf /home/ubuntu/hadoop_conf/conf.cloudera.hdfs 50
sudo update-alternatives --config hadoop-conf



######################################################################################################
######################################################################################################
    ####    24-OCT-2014
######################################################################################################
######################################################################################################
 1174  2014-10-24 21:12:55 	hadoop jar ./hadoop-weather-maxtemp-by-country-station/target/hadoopMaxTempByCountryStation-1.0-SNAPSHOT.jar WeatherDataParser hdfs://localhost/data/weather/prod/weather_data.tsv
 1175  2014-10-24 21:13:47 	hadoop fs -ls -h hdfs://localhost/user/ubuntu/jar-jobs/output/1414165376523
 1176  2014-10-24 21:14:09 	hadoop fs -cat hdfs://localhost/user/ubuntu/jar-jobs/output/1414165376523/*
 1177  2014-10-24 21:14:55 	clear
 1178  2014-10-24 21:14:57 	mvn package
 1179  2014-10-24 21:15:33 	clear
 1180  2014-10-24 21:15:42 	hadoop jar ./hadoop-weather-maxtemp-by-country-station/target/hadoopMaxTempByCountryStation-1.0-SNAPSHOT.jar WeatherDataParser hdfs://localhost/data/weather/prod/weather_data.tsv
 1181  2014-10-24 21:16:34 	hadoop fs -cat hdfs://localhost/user/ubuntu/jar-jobs/output/1414165542635/*
 1182  2014-10-24 21:18:07 	history


hadoop jar ./hadoop-weather-maxtemp-by-country-station/target/hadoopMaxTempByCountryStation-1.0-SNAPSHOT.jar learn.WeatherDataParserPartitionerDriver hdfs://localhost/data/weather/prod/weather_data.tsv



######################################################################################################
######################################################################################################
    ####    25-OCT-2014
######################################################################################################
######################################################################################################
# Aliases created in ~/.bashrc file
function starthadoop(){
        hadoop-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo start namenode;
        hadoop-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo start secondarynamenode;
        hadoop-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo start datanode;
        yarn-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo start nodemanager;
        yarn-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo start resourcemanager;
        mr-jobhistory-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo start historyserver;
}
function stophadoop(){
        hadoop-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo stop namenode;
        hadoop-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo stop secondarynamenode;
        hadoop-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo stop datanode;
        yarn-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo stop nodemanager;
        yarn-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo stop resourcemanager;
        mr-jobhistory-daemon.sh --config $HADOOP_CONF_ROOT/conf.pseudo stop historyserver;
}

function startzoo(){
        zkServer.sh start;
}
function stopzoo(){
        zkServer.sh stop;
}
function starthbase(){
        start-hbase.sh;
        local-master-backup.sh  start   2;
        local-regionservers.sh start    3       4       5;
}
function stophbase(){
        stop-hbase.sh;
}

function starth(){
        starthadoop;
        startzoo;
        starthbase;
}
function stoph(){
        stophadoop;
        stopzoo;
        stophbase;
}



######################################################################################################
######################################################################################################
    ####    26-OCT-2014
######################################################################################################
######################################################################################################
#hbase shell
#create 'weather_sample', 'weather_data', 'loc_data'
#list
#exit
#
#export PIG_CLASSPATH=/dev_tools/hbase_default/lib/hbase-server-0.98.4-hadoop2.jar:/dev_tools/pig_default/lib/zookeeper-3.4.5.jar:/dev_tools/hbase_default/lib/hbase-client-0.98.4-hadoop2.jar;
#export PIG_CLASSPATH=hbase-hadoop2-compat-0.98.4-hadoop2.jar:/dev_tools/pig_default/lib/zookeeper-3.4.5.jar;
#
#pig;
#
#set debug on;
#set mapreduce.task.io.sort.mb 20;
#weather_data_with_header = LOAD 'hdfs://localhost/data/weather/prod/weather_data.tsv'
#                AS (id:chararray,
#                    ymd:chararray,
#                    temp_avg:chararray,
#                    windspeed_avg:chararray,
#                    visibility:chararray,
#                    precipitation:chararray,
#                    country_name:chararray,
#                    st_name:chararray,
#                    country_code:chararray,
#                    state:chararray,
#                    latitude:chararray,
#                    longitude:chararray,
#                    elevation:chararray);
#
#STORE weather_data_with_header INTO 'hbase://weather_sample'
#    USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
#        'weather_data:dateymd,
#         weather_data:temp,
#         weather_data:windspeed,
#         weather_data:visibility,
#         weather_data:percipitation,
#         loc_data:country,
#         loc_data:station,
#         loc_data:station_code,
#         loc_data:state,
#         loc_data:latitude,
#         loc_data:longitude
#         loc_data:elevation'
#
#    );

weather_data = FILTER weather_data_with_header BY (NOT (INDEXOF(id, 'ID', 0) != -1));

hbase shell
scan 'weather_sample'



hbase shell
create 'weather_sample_1', 'weather_data', 'loc_data'


hbase org.apache.hadoop.hbase.mapreduce.ImportTsv -Dimporttsv.skip.bad.lines=false -Dimporttsv.columns=HBASE_ROW_KEY,weather_data:dateymd,weather_data:temp,weather_data:windspeed,weather_data:visibility,weather_data:percipitation,loc_data:country,loc_data:station,loc_data:country_code,loc_data:state,loc_data:latitude,loc_data:longitude,loc_data:elevation weather_sample_1 hdfs://localhost/data/weather/prod/weather_data.tsv;

scan 'weather_sample_1', {COLUMNS => ['weather_data','loc_data'], LIMIT => 10 }
scan 'weather_sample_1', {COLUMNS => ['weather_data','loc_data'], STARTROW => "10100", ENDROW => "10103"}
//  Filter By Index of the Column
scan 'weather_sample_1', {COLUMNS => ['weather_data','loc_data'], LIMIT => 10, FILTER => org.apache.hadoop.hbase.filter.ColumnPaginationFilter.new(1, 0)}
scan 'weather_sample_1', {COLUMNS => ['weather_data','loc_data'], LIMIT => 10, FILTER => "SingleColumnValueFilter('loc_data','country_code',=,'binary:UK')", LIMIT => 10 }



new SingleColumnValueFilter



