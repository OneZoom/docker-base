
NAME = onezoom/docker-base
VERSION = 24.04

DEBUG ?= true
PLATFORM ?= 

PLATFORM_ARG = $(if $(PLATFORM),--platform $(PLATFORM),)
DOCKER_USERNAME ?= $(shell read -p "DockerHub Username: " pwd; echo $$pwd)
DOCKER_PASSWORD ?= $(shell stty -echo; read -p "DockerHub Password: " pwd; stty echo; echo $$pwd)
DOCKER_LOGIN ?= $(shell cat ~/.docker/config.json | grep "docker.io" | wc -l)

.PHONY: all build run test stop clean tag_latest release clean_images

all: build

docker_login:
ifeq ($(DOCKER_LOGIN), 1)
		@echo "Already login to DockerHub"
else
		@docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)
endif

build:
	docker build $(PLATFORM_ARG) \
	 --build-arg UBUNTU_VERSION=${VERSION} \
	 --build-arg VCS_REF=`git rev-parse --short HEAD` \
	 --build-arg DEBUG=$(DEBUG) \
	 -t $(NAME):$(VERSION) --rm .

run:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi

	docker run $(PLATFORM_ARG) -d \
		-e DEBUG=$(DEBUG) \
		--name base $(NAME):$(VERSION) \
		/sbin/my_init --log-level 3

	sleep 1

	docker run $(PLATFORM_ARG) -d \
		-e DEBUG=$(DEBUG) \
		-e DISABLE_SYSLOG=1 \
		--name base_no_syslog $(NAME):$(VERSION)

	sleep 1

	docker run $(PLATFORM_ARG) -d \
		-e DEBUG=$(DEBUG) \
		-e DISABLE_CRON=1 \
		--name base_no_cron $(NAME):$(VERSION)

	sleep 1

test:
	sleep 2
	./bats/bin/bats test/tests.bats

stop:
	docker stop base base_no_syslog base_no_cron 2> /dev/null || true

clean: stop
	docker rm base base_no_syslog base_no_cron 2> /dev/null || true
	docker images | grep "<none>" | awk '{print$3 }' | xargs docker rmi 2> /dev/null || true

publish: docker_login run test clean
	docker push $(NAME)

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: docker_login  run test clean tag_latest
	docker push $(NAME)

clean_images: clean
	docker rmi $(NAME):latest $(NAME):$(VERSION) 2> /dev/null || true
	docker logout 


