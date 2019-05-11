source 00-common.sh

set -x

kubectl apply -f istio-$ISTIO_VERSION/install/kubernetes/namespace.yaml

helm template istio-$ISTIO_VERSION/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -

set -x

declare crd_count
while true
do
    crd_count=$(echo $(kubectl get crds | grep 'istio.io' | wc -l))
    echo "CRDs: $crd_count"
    if [ $crd_count -eq 53 ]
    then
        echo "OK."
        break
    else
        echo "Waiting..."
    fi
    sleep 1
done

set +x

# We do a custom config, but can specify --values and a file like install/kubernetes/helm/istio/values-istio-demo.yaml
$HELM template \
    --name istio \
    --namespace istio-system \
    istio-$ISTIO_VERSION/install/kubernetes/helm/istio \
    --set tracing.enabled=true \
    --set grafana.enabled=true \
    --set prometheus.enabled=true \
    --set servicegraph.enabled=true \
    --set kiali.enabled=true \
    | kubectl apply -f -
    #--set global.mTLS.enabled=true

kubectl label namespace default istio-injection=enabled
