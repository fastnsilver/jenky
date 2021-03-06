# Jenky with Docker Compose

## Prerequisites

* Docker
* Docker Compose

> for Mac users: if you happened to have previously installed [Docker Toolbox](https://www.docker.com/products/docker-toolbox), it will happily [co-exist](https://docs.docker.com/docker-for-mac/docker-toolbox/) with [Docker for Mac](https://www.docker.com/docker-mac).


## Installing Docker for Mac

You're on a Mac (aren't you?). Install [Docker for Mac](https://download.docker.com/mac/stable/Docker.dmg).
Note: Docker Compose also happens to come with Docker for Mac.

## Installing Docker for Linux

Do yourself a favor and spin up an [Ubuntu 16.04 LTS](http://releases.ubuntu.com/16.04/) Linux VM on Azure, AWS, or GCP. Then follow installation and pos-installation instructions:

* [Installation](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-convenience-script)
* [Post-installation](https://docs.docker.com/engine/installation/linux/linux-postinstall/)

To install Docker Compose, consult [these instructions](https://docs.docker.com/compose/install/).

> Your VM should have port 443 (HTTPS) ingress rule assigned.


## Prep Jenkins instance for first use

Create a new SSH key as described [here](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/). Name your private key `jenky_rsa`.

Run the following shell scripts

### Local

```
./bootstrap-local.sh
```

Visit `http://localhost:8080`. (Or if you happen to be running Docker Toolbox, you're in a VM, so your IP address will be something like `http://192.68.99.100:8080`).

### Public cloud hosted

Before executing the script you will need to edit `hosts.env` and update all occurrences of `replace_with_*`

```
./bootstrap.sh
```

Visit the hostname (see `$JENKINS_HOST` in `hosts.env`) of the VM hosting your installation. (Only HTTPS ingress is allowed). 

You will be prompted to enter a password that is to be retrieved from startup log.

![unlock-jenkins](docs/unlock-jenkins.png)

To find it

```
docker exec jenkins-master /bin/bash
cat /var/jenkins_home/secrets/initialAdminPassword
```

Enter the value in the `Administrator password` field and click `Continue`.


Next, you will be prompted to install plugins.  

![customize-jenkins](docs/customize-jenkins.png)

You're advised to click `Install suggested plugins`.

Next, you will be prompted to create an `admin` account.

![create-account](docs/create-account.png)

Click `Save and Finish`.

Upon completion of account creation you can administer your Jenkins instance manually with `Manage Jenkins`.

All updates are persisted to the `jenky_data-volume` volume.


## Pre-installing plugins

See [Plugin Index](http://updates.jenkins-ci.org/download/plugins/). Add a plugin id for each plugin you wish to install to `plugins.txt`.  You should do this before executing `bootstrap.sh`.  If you wish to install plugins after the image has been built, just do so via `Manage Jenkins > Manage Plugins`.


## Notes on images and volume

### jenky_master

Based on the official Jenkins Docker image [here](https://hub.docker.com/_/jenkins/).

### jenky_nginx

Based on [Alpine](https://hub.docker.com/_/alpine/) Linux distro [here](https://hub.docker.com/_/nginx/)

### jenky_slave

Based on [OpenJDK 8](https://hub.docker.com/_/openjdk/) and modeled closely after [jenkinsci/docker-ssh-slave](github.com/jenkinsci/docker-ssh-slave)

### jenky_data-volume

To see volumes

```
docker volume ls
```

To prune volume

```
docker volume prune
```

## Regarding use of SSH Slaves

You have to build and register your own slaves with master.

### Why not use the Docker Slaves Plugin?

From Nicolas De Loof

> You should not have to bake Jenkins specific images.

You can certainly use the [Docker Slaves plugin](http://blog.loof.fr/2016/04/docker-slaves-jenkins-plugin-has-been.html) but it has some known limitations.

It has [experimental support for the Pipeline plugin](https://github.com/jenkinsci/docker-slaves-plugin#pipeline-job-support).

### Why not use Dockins?

As of 2017-01-24, still a [proof-of-concept](http://dockins.github.io)


## Installing GitHub credentials

Visit `https://github.com/settings/tokens` with an authenticated GitHub account.
Click the `Generate new token` button.

![github-token](docs/github-token.png)

Enter a value in `Token description` field. Click on `repo` checkbox. Then click the `Generate token` button.

You will be given a glance at the token.  Copy it!  Store it in a safe location.  You'll need it for the next step.

Create [new credentials](http://localhost/credentials/store/system/domain/_/newCredentials)

![new-credential](docs/new-credential.png)

Enter the token value in the `Password` field.  The `Username` field's value should be your GitHub account.  All other field values are flexible.


## Concourse, Sonarqube and Artifactory

Yes! This Docker Compose cluster also stands up instances of Concourse, Artifactory and SonarQube.

### Local

* Concourse `http://localhost:9090`
* Artifactory `http://localhost:8081`
* SonarQube `http://localhost:9000`

### Public cloud hosted

See `hosts.env`.  Access to these instances will be whatever you configured for `CONCOURSE_HOST`, `ARTIFACTORY_HOST` and `SONARQUBE_HOST`.

> Re: DNSSEC.  If you enable DNSSEC then be sure to verify that your domain registrar and all downstream NS providers support it! Otherwise LetsEncrypt will not properly vend certificates resulting in a dysfunctional Nginx proxy configuration. (E.g., Your domain registrar is Hover (no DNSSEC support) and you manage a sub-domain with DNSSEC enabled on a Cloud DNS zone on Google Cloud Platform).