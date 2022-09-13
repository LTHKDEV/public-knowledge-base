-- standby received logs from primary --

-- check last received log on standby
--- create -> vi stdby_log_rec.sql

select thread#, max(sequence#) "Last Standby Seq Received"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;
