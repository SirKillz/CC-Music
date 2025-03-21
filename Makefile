# Names for the containers and volumes
APP_CONTAINER=app-container
STORAGE_CONTAINER=storage-container
NETWORK=cc_music_net
VOLUME_STORAGE=mysql_data:/var/lib/mysql
VOLUME_APP=storage_data:/data/files

# Build the containers
build:
	docker build -t $(STORAGE_CONTAINER) -f docker/Dockerfile.storage .
	docker build -t $(APP_CONTAINER) -f docker/Dockerfile.app .

# Create the network
create-network:
	docker network create $(NETWORK)

# Run the containers
run:
	docker run -d --name $(STORAGE_CONTAINER) --network $(NETWORK) --env-file .env -p 3306:3306 -v $(VOLUME_STORAGE) $(STORAGE_CONTAINER)
	docker run -d --name $(APP_CONTAINER) --network $(NETWORK) --env-file .env -p 8000:8000 -v $(VOLUME_APP) $(APP_CONTAINER)

# Stop and tear down the containers
down:
	docker stop $(STORAGE_CONTAINER)
	docker rm $(STORAGE_CONTAINER)
	docker stop $(APP_CONTAINER)
	docker rm $(APP_CONTAINER)

# Connect to the storage container
connect-storage:
	docker exec -it $(STORAGE_CONTAINER) mysql -u root -p