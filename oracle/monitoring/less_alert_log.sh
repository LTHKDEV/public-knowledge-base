#!/bin/bash

## using hardcoded location, will eventually query the db to find location dynamically
## query DIAGNOSTIC_DEST from db or from pfile
### run -> SQL> show parameter background
## also can eventually print this out from a certain time in the past and email results on a schedule

# bring up alert.log with the less command
# this is good for scrolling back 24hrs or less
## default location is used below
less /u01/app/oracle/diag/rdbms/<DB_Name>/<Oracle_SID>/trace/alert.log
