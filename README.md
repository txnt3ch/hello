# hello service demo
**Switch ssh:**  <br/>
ssh-add -D  <br/>
ssh-add 1st_key  <br/>
ssh-add 2nd_key  <br/>

**========== START Clean up ==============================**  <br/>
#Delete namespace  <br/>
kubectl delete namespace eks-hello-app

#Delete cluster  <br/>
eksctl delete cluster --name hello-cluster --region ap-southeast-1  <br/>
#========== END Clean up ==============================  <br/>


#===== Create cluster  <br/>
eksctl create cluster --name hello-cluster --region ap-southeast-1 --instance-types <instance type>  <br/>


#===== Create application namespace  <br/>
kubectl create namespace eks-hello-app  <br/>

#===== Apply deployment & service manifest, or check the argocd/apps repo  <br/>
kubectl apply -f ./aws/eks-hello-deployment.yaml  <br/>
kubectl apply -f ./aws/eks-hello-service.yaml  <br/>
#Run shell on a pod - to replace with pod ID. Then curl the localhost:8080/greeting  <br/>
kubectl exec -it <pod ID> -n eks-hello-app -- /bin/bash  <br/>





#===== Install Argocd  <br/>
kubectl create namespace argocd  <br/>
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml  <br/>

#Change type to LoadBalancer  <br/>
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'  <br/>
export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`  <br/>

#Show the default password: ehNTxfS0XvSEIKSP  <br/>
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo;  <br/>

#Login to Argocd  <br/>
argocd login $ARGOCD_SERVER --username admin --password <password here> --insecure  <br/>
CONTEXT_NAME=`kubectl config view -o jsonpath='{.current-context}'`  <br/>
argocd cluster add $CONTEXT_NAME  <br/>

#Create the application - option 1  <br/>
argocd app create eks-hello-linux-app --repo https://github.com/txnt3ch/argocd-apps.git --path apps --dest-server https://1589A63B8955A6C6607187244561A0FE.gr7.ap-southeast-1.eks.amazonaws.com --dest-namespace eks-hello-app  <br/>

#Create the application - option 2  <br/>
#Create secret use in application.yaml  <br/>
kubectl --namespace argocd create secret generic git-creds --from-literal=username=txnt3ch --from-literal=password=xxx  <br/>
kubectl apply -f ../argocd-apps/application.yaml  <br/>
#or using helm chart  <br/>
kubectl apply -f ../hello-helm/application.yaml  <br/>

#Apply auto sync  <br/>
argocd app set eks-hello-linux-app --sync-policy automated  <br/>

#Or check the status and sync manually  <br/>
argocd app get eks-hello-linux-app  <br/>
argocd app sync eks-hello-linux-app  <br/>


#===== Install Argocd Image Updater  <br/>

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml  <br/>


#Read log  <br/>
kubectl --namespace argocd logs --selector app.kubernetes.io/name=argocd-image-updater --follow  <br/>

#Check if the app is running  <br/>
curl http://aaa8027ad80d74893b0fd4bcb7fa4d43-41055664.ap-southeast-1.elb.amazonaws.com:8080/greeting  <br/>
