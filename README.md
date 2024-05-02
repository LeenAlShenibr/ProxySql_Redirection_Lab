# ProxySQL Lab

This lab environment sets up a proxySQL instance that fronts a primary DB and one replica DB. The purpose of this lab is to help understand and experiment with proxySQL query rules.  

The following query redirection rule is setup:
```
mysql_query_rules=
(
  {
    rule_id = 2
    active = 1
    match_pattern = "^SELECT\s*\/\*\s*REDIRECTION\_TEST\s*\*\/"
    apply = 1
    destination_hostgroup = 3
    comment = "Send to read-replica"
  }
)
```

## Environment setup
```
# Create certs 
./create_certs.sh 

# Bring up env 
docker compose up -d

# Bring down env
docker compose down
```

Notes:
- Database initialization data is in `docker/db/docker-entrypoint-initdb.d/`
- Primary / replica db config is in `docker/db/config`
- ProxySql config is in `docker/proxysql`

## Testing Redirection 

Send
```bash
# Login to db 
mycli mysql://docker@db.local:3306/classicmodels

# Query to primary - hostgroup=1
SELECT * from customers;

# Query to replica - hostgroup=3
SELECT /* REDIRECTION_TEST */ * from customers;
```

**Verify proxySQL redirected the query:**
```
# Login to proxySql
mycli -uradmin -pradmin -hproxysql.local -P6032

# How many a query rule was matched against 
select * from stats_mysql_query_rules

# How many queries were sent to a hostgroup 
select `hostgroup`,`Queries`, `srv_host` from stats_mysql_connection_pool
```

### Enable extra debugging
```
# Login to proxySql
mycli -uradmin -pradmin -hproxysql.local -P6032

# Turn on logging
SET mysql-eventslog_filename='/queries.log';
SET mysql-eventslog_default_log=1;
# Log in json format 
SET mysql-eventslog_format=2;
# Load changes to runtime
LOAD MYSQL VARIABLES TO RUNTIME;
```

**Sample Log line:**
```
{"client":"172.18.0.128:64022","digest":"0x4F33AE77FCE89DDF","duration_us":11702,"endtime":"2024-04-13 20:15:01.510946","endtime_timestamp_us":1713039301510946,"event":"COM_QUERY","hostgroup_id":3,"query":"SELECT /* REDIRECTION_TEST */ * from customers","rows_sent":122,"schemaname":"classicmodels","server":"db-replica:3306","starttime":"2024-04-13 20:15:01.499244","starttime_timestamp_us":1713039301499244,"thread_id":4,"username":"root"}
```