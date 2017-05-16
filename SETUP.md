# Starting docker

	docker-compose up

# Running migrations

	phpContainerId=`docker inspect --format="{{.Id}}" enthraler_php_1`
	docker exec -i $phpContainerId php index.php
