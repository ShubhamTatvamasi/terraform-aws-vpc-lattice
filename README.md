# terraform-aws-vpc-lattice

Deploy EKS and VPC:
```bash
terraform apply
```

Configure EKS cluster:
```bash
aws eks update-kubeconfig --name eks-blue
aws eks update-kubeconfig --name eks-green
aws eks update-kubeconfig --name eks-red
```

Set security group rules to allow VPC Lattice to communicate with EKS cluster:
```bash
./set-security-group-rules.sh red
```
> blue | green | red

Install CRD and AWS Gateway Controller:
```bash
./deploy-gateway-controller.sh red
```
> blue | green | red

Deploy nginx blue on Cluster A:
```bash
kubectl create deployment nginx-blue --image=shubhamtatvamasi/nginx-dynamic
kubectl expose deployment nginx-blue --port=80 --name=nginx-blue
kubectl set env deployment/nginx-blue NGINX_ENV=blue
```

Deploy nginx green on Cluster B:
```bash
kubectl create deployment nginx-green --image=shubhamtatvamasi/nginx-dynamic
kubectl expose deployment nginx-green --port=80 --name=nginx-green
kubectl set env deployment/nginx-green NGINX_ENV=green
```

Deploy nginx red on Cluster C:
```bash
kubectl create deployment nginx-red --image=shubhamtatvamasi/nginx-dynamic
kubectl expose deployment nginx-red --port=80 --name=nginx-red
kubectl set env deployment/nginx-red NGINX_ENV=red
```

Deploy GatewayClass and Gateway:
```bash
kubectl apply -f gatewayclass.yaml
kubectl apply -f gateway.yaml
```

Deploy HTTPRoute on Cluster A:
```bash
kubectl apply -f http-route.yaml
```

Export nginx-blue service from Cluster B:
```bash
kubectl apply -f nginx-green-service-export.yaml
```

Export nginx-red service from Cluster C:
```bash
kubectl apply -f nginx-red-service-export.yaml
```

https://gateway-api.sigs.k8s.io/

https://www.eksworkshop.com/docs/networking/vpc-lattice/

https://gallery.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart

---

Deploy netshoot pod for testing:
```bash
kubectl run netshoot --image=nicolaka/netshoot -- sleep infinity
kubectl exec -it netshoot -- bash
```

Test from inside the cluster:
```bash
curl aws.shubhamtatvamasi.com
```
