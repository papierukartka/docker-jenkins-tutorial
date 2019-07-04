# dockerized jenkins tutorial

- start container:
  - default:
    - docker pull jenkins/jenkins
    - docker run -p 8080:8080 --name=jenkins-master jenkins/jenkins
  - in daemon mode:
    - docker run -p 8080:8080 --name=jenkins-master -d jenkins/jenkins
  - with environment variables:
    - give 8GB to JVM
      - docker run -p 8080:8080 --name=jenkins-master -d --env JAVA_OPTS="-Xmx8192m" jenkins/jenkins
    - add port 50000 for JNLP protocol (master-slave communication)
      - docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master -d --env JAVA_OPTS="-Xmx8192m" jenkins/jenkins
        - more options: https://wiki.jenkins.io/display/JENKINS/Starting+and+Accessing+Jenkins

- stop container:
  - default:
    - CTRL + c
  - daemonized:
    - docker stop jenkins-master

- remove:
  - container
    - docker rm jenkins-master
  - volume
    - docker volume rm jenkins-data
    - docker volume prune

- build image:
  - docker build -t myjenkins .

- execute command in container:
  - docker exec jenkins-master ps -ef | grep java
  - docker exec jenkins-master tail -f /var/log/jenkins/jenkins.log
  - docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword

- copy files from (not necessarily running) container:
  - docker cp jenkins-master:/var/log/jenkins/jenkins.log ./jenkins.log

- create docker volume:
  - docker volume create jenkins-log

- mount docker volume:
  - docker run -p 8080:8080 -p 50000:50000 --name=jenkins-master --mount source=jenkins-log,target=/var/log/jenkins -d myjenkins
    * when container which provided the data for volume is lost and you want to pull data out of the volume, you need to mount the volume to (any) container and then use docker cp.
