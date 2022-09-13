/*check oracle character set parameter*/

select * from nls_database_parameters
where parameter='NLS_CHARACTERSET';