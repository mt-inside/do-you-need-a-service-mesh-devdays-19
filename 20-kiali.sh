# https://github.com/istio/istio/tree/master/addons/servicegraph

source 00-common.sh

set -x
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $(echo -n admin | base64)
  passphrase: $(echo -n admin | base64)
EOF
echo open http://localhost:20001/kiali/console
kubectl -n istio-system delete pod $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}')
sleep 5
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
