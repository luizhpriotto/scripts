echo "Preparando configurações...."

echo 'apiVersion: v1
kind: Config
clusters:
- name: "local"
  cluster:
    server: "https://@rancher_url@/k8s/clusters/local"

users:
- name: "local"
  user:
    token: "@option.k8s_prod@"


contexts:
- name: "local"
  context:
    user: "local"
    cluster: "local"

current-context: "local"' > /home/user/.kube/config

kubectl get namespace | awk '{print $1}' > _namespaces_

echo "Namespaces mapeados..."

cat _namespaces_

echo "Eliminando Pods..."
lines=$(cat _namespaces_)
for line in $lines
do
  for d in $(kubectl get pods -n $line | grep Termi | awk '{print $1}'); do kubectl delete pods/$d  --grace-period=0 --force -n $line; done 
done

rm -f _namespaces_

echo "" > /home/user/.kube/config
