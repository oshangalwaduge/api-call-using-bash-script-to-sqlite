# devops-assignment

# Create the database
sqlite3 assignment.db

# Create tables
create table "Meta Data" (
Information varchar(250),
Symbol varchar(10),
"Last Refreshed" date,
"Output Size" varchar(10),
"Time Zone" varchar(25) 
);

create table "Time Series (Daily)" (
Day date not null primary key,
Open float (23),
High float (23),
Low float (23),
Close float (23),
Volume integer (255)
);

# Create cron job for to run at every 2 hours
0 */2 * * * /root/new.sh
