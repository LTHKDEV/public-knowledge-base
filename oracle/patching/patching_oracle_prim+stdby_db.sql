--patching, Non-RAC
--for a primary and standby database, patch standby first and do not do any post installation step on the standby
---disable any cronjobs and make sure application is brought down


--patching order
OPatch --if not on latest version
DB
OJVM
JDK


--export timeout parameter, so terminal does not disconnect
export TMOUT=86400
--check 
echo $TMOUT


--check SID
run -> echo $ORACLE_SID or run -> select instance_name from v$instance;
--check db version
run -> select * from v$version;

--check OPatch version, is high enough to meet patch requirements
--only will work if OPatch is on PATH
run -> $ORACLE_HOME/OPatch/opatch version
--or from OPatch dir <$ORACLE_HOME/OPatch>, run -> ./opatch version


--upgrading OPatch
---if OPatch is outdated, need to update OPatch before patching
---just always update, it is likely that OPatch is outdated
create backup and remove OPatch dir from ORACLE_HOME
make sure this dir -> $ORACLE_HOME/OPatch does not exist
--rename the current OPatch dir to OPatch_<version_number>
mv OPatch OPatch_v1220121

--unzip the OPatch downloaded zip into ORACLE_HOME directory
--go to ORACLE_HOME and then unzip from the loc the zip is staged
run -> unzip <path/to/OPatch/zip/<OPatch>.zip


--check OPatch version
run -> $ORACLE_HOME/OPatch/opatch version
--or from $ORACLE_HOME run -> ./OPatch/opatch version



--need to backup DBs, first check primary and standby are in sync(do full back up the day before and archive log back up after apps come down)
--check primary log sequence number
--disable any running cronjobs from crontab prior to patch


--Log Shipping
primary:
--check primary log sequence number
run -> vi prim_log_seq.sql

select thread#, max(sequence#) "Last Primary Seq Generated"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;

standby:
--check stdby log sequence number
--make sure stdby is still within 1 number of primary, if so primary and stdby in sync

--check last received log on standby
run -> vi stdby_log_rec.sql

select thread#, max(sequence#) "Last Standby Seq Received"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;

--check last applied log on standby
run vi stdby_log_app.sql

select thread#, max(sequence#) "Last Standby Seq Applied"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
and val.applied in ('YES','IN-MEMORY')
group by thread# order by 1;

--if stdby is within 1 number of primary check to make sure logs are applying
--switch the logfiles to make sure that coop is applying, switch log file twice

--primary
alter system switch logfile;


/* THIS SECTION IS NOT BEING USED FOR OPIS, compare with the OPIS app queries
--check that app is not connected, on primary
--this needs formatting
select
       substr(a.spid,1,9) pid,
       substr(b.sid,1,5) sid,
       substr(b.serial#,1,5) ser#,
       substr(b.machine,1,6) box,
       substr(b.username,1,10) username,
--       b.server,
       substr(b.osuser,1,8) os_user,
       substr(b.program,1,30) program
from v$session b, v$process a
where
b.paddr = a.addr
and type='USER'
order by spid;



--backup primary and standby
--shutdown primary and start in mount mode and take backup
--for backup - shutdown primary and startup mount for cold backup, standby is in mount and doesn't need shutdown for cold backup
-- make sure both primary and standby are in mount mode

spool log to '/mnt/admin/oracle/db_patch/backup_log.log'

backup
format '/mnt/admin/oracle/db_patch/backup_db_%U'
database
current controlfile
format '/mnt/admin/oracle/db_patch/backup_cf_%U'
spfile
format '/mnt/admin/oracle/db_patch/backup_spf_%U'
plus archivelog
format '/mnt/admin/oracle/db_patch/backup_arch_%U';
*/



--NOT WORKING, NEEDS FIX ###############################
--add in check patch status 
run -> vi patch_status.sql

set lines 500 pages 1000
col action_time for a12
col action for a10
col comments for a30
col description for a60
col namespace for a20
col status for a10

SELECT TO_CHAR(action_time, ‘YYYY-MM-DD’) AS action_time,action,status,
description,patch_id FROM sys.dba_registry_sqlpatch ORDER by action_time;
--########################################################

--check registry on primary, spool this for pre and post
--create sql file 
run -> vi registry_status.sql

set lines 145 pages 100
col comp_name for a35
col comp_id for a10

select comp_id,comp_name,version,status from dba_registry;

--create prepatch spooling file
run -> vi reg_pre.sql

spool registry_prepatch.log
@registry_status.sql
spool off


--shutdown both prim and standby and listener (and agent if agent is present)
--complete shutting down of standby and then shutdown primary
standby:
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SHUTDOWN IMMEDIATE;

primary:
ALTER SYSTEM SET log_archive_dest_state_2='DEFER';
SHUTDOWN IMMEDIATE;


ps -ef |grep pmon --check to make sure db is not running, if no pmon process is running db is down
agentstop --default command -> emctl stop agent
lsnrctl stop


--make sure listener has stopped
agentstatus --default command -> emctl status agent
lsnrctl status


--backup oraInventory on primary and standby
--default loc -> /u01/app/oraInventory
--can be in same or diff loc
run-> cp -R /u01/app/oraInventory /u01/app/oraInventory_<current_date>

--backup $ORACLE_HOME on primary and standby
-- make sure there is space, this will create in the current dir
run -> tar -cvf oracle_home_<current_date>.tar $ORACLE_HOME

--unzip patches
run -> unzip <oracle_patch>.zip

--give dir that is holding patch 775 permission
run -> chmod -R 775 <staging_dir>

--create a pre-patch inventory txt file
run -> $ORACLE_HOME/OPatch/opatch lsinventory -details > prepatchinv.txt



--opatch lspatches


oracle patch - for standby/primary or standalone (binaries can be patched simultaneously on primary or standby, if no standby just run steps on the standalone) - DO NOT RUN POST INSTALLATION STEPS ON STANDBY
----------------------------------
-- make sure listener is still down
lsnrctl status
-- make sure db is shutdown
ps -ef | grep pmon
--change dir to dir where patch is located/staged
--unzip patch if not already unzipped and go into dir with the specific patch
-- <staging_dir>/<patch_number> or <staging_dir>/<combo_patch_number>/<patch_number>

--check to make sure the Oracle patch does not have a conflict with any other installed patches
----##want to get nohup to print this into a file 
opatch prereq CheckConflictAgainstOHWithDetail -ph ./

-- install the patch, currently using nohup to run in background in case of a disconnected session
--(yes | nohup $ORACLE_HOME/OPatch/opatch apply) &
nohup $ORACLE_HOME/OPatch/opatch apply -silent &

-- to monitor progress
tail -f nohup.out

/*
default command -> $ORACLE_HOME/OPatch/opatch apply
--OPatch continues with these patches should match the patch number for the patch being applied
--choose to proceed
y
--local system, choose yes, make sure instances running out of that ORACLE_HOME and shutdown
y
*/

--wait for OPatch succeeded


java patch - for standby/primary or standalone (binaries can be patched simultaneously on primary or standby, if no standby just run steps on the standalone) - DO NOT RUN POST INSTALLATION STEPS ON STANDBY
----------------------------------
-- make sure listener is still down
lsnrctl status
-- make sure db is shutdown
ps -ef | grep pmon
--change dir to dir where patch is located/staged
--unzip patch if not already unzipped and go into dir with the specific patch
-- <staging_dir>/<patch_number> or <staging_dir>/<combo_patch_number>/<patch_number>

--check to make sure the Java patch does not have a conflict with any other installed patches
----##want to get nohup to print this into a file 
opatch prereq CheckConflictAgainstOHWithDetail -ph ./

-- install the patch, currently using nohup to run in background in case of a disconnected session
--(yes | nohup $ORACLE_HOME/OPatch/opatch apply) &
nohup $ORACLE_HOME/OPatch/opatch apply -silent &

-- to monitor progress
tail -f nohup.out

/*
default command -> $ORACLE_HOME/OPatch/opatch apply
--OPatch continues with these patches should match the patch number for the patch being applied
--choose to proceed
y
--local system, choose yes, make sure instances running out of that ORACLE_HOME and shutdown
y
*/

--wait for OPatch succeeded


oracle and java patch - post-installation - ONLY DO ON PRIMARY or STANDALONE
---------------------------------
--log back into sql and proceed with post-installation steps
--start db
startup
--once db opens then quit
quit
--run the datapatch with the verbose option
----##look into running this with nohup, below nohup needs testing
----##run -> nohup $ORACLE_HOME/OPatch/datapatch -verbose &
run -> $ORACLE_HOME/OPatch/datapatch -verbose
--old patch rolledback (if applicable), new patch applied
--wait for datapatch to complete
--log back into sqlplus
shutdown immediate
--use exit to make share segments go away
exit
--change to $ORACLE_HOME/rdbms/admin dir
cd $ORACLE_HOME/rdbms/admin
--connect to sqlplus from the current dir
--conenct to sqlplus and startup
startup
--run recompiliation script
@utlrp.sql


--check registry, spool this for pre and post
--create sql file (this file should have be created in the earlier steps)
run -> vi registry_status.sql

set lines 145 pages 100
col comp_name for a35
col comp_id for a10

select comp_id,comp_name,version,status from dba_registry;

--create postpatch spooling file
run -> vi reg_post.sql

spool registry_postpatch.log
@registry_status.sql
spool off


JDK patch - do on standby/primary or standalone
------------------------------------
-- check version to see if upgrade is needed
$ORACLE_HOME/jdk/bin/java -version
--log into sqlplus (if the oracle and java patches were applied prior only primary needs to be shutdown)
shutdown immediate
exit

--change dir to dir where patch is located/staged
--unzip patch if not already unzipped and go into dir with the specific patch (rename any patchsearch.xml in the current dir)
--make sure to give patch dir 775 permissions
-- <staging_dir>/<patch_number> or <staging_dir>/<combo_patch_number>/<patch_number>

--check to make sure the JDK patch does not have a conflict with any other installed patches
----##want to get nohup to print this into a file 
opatch prereq CheckConflictAgainstOHWithDetail -ph ./

-- install the patch, currently using nohup to run in background in case of a disconnected session
--(yes | nohup $ORACLE_HOME/OPatch/opatch apply) &
nohup $ORACLE_HOME/OPatch/opatch apply -silent &

-- to monitor progress
tail -f nohup.out

/*
default command -> $ORACLE_HOME/OPatch/opatch apply
--OPatch continues with these patches should match the patch number for the patch being applied
--choose to proceed
y
--local system, choose yes, make sure instances running out of that ORACLE_HOME and shutdown
y
*/

--wait for OPatch succeeded


--log into sqlplus
--start db only for primary or standalone
startup
-- standby does not need to be started and can be mounted as normal (this is in the JDK readme, there is no mention of starting db for this to take effect)
--check version to make sure version was upgraded
$ORACLE_HOME/jdk/bin/java -version


--create post patch inventory file
--THIS COMES AFTER THE JDK IF THERE IS A JDK PATCH
run -> $ORACLE_HOME/OPatch/opatch lsinventory -details > postpatchinv.txt


--start both primary and standby and listener (and agent if agent is present)
--complete starting up primary and then start standby
--primary
startup
ALTER SYSTEM SET log_archive_dest_state_2='ENABLE';

--standby
--start db in mount mode, control file should start it in mount mode regardless
startup mount
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;


--start listener (and then agent if agent is present) on primary
lsnrctl start
agentstart --default -> emctl start agent

--check status
lsnrctl status
agentstatus --default command -> emctl status agent

--start listener (and then agent if agent is present) on standby
lsnrctl start
agentstart --default -> emctl start agent

--check status
lsnrctl status
agentstatus --default command -> emctl status agent



--check if mrp is started, if not start it
--check if MRP is running on standby
ps -ef | grep mrp
--OR
select process, status from v$managed_standby; --MRP or MRP0 process means it is running

--if MRP is NOT RUNNING then start MRP
--start mrp
alter database recover managed standby database disconnect from session;


--switch logs twice on primary and check to see if standby is in sync
--primary
alter system switch logfile;

--Log Shipping
primary:
--check primary log sequence number
run -> vi prim_log_seq.sql

select thread#, max(sequence#) "Last Primary Seq Generated"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;

standby:
--check stdby log sequence number
--make sure stdby is still within 1 number of primary, if so primary and stdby in sync

--check last received log on standby
run -> vi stdby_log_rec.sql

select thread#, max(sequence#) "Last Standby Seq Received"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;

--check last applied log on standby
run -> vi stdby_log_app.sql

select thread#, max(sequence#) "Last Standby Seq Applied"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
and val.applied in ('YES','IN-MEMORY')
group by thread# order by 1;

--if stdby is within 1 number of primary check to make sure logs are applying
--switch the logfiles to make sure that coop is applying, switch log file twice

--primary
--switch log files twice to send the patch updates from primary to standby
alter system switch logfile;


--can check db version after patch is applied
--check db version
run -> select * from v$version;

--REMEMBER to enable any jobs that were previously disabled for patching



----##notes##----
agentstatus --default command -> emctl status agent
lsnrctl status

have to stop lsnr and agent -> agentstop --default -> emctl stop agent
after patch -> agentstart --default -> emctl start agent




unzip patch --rename any patchsearch.xml in the current dir
go into dir with the specific patch
opatch apply




-- silent opatch
/*
--- can run below to name the nohup.out file, the & runs the command in the background
nohup $ORACLE_HOME/OPatch/opatch apply -silent  >myoutput.log &
*/
nohup $ORACLE_HOME/OPatch/opatch apply -silent &

--- to monitor progress
tail -f nohup.out




-- 
guranteed flashback - creates in COOP too, COOP can be connected


