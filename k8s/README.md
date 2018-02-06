# Jenky with Kubernetes


## Prerequisites

If you want to run Kubernetes

* *locally* on a workstation or laptop, consider [Minikube](https://github.com/kubernetes/minikube).
* on a *public cloud*, consider [GKE](https://cloud.google.com/kubernetes-engine/), [EKS](https://aws.amazon.com/eks/), [AKS](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes), 
* *self-hosted*, consider [PKS](https://pivotal.io/platform/pivotal-container-service).

You'll also want to install [Helm](https://github.com/kubernetes/helm#install). Then consult [Using Helm](https://docs.helm.sh/using_helm/).

And last, but not least, install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).


## Running locally

### To start Kubernetes

```
minikube start
```

### Open dashboard

```
minikube dashboard
```

### To install charts

```
helm install stable/nginx-ingress --set controller.stats.enabled=true
helm install stable/jenkins
helm install stable/sonarqube
helm install stable/artifactory
helm install stable/concourse
```

### List services

```
kubectl get services
```

### Visit a service

```
minikube service {service_name}
```

### To stop Kubernetes

```
minikube stop
```


## Running on PKS

// TODO


## SSL termination and certificate regeneration

See this [article](http://blog.ployst.com/development/2015/12/22/letsencrypt-on-kubernetes.html
).