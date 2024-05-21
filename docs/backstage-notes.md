## We've added this labels so they are recongnized by the Kubernetes plugin 
```yaml
labels:
    backstage.io/kubernetes-id: my-app-frontend
```

## We've accomodated the directory structure to more appropiately fit the new 
meme-web (used to be my-app) helm charts now exists within [/helm-charts/systems/ dir](/helm-charts/systems/) because now we have the possibility of other syetems existing.
So my-app is a sytem whinch includes my-app frontend  and my-app-backend but we could also have your-app system which might include any number of services.

## Flagger limitation
Backstage Kubernetes plugin doesnt show primary deployments because we can't tag the primary dpls through the FLagger canary