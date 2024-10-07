# OCG API Simple

*Keep it simple*

## Quick Setup

You will need `docker` and `docker-compose` installed in your system, in order to run this infrastructure. 

## Start pygeoapi

Type:

```
docker compose up
```

Or, if you want to run it in the background

```
docker compose up -d
```


## Environment Variables

This compositions read secrets from an environment file on this folder: ```.env```.

Create this file with the following format, replacing "SOMEPASSWORD" by a reasonable value.

```
POSTGRES_PASSWORD="SOMEPASSWORD"
POSTGRES_DB="geodb"
POSTGRES_USER="postgres"
DATABASE_URL=postgresql://postgres:SOMEPASSWORD@postgis/geodb
```

For Matomo we need also:

```
MYSQL_PASSWORD=matomo
MYSQL_DATABASE=matomo
MYSQL_USER=matomo
MARIADB_ROOT_PASSWORD=matomo
MATOMO_DATABASE_ADAPTER=mysql
MATOMO_DATABASE_TABLES_PREFIX=matomo_
MATOMO_DATABASE_USERNAME=matomo
MATOMO_DATABASE_PASSWORD=matomo
MATOMO_DATABASE_DBNAME=matomo
MARIADB_AUTO_UPGRADE=1
MARIADB_INITDB_SKIP_TZINFO=1
```

## Setup DB

Connect to DB:

```
psql -h localhost -U [USERNAME] -W
```

Donwload Shapefile from [here](https://www.dgterritorio.gov.pt/download/agt/).

Insert data:

```
docker run --network=ogcapi-simple_bridge1 -v "${PWD}/data:/mnt" ghcr.io/osgeo/gdal:ubuntu-full-3.8.4 \
ogr2ogr -a_srs "EPSG:3763" -t_srs "EPSG:4326" -f "PostgreSQL" PG:"dbname='geodb' user='postgres'
 host='postgis'" /mnt/CRUS+_31_julho2024.shp -lco GEOMETRY_NAME=geom -lco FID=OBJECTID -lco precision=NO -lco SPATIAL_INDEX=GIST \
-nlt PROMOTE_TO_MULTI -nln crus_31_julho2024 -overwrite
```

Create materialised view:

```
docker compose exec postgis  psql -U postgres -d geodb -f /tmp/create-views.sql
```


## Serving tiles from file

Generate MBTiles (but first, uncomment [this line](docker-compose.yml#+77) on docker compose):

```
docker compose exec tiles \
martin-cp  --output-file /data/crus_31_julho2024.mbtiles \
           --mbtiles-type normalized     \
           "--bbox=-9.52657060387,36.838268541,-6.3890876937,42.280468655"      \
           --min-zoom 0                  \
           --max-zoom 10                \
           --source crus_31_julho2024          \
           --save-config /data/config.yaml   \
           postgresql://postgres@postgis:5432/geodb
```

Remove the containers, uncomment line 77 and start the composition again.

## Serving tiles from static dir

```
docker run -it --rm -v $(pwd)/data:/data emotionalcities/tippecanoe \
tippecanoe -r1 -pk -pf --output-to-directory=/data/tiles/ --force --maximum-zoom=14 \
--extend-zooms-if-still-dropping --no-tile-compression /data/crus_31_julho2024.geojson
```

## Setup Matomo

Go to [http:localhost:8081](http:localhost:8081) and follow the wizard. Confirm everything until you initialized the DB. 

In the *Superuser* section please use 

```
username: user
password: matomo
```

(Otherwise you have to change this manually in ./matomo/refresh_logs.sh command)

In the *Set up a Website* section please use `http://localhost` as *Website URL*. 

Confirm all the next steps until you arrive to the end of the wizard (login screen).

The stats from the logs are refreshed every minute. So wait a minute before logging in.

When the containers are running, run this one-time configuration command:

```
docker compose exec matomo bash -c 'echo "proxy_uri_header = 1" >> /var/www/html/config/config.ini.php'
```

## License

This project is released under an [MIT License](./LICENSE)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)