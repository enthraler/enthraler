#!/bin/bash

# Get the container id of the database container
dirName=${PWD##*/}
mysqlContainerId=`docker inspect --format="{{.Id}}" ${dirName}_db_1`
phpContainerId=`docker inspect --format="{{.Id}}" ${dirName}_php_1`

# Run the database migrations
docker exec -it $phpContainerId php index.php

echo "Successfully ran ufront migrations."
