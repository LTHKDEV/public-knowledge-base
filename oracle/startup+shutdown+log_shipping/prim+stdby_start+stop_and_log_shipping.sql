//DG Shutdown/Startup and Primary/Standby Log Shipping//


//Shutdown
standby:
--check if MRP is running on standby
ps -ef | grep mrp
--OR
select process, status from v$managed_standby; --MRP or MRP0 process means it is running
--stop mrp
alter database recover managed standby database cancel;
--shutdown
shutdown immediate;

primary:
--stop log shipping
alter system set log_archive_dest_state_2='DEFER';
--shutdown
shutdown immediate;

BOTH primary and standby:
ps -ef |grep pmon --check to make sure db is not running, if no pmon process is running db is down
agentstop --default command -> emctl stop agent
lsnrctl stop

--make sure listener has stopped
agentstatus --default command -> emctl status agent
lsnrctl status


//Startup
primary:
--start
startup;
--enable log shipping
alter system set log_archive_dest_state_2='ENABLE';

standby:
--start
startup mount;
--check if MRP is running on standby
ps -ef | grep mrp
--OR
select process, status from v$managed_standby; --MRP or MRP0 process means it is running
--start mrp
alter database recover managed standby database disconnect from session;

BOTH primary and standby:
--start listener (and then agent if agent is present) on primary
lsnrctl start
agentstart --default -> emctl start agent

--check status
agentstatus --default command -> emctl status agent
lsnrctl status

--start listener (and then agent if agent is present) on standby
lsnrctl start
agentstart --default -> emctl start agent

--check status
agentstatus --default command -> emctl status agent
lsnrclt status


--check if mrp is started, if not start it
--check if MRP is running on standby
ps -ef | grep mrp
--OR
select process, status from v$managed_standby; --MRP or MRP0 process means it is running

--if MRP is NOT RUNNING then start MRP
--start mrp
alter database recover managed standby database disconnect from session;

--switch logs twice on primary and check to see if standby is in sync


//Log Shipping
primary:
-- check primary log sequence number
--- create -> vi prim_log_seq.sql

select thread#, max(sequence#) "Last Primary Seq Generated"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;

standby:
-- check stdby log sequence number
-- make sure stdby is still within 1 number of primary, if so primary and stdby in sync

-- check last received log on standby
--- create -> vi stdby_log_rec.sql

select thread#, max(sequence#) "Last Standby Seq Received"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;

-- check last applied log on standby
--- create -> vi stdby_log_app.sql

select thread#, max(sequence#) "Last Standby Seq Applied"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
and val.applied in ('YES','IN-MEMORY')
group by thread# order by 1;

--if stdby is within 1 number of primary check to make sure logs are applying
--switch the logfiles to make sure that coop is applying, switch log file twice

--primary
alter system switch logfile;
