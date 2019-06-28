KUBECONFIG = $(shell kind get kubeconfig-path --name='kind')
export KUBECONFIG

build:
	docker build -t kute .
	docker tag kute jmcarbo/kute

kindbuild:
	docker run -ti -v $$PWD:/go/bin golang bash -c "CGO_ENABLED=0 GOOS=linux GO111MODULE=on go get -a -ldflags \"-extldflags '-staticr'\" sigs.k8s.io/kind@v0.4.0"

run:
	docker run -v /var/run/docker.sock:/var/run/docker.sock -ti jmcarbo/kute

forward:
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" kubectl port-forward svc/pydiosvc -n pydio 8080:8080

clusterup:
	kind create cluster --config examples/cluster.yaml

loadcerts:
	#KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" kubectl create secret tls imimscience --key=certs/imim.science.key --cert=certs/imim.science.crt -n kube-system
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" kubectl create secret tls imimscience --key=certs/imim.science.key --cert=certs/imim.science.crt -n pydio

clusterdown:
	kind delete cluster

installstorage:
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" kubectl delete storageclass standard
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" helm repo add rimusz https://charts.rimusz.net
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" helm upgrade --install hostpath-provisioner --namespace kube-system rimusz/hostpath-provisioner

installhelm:
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" kubectl -n kube-system create serviceaccount tiller
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" kubectl create clusterrolebinding tiller \
	   --clusterrole=cluster-admin \
	  --serviceaccount=kube-system:tiller
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" helm init --service-account tiller

installrancher:
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" helm install stable/cert-manager --name cert-manager --namespace kube-system --version v0.5.2
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" helm install rancher-latest/rancher --name rancher --namespace cattle-system --set tls=external
	#KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" helm install rancher-latest/rancher --name rancher --namespace cattle-system --set hostname=rancher.my.org --set tls=external

uninstallrancher:
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" helm delete --purge cert-manager 
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" helm delete --purge rancher 

forwardrancher:
	KUBECONFIG="$$(kind get kubeconfig-path --name='kind')" kubectl port-forward svc/rancher -n cattle-system 8443:80
