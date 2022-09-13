-- check available space for tablespace --

-- get tbs space
--- create -> vi get_tbs_space.sql

set head off
select 'Tablespace Storage Report for ' || value || ' as of: ' || systimestamp
from v$parameter
where name='db_name';
Prompt

set head on
col allocated(MB) format 99999999.99
col total(MB) format 99999999.99
col usedspace(MB) format 99999999.99
col freespace(MB) format 99999999.99
col "pctfree" format 99999.99
set lines 140
set pages 200

compute sum of "total(MB)" on report
compute sum of "usedspace(MB)" on report
compute sum of "freespace(MB)" on report
compute sum of "allocated(MB)" on report
break on report

select u.tablespace_name,
       a.allocated_mb "allocated(MB)",
       a.max_mb "total(MB)",
       u.used_mb "usedspace(MB)",
       case when (a.max_mb>=a.allocated_mb) then (a.max_mb-u.used_mb) else (a.allocated_mb-u.used_mb) end as "freespace(MB)",
       case when (a.max_mb>=a.allocated_mb) then (((a.max_mb-u.used_mb)/a.max_mb)*100) else (((a.allocated_mb-u.used_mb)/a.allocated_mb)*100) end as  "pctfree",
       case when (a.max_mb<a.allocated_mb) then 'Alloc > Max - CHECK MAXSIZE PARAMETER' end as "ckparam"
from (select tablespace_name,
             sum(bytes)/(1024*1024) Used_MB
      from dba_segments
      group by tablespace_name
      order by tablespace_name) u,
    (select tablespace_name,
            (decode(sum(maxbytes),0,sum(bytes),sum(maxbytes)))/(1024*1024) Max_MB,
            sum(bytes)/(1024*1024) Allocated_MB
     from dba_data_files
     group by tablespace_name
     order by tablespace_name) a
where u.tablespace_name=a.tablespace_name;

set linesize 80
set pagesize 23
