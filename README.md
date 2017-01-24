# Jenky

![](http://i.imgur.com/KC6TAD3.png)

A configurable Docker-ized instance of Jenkins fronted by Nginx.
Convenient for vetting builds in a local development environment.

## Credits

Standing on the shoulders of giants.

I couldn't have scraped this together without
* [A. J. Ricoveri](https://github.com/axltxl/docker-jenkins-dood)
* [Stefan Prodan](https://github.com/stefanprodan/jenkins)
* [Riot Games Engineering](https://engineering.riotgames.com/news/jenkins-ephemeral-docker-tutorial)
* [Ryan J. McDonough](https://damnhandy.com/2016/03/06/creating-containerized-build-environments-with-the-jenkins-pipeline-plugin-and-docker-well-almost/)


## Prerequisites

* Docker for Mac

If you happened to have previously installed [Docker Toolbox](https://www.docker.com/products/docker-toolbox), it will happily [co-exist](https://docs.docker.com/docker-for-mac/docker-toolbox/) with Docker for Mac.


## How to obtain the source

You'll use a git client.

#### with HTTPS

```
git clone https://github.com/fastnsilver/jenky.git
```

#### with SSH

```
git clone git@github.com:fastnsilver/jenky.git
```

## Installing Docker for Mac

You're on a Mac (aren't you?). Install [Docker for Mac](https://download.docker.com/mac/stable/Docker.dmg).


## Prep Jenkins instance for first use

```
./bootstrap.sh
```

Visit `http://localhost`.

You will be prompted to enter a password that is to be retrieved from startup log.

![unlock-jenkins](docs/unlock-jenkins.png)

To find it

```
docker exec master /bin/bash
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

### jenky_data-volume

To see volumes

```
docker volume ls
```

To remove volume

```
docker volume rm jenky_data-volume
```

## Installing GitHub credentials

Visit `https://github.com/settings/tokens` with an authenticated GitHub account.
Click the `Generate new token` button.

![github-token](docs/github-token.png)

Enter a value in `Token description` field. Click on `repo` checkbox. Then click the `Generate token` button.

You will be given a glance at the token.  Copy it!  Store it in a safe location.  You'll need it for the next step.

Create [new credentials](http://localhost/credentials/store/system/domain/_/newCredentials)

![new-credential](docs/new-credential.png)

Enter the token value in the `Password` field.  The `Username` field's value should be your GitHub account.  All other field values are flexible.


## Background

* Trying to run a "sibling" Docker process as described [here](http://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/#the-solution).
* Executing a GitHub pipeline with `Jenkinsfile` when using the [Cloudbees Docker Pipeline Plugin](https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/index.html#docker-workflow-sect-inside).


## Sample

This sample will build a Java project using Maven, then build and push a Docker image to a Docker registry.

### Dockerfile

This Docker image employs an Alpine Linux Open JDK 8 JRE.

Assume that Spring Boot Maven [plugin](http://docs.spring.io/spring-boot/docs/current/maven-plugin/usage.html) was used to package an executable JAR.  Also note it is in template form so that e.g., during the `process-sources` phase of the Maven life-cycle the `project.*` variables could be [filtered](https://maven.apache.org/plugins/maven-resources-plugin/examples/filter.html) with values from POM via maven-resources

```
FROM java:openjdk-8-jre-alpine
MAINTAINER Chris Phillipson
RUN mkdir -p /opt/@project.artifactId@/bin
COPY @project.artifactId@-@project.version@-exec.jar /opt/@project.artifactId@/bin
ENTRYPOINT exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /opt/@project.artifactId@/bin/@project.artifactId@-@project.version@-exec.jar
```

### Jenkinsfile

Parameters are expected to be declared in the Jenkins job configuration (i.e., Build parameters).

```
#!groovy

node {

    echo "Running ${env.BUILD_ID} on ${env.JENKINS_URL} with"
    echoParameters()

    // @see https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/index.html#docker-workflow-sect-endpoints
    docker.withRegistry("$DOCKER_REGISTRY_URL", "$DOCKER_CREDENTIALS") {

        stage ('Checkout') {
            git branch: "$GIT_BRANCH", credentialsId: "$GIT_CREDENTIALS", url: "$GIT_REPO"

            // Get the commit id
            commit_id = sh(script: 'git rev-parse --verify HEAD', returnStdout: true).trim()
            echo "COMMIT_ID = " + commit_id

            // Get the email address of committer
            committer = sh(script: 'git --no-pager show -s --format="%ae" ${commit_id}', returnStdout: true).trim()
            echo "COMMITER = " + committer
        }

        stage ('Build JAR') {
            mvn "clean verify"
            junit testResults: "**/surefire-reports/*.xml"
            // publishHTML(target:[allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "target/site/jacoco", reportFiles: "index.html", reportName: "Jacoco report"])
        }

        stage ('Build Docker Image') {
            container = docker.build("$CONTAINER_OWNER/$CONTAINER_NAME:$DEFAULT_TAG", 'target')
        }

        stage ('Publish Docker Image') {
            container.push(commit_id)
        }

    }
}

def mvn(args) {
    sh "${tool 'M3'}/bin/mvn ${args}"
}

def echoParameters() {
    echo "> GIT_REPO = $GIT_REPO"
    echo "> GIT_BRANCH = $GIT_BRANCH"
    echo "> GIT_CREDENTIALS = $GIT_CREDENTIALS"
    echo "> DOCKER_REGISTRY_URL = $DOCKER_REGISTRY_URL"
    echo "> DOCKER_CREDENTIALS = $DOCKER_CREDENTIALS"
    echo "> DEFAULT_TAG = $DEFAULT_TAG"
    echo "> CONTAINER_OWNER = $CONTAINER_OWNER"
    echo "> CONTAINER_NAME = $CONTAINER_NAME"
}
```
