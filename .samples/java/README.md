## Java Builds

This sample will build a Java project using Maven, then build and push a Docker image to a Docker registry.

### Dockerfile

This Docker image employs an Alpine Linux Open JDK 8 JRE.

Assume that Spring Boot Maven [plugin](http://docs.spring.io/spring-boot/docs/current/maven-plugin/usage.html) was used to package an executable JAR.  Also note it is in template form so that e.g., during the `process-sources` phase of the Maven life-cycle the `project.*` variables could be [filtered](https://maven.apache.org/plugins/maven-resources-plugin/examples/filter.html) with values from POM via maven-resources

```
FROM openjdk:8-jre-alpine
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

// Expects tool configuration
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
