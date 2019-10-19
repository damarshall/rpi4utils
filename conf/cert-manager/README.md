## cert-manager deployment

This manifest comes from the 
[jetstack/cert-manager/releases/download/v0.11.0](wget https://github.com/jetstack/cert-manager/releases/tag/v0.11.0)
folder. The manifest __cert-manager.yaml__ is unmodified,
however it is patched via __kustomization.yaml__ to pick up _arm64_ images.
