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
        - more options: https://wiki.jenkins.io/display/JENKINS/Starting+and+Accessing+Jenkins

- stop container:
  - default:
    - CTRL + c
  - daemonized:
    - docker stop jenkins-master

- remove container:
  - docker rm jenkins-master

- build image:
  - docker build -t myjenkins .

- execute command in container:
  - docker exec jenkins-master ps -ef | grep java
  - docker exec jenkins-master tail -f /var/log/jenkins/jenkins.log
  - docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword

- copy files from (not necessarily running) container:
  - docker cp jenkins-master:/var/log/jenkins/jenkins.log ./jenkins.log
