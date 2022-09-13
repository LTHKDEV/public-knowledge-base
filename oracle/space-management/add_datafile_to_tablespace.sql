-- add a datafile to tablespace

--tbs:
<tablespace_name>

--if database is setup primary with standby, make sure that standby_file_management parameter is set to AUTO, if not this parameter needs to be set before adding datafiles
on standby:
run -> show parameter standby

--if standby_file_management not set to auto can set with below command
on primary: --need to verify if this is run from primary
run -> alter system set standby_file_management=AUTO scope=both;


--find ASM DiskGroup space available
SELECT name, free_mb, total_mb, free_mb/total_mb*100 as percent_free FROM v$asm_diskgroup;

--if not ASM then check mount points for space available
df -h


--To check the location of existing datafiles:
show parameter db_create_file_dest;
---only shows if parameter is set

--if parameter is not set use below query
select file_name from dba_data_files;

--to just get the data file names, in order to name data file manually
select file_name from dba_data_files where tablespace_name = '<tablespace_name>'order by file_id asc;

---checks location and name of datafile and autoextend setting and file size and max size
select FILE_NAME,FILE_ID,AUTOEXTENSIBLE,bytes/1024/1024/1024 as SIZE_GB,STATUS,MAXBYTES/1024/1024/1024 as MAX_GB from dba_data_files where TABLESPACE_NAME='<tablespace_name>';

---to get just the size information
select bytes/1024/1024/1024 as SIZE_GB,MAXBYTES/1024/1024/1024 as MAX_GB,AUTOEXTENSIBLE from dba_data_files where TABLESPACE_NAME='<tablespace_name>';


---query to get file name and tbs name for all data files, for naming files manually and not using OMF naming
set pages 50
col file_name for a50
col tablespace_name for a15
select file_name, tablespace_name, file_id from dba_data_files where tablespace_name = '<tablespace_name>'order by file_id asc;


--add space to tablespace using ASM diskgroup, OMF is used so full path not specified
--diskgroup name can be found using a previous query, names are usually +DATA, +DATA2, etc
--use previous queries to find other datfile sizes and make new datafile size match other data files
alter tablespace
<tablespace_name> 
add datafile
'+<name_of_ASM_diskgroup>'SIZE 300M;


--add space to tablespace using ASM diskgroup, OMF is not used so full path is specified
--use previous queries to find other datfile sizes and make new datafile size match other data files
alter tablespace
INDEX_L 
add datafile
'+<name_of_ASM_diskgroup/path/to/datafile/location/<datafile_name_or_tablespace_name>_data_<datafile_#>.dbf>'SIZE 32000M;

--manually added, OMF not used, autoextend is used
--use previous queries to find other datfile sizes and make new datafile size match other data files
--good practice to name datafile after the tablespace
--"size" and "autoextend on next" and "maxsize" are env dependent, parameters can be found using previous queries
alter tablespace <tablespace_name>
ADD DATAFILE '</path/to/datafile/location/<datafile_name_or_tablespace_name>_data_<datafile_#>.dbf>'
size 20G autoextend on next 200M maxsize 31767M;


-- resize datafile
--- including SYSTEM datafile
 ALTER DATABASE DATAFILE '</path/to/datafile/location/<datafile_name_or_tablespace_name>_data_<datafile_#>.dbf>' AUTOEXTEND ON NEXT 200M MAXSIZE 4096M;




--notes
accept tablespace Prompt 'Enter Tablespace:'
accept datafile Prompt 'Enter Datafile:'
accept size Prompt 'Enter Size of the Datafile:'

alter tablespace '&tablespace' add datafile '&datafile' size &size autoextend on next 1M;

--alter tablespace <Tablespace> add datafile '<Datafile>' size 1001M;
--ALTER DATABASE DATAFILE '<Datafile>' AUTOEXTEND ON NEXT 1M;

