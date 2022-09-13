#!/bin/bash

# FUNCTION DEFINITION #
check_disk_space() {
	df -h
}

check_dir_space_usage() {
	# need to add option to select location
	du -sh *
}

check_running_db_instances() {
	ps -ef | grep pmon
}

check_listener_status() {
	lsnrctl status
}

check_running_OEM_agents() {
	ps -ef | grep java
}

less_alert_log() {
	#if multiple instances on server need to give option to select specific instance
	less /u01/app/oracle/diag/rdbms/cdb/cdb/trace/alert_cdb.log
}

view_alert_log() {
	#if multiple instances on server need to give option to select specific instance
	view /u01/app/oracle/diag/rdbms/cdb/cdb/trace/alert_cdb.log
}

check_db_physical_space() {
	sqlplus -s "/ as sysdba"<<-EOF
	@/home/oracle/DBAScriptsFrequent/ops_scripts/get_physical_space.sql
	EOF
}

check_db_used_space() {
	sqlplus -s "/ as sysdba"<<-EOF
	@/home/oracle/DBAScriptsFrequent/ops_scripts/get_used_space.sql
	EOF
}

check_tablespace_space() {
	sqlplus -s "/ as sysdba"<<-EOF
	@/home/oracle/DBAScriptsFrequent/ops_scripts/get_tbs_space.sql
	EOF
}

check_log_seq() {
	#upgrade - will pick instance and check to see if primary or stdby
	sqlplus -s "/ as sysdba"<<-EOF
	@/home/oracle/DBAScriptsFrequent/ops_scripts/prim_log_seq.sql
	EOF
}

# while statement to print out menu after every execution
while true
do
	# VARIABLE DECLARATION #
	
	# the file -> operations contains the list of operations this script can peform
	OPS=$(cat /home/oracle/DBAScriptsFrequent/operations)
	
	### testing how operations file is diplayed
	###echo "${OPS}"
	
	# Main Body #
	
	# echo to insert blank line
	echo ""
	# custom prompt for select loop
	PS3="Select monitoring operation: "
	
	select OP in ${OPS}
	do
		# echo to insert blank line
		echo ""
		# calling function
		## if statement to break select loop
		if [[ "${OP}" == "quit" ]]
		then
			break
		fi
		## function call
		${OP}
		break
	done
	# if statement to break while loop
	if [[ "${OP}" == "quit" ]]
	then
	   break
	fi
done

echo "Execution ended..."
