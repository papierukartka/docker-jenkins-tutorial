# dockerized jenkins tutorial

## Docker

### image

- pull:
  - docker pull jenkins/jenkins

- build:
  - based on a Dockerfile
    - docker build -t myjenkins .

### container

- run (create from an image):
  - with ports & name: **-p outside_port:container_port --name=container-name**
    - docker run -p 8080:8080 --name=jenkins-master jenkins/jenkins
      - note: if you're running docker network with nginx proxy listening on 80, you don't need jenkins to expose 8080 and can access jenkins by localhost:80
  - in daemon mode: **-d**
    - docker run -p 8080:8080 --name=jenkins-master -d jenkins/jenkins
  - with environment variables: **--env VARIABLE="value"**
    - give 8GB to JVM
      - docker run -p 8080:8080 --name=jenkins-master -d --env JAVA_OPTS="-Xmx8192m" jenkins/jenkins
    - add port 50000 for JNLP protocol (master-slave communication)
      - docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master -d --env JAVA_OPTS="-Xmx8192m" jenkins/jenkins
        - more options: [wiki.jenkins.io](https://wiki.jenkins.io/display/JENKINS/Starting+and+Accessing+Jenkins)
  - with network attached: **--network jenkins-net**
    - docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master --network jenkins-net --mount source=jenkins-log,target=/var/log/jenkins --mount source=jenkins-data,target=/var/jenkins_home -d myjenkins

- execute command in a running container:
  - docker exec jenkins-master ps -ef | grep java
  - docker exec jenkins-master tail -f /var/log/jenkins/jenkins.log
  - docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword

- copy files from (not necessarily running) container:
  - docker cp jenkins-master:/var/log/jenkins/jenkins.log ./jenkins.log

- start (existing container):
  - docker start jenkins-master

- stop:
  - default:
    - CTRL + c
  - daemonized:
    - docker stop jenkins-master

- remove:
  - docker rm jenkins-master

### volume

- *containers are disposable, volumes are permanent across disposes*

- create:
  - docker volume create jenkins-log

- delete:
  - docker volume rm jenkins-data
  - docker volume prune

- mount:
  - docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master --mount source=jenkins-log,target=/var/log/jenkins --mount source=jenkins-data,target=/var/jenkins_home -d myjenkins
    - when container which provided the data for volume is lost and you want to pull data out of the volume, you need to mount the volume to (any) container and then use docker cp.
    - if a volume doesn't exist, docker will create one based on the name given

### network

- docker can create a DNS name on the network that match the container name. If you create a container named `jenkins-master`, docker can create `http://jenkins-master:8080` for you. It's called "automatic service discovery".

- create
  - docker network create --driver bridge jenkins-net

- remove
  - docker network rm jenkins-net

### compose

- docker-compose names containers in the following manner: `[project]_[service]_[instance]`. This should be considered, for example, in our jenkins.conf nginx configuration(proxy pass)
- docker-compose has several API versions, the latest one being 3 atm.
- if you don't define a network, docker-compose will create one for you.
  - similarly, if any of defined volumes doesn't exist, docker-compose will create them
- docker-compose.yml structure:

```yaml
version: '3'  # docker-compose API version
volumes:  # docker volumes that should be made available
  jenkins-data:
  jenkins-log:
services:  # section used to define container startup
  master:  # service image corresponding to the `jenkins-master` container
    build: ./jenkins-master  # contains a relative path to a Dockerfile defining jenkins-master image
    ports:  # port mappings
      - "50000:50000"
    volumes:  # equivalent of `--mount` attribute
      - jenkins-log:/var/log/jenkins
      - jenkins-data:/var/jenkins_home
    networks:  # contains a network name the container will be using
      - jenkins-net
```

- build
  - docker-compose build

- spin things up
  - docker-compose -p jenkins up -d
    - **-p** - project name, in this case it's `jenkins`. It will be a prefix for all resources created with `docker-compose.yml`. If you don't provide this, a name will be derived from the folder `docker-compose.yml` is in
    - **-d** - run as a daemon

- see what's up
  - docker-compose -p jenkins ps
    - **ps** list of application containers

- put things down
  - docker compose -p jenkins down
    - **-v** add this option at the end if you want volumes deleted too

## nginx

### nginx.conf file

- must have settings:
  - **daemon off;** - by default nginx starts as a daemon and returns exit 0. This makes Docker think that the process has stopped and the container can be stopped. We don't want this to happen.
  - **proxy_set_header X-Real-IP $remote_addr;**
  - **proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;** - so Jenkins can interpret requests properly. This eliminates warnings about improperly set headers.

### jenkins.conf file

- must have settings:
  - **proxy_pass http://jenkins-master:8080;** - this expects a domain name of jenkins-master to exist (docker networks) 

### spinning up

- run nginx container on port 80 attached to jenkins-net
  - docker run -p 80:80 --name=jenkins-nginx --network jenkins-net -d myjenkinsnginx
