FROM openjdk:8-jdk

MAINTAINER Chris Phillipson <fastnsilver@gmail.com>

ENV HOME /home/jenkins
RUN useradd -c "Jenkins user" -d $HOME -m jenkins

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/3.9/remoting-3.9.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

VOLUME /home/jenkins
WORKDIR /home/jenkins

# setup SSH server
RUN apt-get update && apt-get install -y openssh-server
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN mkdir -p /var/run/sshd

COPY setup-sshd /usr/local/bin/setup-sshd

EXPOSE 22

ENTRYPOINT ["setup-sshd"]
