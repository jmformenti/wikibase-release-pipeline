# Example docker compose configuration

The example docker compose configuration consists of two files:

- `docker-compose.yml` contains two services: wikibase and mysql
- `docker-compose.extra.yml` contains additional services such as wdqs, wdqs-frontend, elasticsearch and quickstatements

**We recommend you go through `docker-compose.extra.yml` and remove any unwanted services.**

**This configuration serves as an example of how the images could be used together and isn't production ready**

## Configure your installation

Copy `template.env` to `.env` and replace the passwords and secrets with your own.

## Running a Wikibase instance

To run a Wikibase instance on port 80 run the following command:

```
docker compose up
```

This will start up the services defined in [docker-compose.yml](docker-compose.yml), a Wikibase instance, database and a job runner.

## Job runner

The example docker-compose.yml sets up a dedicated job runner which restarts itself after every job, to ensure that changes to the configuration are picked up as quickly as possible.

If you run large batches of edits, this job runner may not be able to keep up with edits.

You can speed it up by increasing the `MAX_JOBS` variable to run more jobs between restarts, if you’re okay with configuration changes not taking effect in the job runner immediately. Alternatively, you can run several job runners in parallel by using the `--scale` option.

```sh
docker compose up --scale wikibase-jobrunner=8
```

## Running additional services

The Wikibase bundle comes with some additional services that can be enabled.

- wdqs
- wdqs-updater
- wdqs-frontend
- quickstatements
- elasticsearch

### 1. Run with the extra configuration

```
docker compose -f docker-compose.yml -f docker-compose.extra.yml up
```

In the volumes section of the wikibase service in [docker-compose.extra.yml](docker-compose.extra.yml), there is one additional script inside the container that automatically sets up the extensions needed for the additional services.

```yml
- ./extra-install.sh:/extra-install.sh
```

Looking inside extra-install.sh, you see that it executes two scripts which set up an OAuth consumer for quickstatements and creates indices for Elasticsearch.

There are also additional environment variables passed into Wikibase to configure the Elasticsearch host and port.

```yml
MW_ELASTIC_HOST: ${MW_ELASTIC_HOST}
MW_ELASTIC_PORT: ${MW_ELASTIC_PORT}
```

## Running Quickstatements batches

To run batches in the background, follow these steps:

1. Import data from the UI using the "Run in background" button (just one statement is sufficient).
2. Go to your user profile and copy the generated token.
3. Use that token to import data via the command line:
```
curl http://localhost:8840/api.php -d action=import -d submit=1 -d format=v1 -d username=<your-user> -d "batchname=<your-batch-name>" --data-raw 'token=<your-token>' --data-urlencode data@<file-to-import>
```
4. Schedule the batch job to import all the generated batches, for example, using crontab:
```
crontab quickstatements/crontabs.txt
```

