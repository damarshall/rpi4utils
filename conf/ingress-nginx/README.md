## ingress-nginx

The manifest in the directory is sourced from (https://github.com/kubernetes/ingress-nginx/tree/nginx-0.25.1/deploy/static)[https://github.com/kubernetes/ingress-nginx/tree/nginx-0.25.1/deploy/static]

__service-loadbalancer.yaml__ is project-specific. As we are deploying on bare-metal we'll front the our ingress 
with our loadbalancer.

Kustomization ensures we deploy an _arm64_ image.
