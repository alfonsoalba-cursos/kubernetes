echo "$ kubectl get rs"
kubectl get rs -n demo-deployment

echo "$ kubectl get pods"
kubectl get pods -n demo-deployment

echo "$ kubectl describe deployment foo-website -n demo-deployment"
kubectl describe deployment foo-website -n demo-deployment
