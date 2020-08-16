# devops-assignment

Write a shell script that pulls data from the endpoint described below and prints it in console, while storing data in an SQLite database. Your solution should be generalized as much as possible to work with any 3rd party endpoint.

Tasks
1. Calling "Search Company" API to search companies start with "AB" (Note: select companies which has the "matchScore" greater than 0.5)
2. Calling "Daily Stock" API to get stock information for all selected companies in point number 1.
3. Saving the captured information for future use. This means the data we capture should be reused in subsequent runs. So before we make a request to the service we
need to look at our own databases to check existing information, Validity period for cached info should be 2 hours.
4. The script should provide high reliability & reusability.

Endpoint details
Note: You may need to register with the https://www.alphavantage.co/support/#api-key to access the APIs.

API Methods
>>Search Company: Eg: https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=BA&apikey=demo
>>>Daily Stock: Eg: ttps://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=IBM&apikey=demo
For more information about APIs refer to the official documentation at: https://www.alphavantage.co/documentation/

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
