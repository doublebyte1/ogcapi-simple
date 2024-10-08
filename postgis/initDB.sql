-- CREATE SCHEMA geostore 
CREATE USER geostore LOGIN PASSWORD 'geostore1234f' NOINHERIT;

CREATE SCHEMA IF NOT EXISTS geostore AUTHORIZATION geostore;

-- GRANT USAGE ON SCHEMA geostore TO geostore ;
GRANT ALL PRIVILEGES ON SCHEMA geostore TO geostore ;

CREATE DATABASE dgt;

GRANT CONNECT ON DATABASE dgt TO geostore;
GRANT USAGE, CREATE ON SCHEMA public TO geostore;
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO geostore;
ALTER DEFAULT PRIVILEGES GRANT ALL ON SEQUENCES TO geostore;


GRANT SELECT ON public.spatial_ref_sys to geostore;
GRANT SELECT,INSERT,DELETE ON public.geometry_columns to geostore;

alter user geostore set search_path to geostore , public;