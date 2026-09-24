-- backend/db/configure.sql
CREATE USER greenpages WITH PASSWORD 'greenpages';
CREATE DATABASE greenpages OWNER greenpages;
GRANT ALL PRIVILEGES ON DATABASE greenpages TO greenpages;
