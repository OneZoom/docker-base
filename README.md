# docker-base

[![Build Status](https://travis-ci.com/madharjan/docker-base.svg?branch=master)](https://travis-ci.com/madharjan/docker-base)

Docker baseimage based on [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker)

To build, run `make build`. To release a new version, change the Ubuntu version in the
Makefile, and run `make release`, which will run a test suite (also available using
`make test`) and, if tests pass, attempt to push a release to docker.io.
You may need to run `make clean` beforehand. To specify building for a different platform
or set of platforms (e.g. on Mac ARM), specify e.g. `make build PLATFORM=linux/amd64,linux/arm64`.

## Changes

* Removed `ssh` service
* Updated to Ubuntu 24.04

## Features

* Environment variables to disable services
* Using scripts in `my_init.d` to initialize services (e.g 10-startup.sh, 20-nginx.sh .. etc)
* Using scripts in `my_shutdown.d` to cleanup services before container stop (e.g 80-postfix.sh ..etc)
* Bats ([bats-core/bats-core](https://github.com/bats-core/bats-core)) based test cases

## Ubuntu 24.04 (docker-base)

### Environment

| Variable       | Default | Example        |
|----------------|---------|----------------|
| DISABLE_SYSLOG | 0       | 1 (to disable) |
| DISABLE_CRON   | 0       | 1 (to disable) |

## Build

```bash
# clone project
git clone https://github.com/onezoom/docker-base
cd docker-base

# build
make

# tests
make run
make test

# clean
make clean
```

## Run

```bash
# stop & remove previous instances
docker stop base
docker rm base

# run container
docker run -d \
  -e DEBUG=false \
  -e DISABLE_SYSLOG=0 \
  -e DISABLE_CRON=0 \
  --name base onezoom/docker-base:24.04 \
  /sbin/my_init --log-level 3
```
