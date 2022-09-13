--password reset and account unlock--


find user account status:
--username is case sensitive for finding user in database
col username for a15
col account_status for a15
col last_login for a25
select username, account_status, lock_date, expiry_date, last_login, password_change_date from dba_users where username = '<username>';


unlock account and reset with a temporary password:
ALTER USER <username> IDENTIFIED BY "<temp_password>" ACCOUNT UNLOCK;


reset user password(just resets password, requires account to be unlocked already):
ALTER USER <username> IDENTIFIED BY "<temp_password>" PASSWORD EXPIRE;
--This makes it so user has to change password on first login
--Does not work with DB Visualizer

ALTER USER <username> IDENTIFIED BY "<temp_password>";
--This just changes the password and requires user to set their own unique password manually afterwards


unlock user account(just unlock no password reset):
ALTER USER <username> ACCOUNT UNLOCK;
--If you unlock an account but do not reset the password, then the password remains expired. The first time that user connects they must change the password (need to verify)


temp pw:
T3mpP@55w0rd!12



--notes

--DB Visualizer - user change password:
alter user <username> identified by "<temp_password>" replace  "<new_password>";



