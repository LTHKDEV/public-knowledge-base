#!/bin/bash

## using hardcoded location, will eventually query the db to find location dynamically
## query DIAGNOSTIC_DEST from db or from pfile
### run -> SQL> show parameter background
## also can eventually print this out from a certain time in the past and email results on a schedule

# bring up alert.log with the view command
# this is better for searching back more that 24hrs because I prefer how vi search works
## default location is used below
view /u01/app/oracle/diag/rdbms/<DB_Name>/<Oracle_SID>/trace/alert.log