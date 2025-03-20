#include "manifests/justfile"
#import 'manifests/justfile'

nx-create:
  bunx create-nx-workspace --pm bun --preset=@monodon/rust

default:
    bun nx run-many -t test --parallel --max-parallel=10
    bun nx run-many -t lint --parallel --max-parallel=10
    bun nx run-many -t build --parallel --max-parallel=10
    #echo "Creating a local cluster for local development."
#    just _local
#    tilt up
#    helm install my-kubeshark kubeshark-helm-charts/kubeshark --version 52.3.69
#    helm repo add kubeshark-helm-charts https://helm.kubeshark.co/
nus:
  nu
  source manifests/scripts/ai.nu
  source manifests/scripts/cluster.nu
  source manifests/scripts/greet.nu
  get-hyperscaler
lint:
    popeye -A -s cm
    kubent -o json
    kubescape scan framework nsa --exclude-namespaces kube-system # mitre
    pnpm nx run-many -t lint --parallel --max-parallel=12
    kube-linter lint manifests/kustomize/base/deployment.yml manifests/kustomize/base/service-account.yaml manifests/kustomize/base/service.yml manifests/kustomize/base/network-policy.yaml manifests/kustomize/base/scale.yaml

#    -kubectl create secret generic secret-puller --from-file=creds=./tmp/secret-puller.json
#    -kubectl create configmap k6-load-test --from-file=tss.js
#    -kubectl create secret docker-registry docker-registry-secret --docker-server=me-west1-docker.pkg.dev  --docker-username=_json_key --docker-password="$(cat ./tmp/container-puller.json)" --docker-email=container-puller-sa@devops-386509.iam.gserviceaccount.com
cluster:
    -kind create cluster --config ./manifests/cluster/cluster.yaml
_local:
    -kind create cluster --config ./scripts/cluster.yaml
    sleep 20
    kubectl apply -f manifests/configs/stage.yaml
    -kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    timoni bundle apply -f manifests/bundle.cue -r manifests/runtime.cue --runtime-from-env

#    kubectl apply -k
#    timoni bundle build -f manifests/bundle.cue -r manifests/runtime.cue --runtime-from-env

# kubectl annotate node --all kwasm.sh/kwasm-node=true # Annonate the nodes to support wasm runtime
_echo:
    echo hello

kdash: # check from here - https://itnext.io/essential-cli-tui-tools-for-developers-7e78f0cd27db
    kdash
    ktop
    ctop
    lazydocker
    dive
    ATAC
    vegeta
    dog
    asciinema

run-func:
  crossplane render xr.yaml composition.yaml functions.yaml | crossplane validate schemaDir -
  crossplane validate xr.yaml composition.yaml functions.yaml

migrate:
  -sqlx migrate run --database-url=postgres://myuser:mypassword@localhost/mydatabase --source manifests/dbs/migrations/postgres/
_istio:
    -kind create cluster --config ./scripts/cluster.yaml
    sleep 20
    istioctl install --set profile=demo --yes
    kubectl label namespace default istio-injection=enabled
    kubectl apply -f manifests/configs/stage.yaml
    -kubectl create secret generic secret-puller --from-file=creds=./tmp/secret-puller.json
    -kubectl create configmap k6-load-test --from-file=tss.js
    -kubectl create secret docker-registry docker-registry-secret --docker-server=me-west1-docker.pkg.dev  --docker-username=_json_key --docker-password="$(cat ./tmp/container-puller.json)" --docker-email=container-puller-sa@devops-386509.iam.gserviceaccount.com
    timoni bundle apply -f manifests/bundle.cue -r manifests/runtime.cue --runtime-from-env

kustomize:
    kustomize build manifests/kustomize/overlays/prod -o output.yaml

migrations:
    sqlx migrate run --database-url=postgres://myuser:mypassword@localhost/mydatabase --source apps/web/playground/migrations/
    sqlx migrate run --database-url=postgres://myuser:mypassword@postgres-service.dbs.svc.cluster.local --source apps/web/playground/migrations/
    redis-cli XGROUP CREATE tasks_stream mygroup $ MKSTREAM
    redis-cli XGROUP CREATE users_stream mygroup $ MKSTREAM

buf:
    #buf init first
    #   add paths for proto files
    buf lint
    buf build
    buf generate

frame:
    cargo update
    cargo flamegraph
    cargo audit
    cross test --target mips64-unknown-linux-gnuabi64

bacon:
    bacon clippy
    bacon test
secrets:
  echo 'foo: ref+gcpsecrets://playground-447016/github-secret' | vals eval -f -
# see https://www.kcl-lang.io/docs/user_docs/guides/secret-management/vault for more examples with deployment - do not understand why add secret to annotation
ollama-k8s:
  https://github.com/open-webui/open-webui/blob/main/kubernetes/manifest/base/kustomization.yaml
ollama-docker:
  docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
  npx flowise start
