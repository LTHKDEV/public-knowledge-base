-- standby received logs from primary --

-- check last applied log on standby
--- create -> vi stdby_log_app.sql

select thread#, max(sequence#) "Last Standby Seq Applied"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
and val.applied in ('YES','IN-MEMORY')
group by thread# order by 1;
