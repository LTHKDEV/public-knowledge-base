-- get db, schema, table size --

-- get size of database (data files, temp files, redo files, control files) that is physically consumed on disk
--- not all this space is necessarily used
run -> vi get_physical_space.sql

select
(select sum(bytes)/1024/1024/1024 data_size from dba_data_files ) +
(select nvl(sum(bytes),0)/1024/1024/1024 temp_size from dba_temp_files ) +
(select sum(bytes)/1024/1024/1024 redo_size from sys.v_$log ) +
(select sum(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024/1024 controlfile_size from v$controlfile) "Size in GB"
from
dual;


-- get total used space in GB
run -> vi get_used_space.sql

SELECT SUM (bytes)/1024/1024/1024 AS GB FROM dba_segments;


--get db size in ASM
select GROUP_NUMBER, NAME, SECTOR_SIZE, BLOCK_SIZE, ALLOCATION_UNIT_SIZE, TYPE, TOTAL_MB, FREE_MB, (TOTAL_MB - FREE_MB) USED_MB, round((FREE_MB/TOTAL_MB)*100,2) PCT_FREE, STATE, COMPATIBILITY
from v$asm_diskgroup;



-- get size of the database in MB (data files) that is physically consumed on disk
--- not all this space is necessarily used
select sum(bytes)/1024/1024 size_in_mb
from dba_data_files;


-- get total used space in MB
select sum(bytes)/1024/1024 size_in_mb
from dba_segments;


-- get used space brokendown by schema
select owner, sum(bytes)/1024/1024 Size_MB
from dba_segments
group  by owner;


-- get schema size for specific schema
select sum(bytes)/1024/1024 as size_in_MB, segment_type
from dba_segments
where owner='<schema_name>'
group by segment_type;


-- get table size GB
select segment_name,sum(bytes)/1024/1024/1024 GB from dba_segments where segment_type='TABLE' and segment_name=upper('&TABLE_NAME') group by segment_name;