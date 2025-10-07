# terraform-aws-vpc-lattice

Configure EKS cluster:
```bash
aws eks update-kubeconfig --name eks-blue
aws eks update-kubeconfig --name eks-green
```

Set security group rules to allow VPC Lattice to communicate with EKS cluster:
```bash
./set-security-group-rules.sh
```

Install CRD for AWS Gateway Controller:
```bash
./install-crd.sh
```

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

https://gateway-api.sigs.k8s.io/

https://www.eksworkshop.com/docs/networking/vpc-lattice/

https://gallery.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart

---

Test from inside the cluster:
```bash
kubectl run netshoot --image=nicolaka/netshoot -- sleep infinity
kubectl exec -it netshoot -- bash
```
