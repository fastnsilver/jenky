# @see https://github.com/jenkinsci/docker/blob/master/Dockerfile
FROM jenkins:2.32.1
MAINTAINER Chris Phillipson <fastnsilver@gmail.com>

# Install default plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/install-plugins.sh $(cat /usr/share/jenkins/plugins.txt | tr '\n' ' ')

USER root

# Install Docker from official repo
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -qqy apt-transport-https ca-certificates software-properties-common && \
    curl -s http://yum.dockerproject.org/gpg | apt-key add - && \
    apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D && \
    add-apt-repository \
    "deb https://apt.dockerproject.org/repo \
      debian-$(lsb_release -cs) \
      main" && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -qqy docker-engine && \
    gpasswd -a jenkins docker && \
    chown -R jenkins:jenkins $JENKINS_HOME/

ENV ANSIBLE_HOME=/opt/ansible

# Install Ansible (+deps) from git repo & cleanup
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -qqy \
        build-essential \
        python-pip python-dev python-yaml \
        libffi-dev libssl-dev \
        libxml2-dev libxslt1-dev zlib1g-dev && \
    pip install --upgrade wheel setuptools && \
    pip install --upgrade pyyaml jinja2 pycrypto && \
    git clone git://github.com/ansible/ansible.git --recursive && \
    cd ansible && \
    bash -c 'source ./hacking/env-setup' && \
    mkdir -p $ANSIBLE_HOME && \
    mv /ansible/bin $ANSIBLE_HOME/bin && \
    mv /ansible/lib $ANSIBLE_HOME/lib && \
    mv /ansible/docs $ANSIBLE_HOME/docs && \
    rm -rf /ansible && \
    apt-get install --no-install-recommends -qqy sshpass openssh-client && \
    apt-get remove -y --auto-remove build-essential python-pip python-dev libffi-dev libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts && \
    chown -R jenkins:jenkins $ANSIBLE_HOME/

USER jenkins

# Copy in the Docker certs, we'll use /usr/local/etc for them
COPY certs/ca-key.pem /usr/local/etc/jenkins/certs/ca-key.pem
COPY certs/ca.pem /usr/local/etc/jenkins/certs/ca.pem
COPY certs/cert.pem /usr/local/etc/jenkins/certs/cert.pem
COPY certs/key.pem /usr/local/etc/jenkins/certs/key.pem

ENV PATH=$ANSIBLE_HOME/bin:$PATH \
    PYTHONPATH=$ANSIBLE_HOME/lib:$PYTHONPATH \
    MANPATH=$ANSIBLE_HOME/docs/man:$MANPATH

VOLUME ["/var/jenkins_home", "/var/run/docker.sock", "/etc/ansible"]
