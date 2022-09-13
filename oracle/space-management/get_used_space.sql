-- check used space --

-- get total used space in GB
--- create -> vi get_used_space.sql

SELECT SUM (bytes)/1024/1024/1024 AS "Used size in GB" FROM dba_segments;
