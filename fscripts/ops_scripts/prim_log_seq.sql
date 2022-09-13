-- primary log sequence number --

-- check primary log sequence number
--- create -> vi prim_log_seq.sql

select thread#, max(sequence#) "Last Primary Seq Generated"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by thread# order by 1;
