#!/usr/bin/make -f

SHELL = /bin/bash
NAME = jupyter
IMAGE = jupyter/datascience-notebook
IMAGE_VER = latest
IMAGE_TAG = ${IMAGE}:${IMAGE_VER}
SRCDIR = ${PWD}

# Set $_U to override the image's default user, for example:
# 	make container-shell _U=root

# Parameters for Docker commands
PNAME = --name ${NAME}
PUSER = $(if ${_U},--user ${_U},)

# I really should learn how to use Makefiles properly
lint: lint-super-linter
shell: container-shell
start: container-start
stop: container-stop

# Recipes
lint-super-linter:
	@echo "Linting all the things..."
	@docker run --rm \
		-e VALIDATE_DOCKERFILE=false \
		-e VALIDATE_ENV=false \
		-e RUN_LOCAL=true \
		-v "$(realpath ${SRCDIR})":"/tmp/lint":ro \
		github/super-linter
	@echo "All the things linted!"

container-shell:
	@echo "Running interactive ${NAME} shell..."
	@docker exec -it ${PUSER} ${NAME} ${SHELL} || \
		docker run -it --rm ${PNAME} ${PUSER} ${IMAGE_TAG} ${SHELL}
	@echo "Interactive ${NAME} shell finished!"

container-start:
	@echo "Starting detached ${NAME} container..."
	@docker run -d --rm ${PNAME} ${PUSER} ${IMAGE_TAG}
	@echo "Detached ${NAME} container started!"
	@docker logs --tail 5 jupyter

container-stop:
	@echo "Stopping ${NAME} container..."
	@docker stop "${NAME}"
	@echo "${NAME} container stopped!"
	@docker ps -a
