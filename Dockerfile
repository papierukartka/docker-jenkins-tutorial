FROM jenkins/jenkins:lts
LABEL maintainer="mymail@gmail.com"
ENV JAVA_OPTS="-Xmx8192m"

USER root
RUN mkdir /var/log/jenkins
RUN mkdir /var/cache/jenkins
RUN chown -R jenkins:jenkins /var/log/jenkins
RUN chown -R jenkins:jenkins /var/cache/jenkins
USER jenkins

# webroot is the place of uncompressed jenkins.war file
ENV JENKINS_OPTS="--logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war"
