//spooling oracle results SOP//

create spool file to run
//put file being run and spool file in the same dir, also create log file in the same dir, this makes things easier
-- vi spool.sql
-- spool.sql format:

spool <file_to_run>_results.log
@<file_to_run>.sql
spool off

-- log file will be created in the same dir

