# Names for the containers and volumes
APP_CONTAINER=app-container
STORAGE_CONTAINER=storage-container
APP_CONTAINER_PORT=8000
NGROK_DOMAIN=still-close-bobcat.ngrok-free.app

# Build the containers
build:
	docker-compose -f docker/docker-compose.yml build

# Run the containers
up:
	docker-compose -f docker/docker-compose.yml up -d

# Stop and tear down the containers
down:
	docker-compose -f docker/docker-compose.yml down

# Connect to the storage container
connect-storage:
	docker exec -it $(STORAGE_CONTAINER) mysql -u root -p

# Start ngrok for App-Container Port
ngrok-start:
	ngrok http $(APP_CONTAINER_PORT) --domain=$(NGROK_DOMAIN)

# Stop ngrok
ngrok-stop:
	taskkill /F /IM ngrok.exe