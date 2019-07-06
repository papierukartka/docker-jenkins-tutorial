# dockerized jenkins tutorial

## images

- pull:
  - docker pull jenkins/jenkins

- build:
  - based on a Dockerfile
    - docker build -t myjenkins .

## containers

- run (create from an image):
  - with ports & name: **-p outside_port:container_port --name=container-name**
    - docker run -p 8080:8080 --name=jenkins-master jenkins/jenkins
  - in daemon mode: **-d**
    - docker run -p 8080:8080 --name=jenkins-master -d jenkins/jenkins
  - with environment variables: **--env VARIABLE="value"**
    - give 8GB to JVM
      - docker run -p 8080:8080 --name=jenkins-master -d --env JAVA_OPTS="-Xmx8192m" jenkins/jenkins
    - add port 50000 for JNLP protocol (master-slave communication)
      - docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master -d --env JAVA_OPTS="-Xmx8192m" jenkins/jenkins
        - more options: [wiki.jenkins.io](https://wiki.jenkins.io/display/JENKINS/Starting+and+Accessing+Jenkins)

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

## volumes

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
