# hello service demo
**Switch ssh:**  
ssh-add -D  
ssh-add 1st_key  
ssh-add 2nd_key  

**========== START Clean up ==============================**  
#Delete namespace  
kubectl delete namespace eks-hello-app

#Delete cluster  
eksctl delete cluster --name hello-cluster --region ap-southeast-1  
#========== END Clean up ==============================  


#===== Create cluster  
eksctl create cluster --name hello-cluster --region ap-southeast-1 --instance-types <instance type>  


#===== Create application namespace  
kubectl create namespace eks-hello-app  

#===== Apply deployment & service manifest, or check the argocd/apps repo  
kubectl apply -f ./aws/eks-hello-deployment.yaml  
kubectl apply -f ./aws/eks-hello-service.yaml  
#Run shell on a pod - to replace with pod ID. Then curl the localhost:8080/greeting  
kubectl exec -it <pod ID> -n eks-hello-app -- /bin/bash  





#===== Install Argocd  
kubectl create namespace argocd  
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml  

#Change type to LoadBalancer  
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'  
export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`  

#Show the default password: ehNTxfS0XvSEIKSP  
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo;  

#Login to Argocd  
argocd login $ARGOCD_SERVER --username admin --password <password here> --insecure  
CONTEXT_NAME=`kubectl config view -o jsonpath='{.current-context}'`  
argocd cluster add $CONTEXT_NAME  

#Create the application - option 1  
argocd app create eks-hello-linux-app --repo https://github.com/txnt3ch/argocd-apps.git --path apps --dest-server https://1589A63B8955A6C6607187244561A0FE.gr7.ap-southeast-1.eks.amazonaws.com --dest-namespace eks-hello-app  

#Create the application - option 2  
#Create secret use in application.yaml  
kubectl --namespace argocd create secret generic git-creds --from-literal=username=txnt3ch --from-literal=password=xxx  
kubectl apply -f ../argocd-apps/application.yaml  
#or using helm chart  
kubectl apply -f ../hello-helm/application.yaml  

#Apply auto sync  
argocd app set eks-hello-linux-app --sync-policy automated  

#Or check the status and sync manually  
argocd app get eks-hello-linux-app  
argocd app sync eks-hello-linux-app  


#===== Install Argocd Image Updater  

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml  


#Read log  
kubectl --namespace argocd logs --selector app.kubernetes.io/name=argocd-image-updater --follow  

#Check if the app is running  
curl http://aaa8027ad80d74893b0fd4bcb7fa4d43-41055664.ap-southeast-1.elb.amazonaws.com:8080/greeting  
