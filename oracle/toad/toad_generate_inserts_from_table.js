//Toad - generate insert statements script from a table//

SOP:
open Toad
open schema browser
got to the schema.table that needs insert statements generated
select that table and then go to the DATA tab
select the dropdown for the DATA EXPORT button
select 'Create insert statements for all rows'
make sure all the columns are selected under the COLUMNS tab
under the OPTIONS tab make sure 'Include Schema name in Insert statements' is selected
pick FILE for Destination and choose file location and name
export
// can check the count by comparing select count(*) results with the amount of 'Insert into' statements in generated script
