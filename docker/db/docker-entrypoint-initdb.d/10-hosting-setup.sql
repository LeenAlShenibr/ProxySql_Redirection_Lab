ALTER USER 'root'@'%' IDENTIFIED BY 'labPass';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;


CREATE USER 'docker'@'%' IDENTIFIED BY 'labPass';
GRANT ALL PRIVILEGES ON *.* TO 'docker'@'%';