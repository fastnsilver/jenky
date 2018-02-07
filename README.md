# Jenky

![](http://i.imgur.com/KC6TAD3.png)

Configurable, integrated Docker-ized instances of Jenkins, Concourse, Artifactory and Sonarqube fronted by Nginx. Convenient for vetting builds in a local development environment. And robust enough to host a secure production CI/CD environment in the cloud.

## Credits

Standing on the shoulders of giants.

I couldn't have scraped this together without
* [A. J. Ricoveri](https://github.com/axltxl/docker-jenkins-dood)
* [Stefan Prodan](https://github.com/stefanprodan/jenkins)
* [Riot Games Engineering](https://engineering.riotgames.com/news/jenkins-ephemeral-docker-tutorial)
* [Ryan J. McDonough](https://damnhandy.com/2016/03/06/creating-containerized-build-environments-with-the-jenkins-pipeline-plugin-and-docker-well-almost/)
* [Alex Ellis](http://blog.alexellis.io/jenkins-2-0-first-impressions/)
* [Soheil Hassas Yeganeh](https://gist.github.com/soheilhy/8b94347ff8336d971ad0)
* [Evert Ramos](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion)


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

## Getting started

Pick your favorite container orchestrator

* [Docker Compose](compose/README.md)
* [Kubernetes + Helm](k8s/README.md)
