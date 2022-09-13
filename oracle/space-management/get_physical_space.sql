-- check physical space --

-- get size of database (data files, temp files, redo files, control files) that is physically consumed on disk
--- not all this space is necessarily used
--- create -> vi get_physical_space.sql

select
(select sum(bytes)/1024/1024/1024 data_size from dba_data_files ) +
(select nvl(sum(bytes),0)/1024/1024/1024 temp_size from dba_temp_files ) +
(select sum(bytes)/1024/1024/1024 redo_size from sys.v_$log ) +
(select sum(BLOCK_SIZE*FILE_SIZE_BLKS)/1024/1024/1024 controlfile_size from v$controlfile) "Pyhsical size in GB"
from
dual;
