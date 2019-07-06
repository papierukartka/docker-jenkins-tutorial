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
