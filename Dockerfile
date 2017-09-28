FROM mysql:5.7.19

ENV MYSQL_DATABASE employees
ENV MYSQL_USER user
ENV MYSQL_PASSWORD s3cur3p4ssw0rd

COPY *.dump /docker-entrypoint-initdb.d/

COPY employees.sql /docker-entrypoint-initdb.d/01-employees.sql
COPY objects.sql /docker-entrypoint-initdb.d/02-objects.sql

# The .1 suffix is added here so base image doesn't auto-apply this script.
COPY show_elapsed.sql /docker-entrypoint-initdb.d/show_elapsed.sql.1
COPY test_employees_md5.sql /docker-entrypoint-initdb.d/99-test_employees_md5.sql

RUN sed -i 's/^source /source \/docker-entrypoint-initdb.d\//g' /docker-entrypoint-initdb.d/01-employees.sql
RUN sed -i 's/\bshow_elapsed.sql\b/show_elapsed.sql.1/g' /docker-entrypoint-initdb.d/01-employees.sql
