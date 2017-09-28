# mysql_employees

A MySQL Sample Database to run within a Docker container. Use this to spin up a quick proof-of-concept web application or backend service.

This is a simplified fork of [datacharmer/test_db](https://github.com/datacharmer/test_db), see that repository for more in-depth examples, repository history, bug fixes and ongoing updates.

See usage in the [MySQL docs](https://dev.mysql.com/doc/employee/en/index.html)

## Build & Run

1. `docker build -t mysql_employees .`
2. `docker run -it --rm -e "MYSQL_ROOT_PASSWORD=s3cr3t1" -p '3306:3306' mysql_employees`

This will populate a MySQL database with employee/deparatment relationships.

The command exposes the database on `localhost:3306`. If you have a port conflict, you may need to either stop an existing MySQL instance first or change the first 3306 to another port.

## DISCLAIMER

To the best of my knowledge, this data is fabricated, and it does not correspond to real people. 
Any similarity to existing people is purely coincidental.

## NOTICE

This containerized solution is not meant to be used for anything other than development purposes.

DO NOT:

* Use this in a production environment
* Host this using the usernames or passwords contained in this repository
* Assume the MySQL container is secure

There is no warranty associated with this repository or any container built from this repository.

## LICENSE
This work is licensed under the 
Creative Commons Attribution-Share Alike 3.0 Unported License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 
Creative Commons, 171 Second Street, Suite 300, San Francisco, 
California, 94105, USA.


