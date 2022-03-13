# 12.1 Компоненты Kubernetes
1. Результат по поднятияю minikube. Поднима на CentOS 7:
    ```
    [root@centos7-tmp-2021 minikube]# minikube version
    minikube version: v1.25.2
    commit: 362d5fdc0a3dbee389b3d3f1034e8023e72bd3a7
    
    [root@centos7-tmp-2021 minikube]# minikube status
    minikube
    type: Control Plane
    host: Running
    kubelet: Running
    apiserver: Running
    kubeconfig: Configured

    [root@centos7-tmp-2021 usr]# kubectl get pods --namespace=kube-system
    NAME                                                READY   STATUS    RESTARTS   AGE
    coredns-64897985d-69rn6                             1/1     Running   0          2m5s
    etcd-centos7-tmp-2021.ugmk.com                      1/1     Running   0          2m18s
    kube-apiserver-centos7-tmp-2021.ugmk.com            1/1     Running   0          2m19s
    kube-controller-manager-centos7-tmp-2021.ugmk.com   1/1     Running   0          2m19s
    kube-proxy-qv669                                    1/1     Running   0          2m5s
    kube-scheduler-centos7-tmp-2021.ugmk.com            1/1     Running   0          2m19s
    storage-provisioner                                 1/1     Running   0          2m17s
    
    [root@centos7-tmp-2021 usr]# cat /etc/centos-release
    CentOS Linux release 7.9.2009 (Core)
    ```
2. Запуск Hello World:
    ```
    [root@centos7-tmp-2021 usr]# kubectl get pod,svc
    NAME                              READY   STATUS    RESTARTS   AGE
    pod/hello-node-6b89d599b9-gvhv2   1/1     Running   0          10m

    NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
    service/hello-node   LoadBalancer   10.100.17.239   <pending>     8080:31204/TCP   9m57s
    service/kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          13m

    [root@centos7-tmp-2021 usr]# minikube addons list
    |-----------------------------|----------|--------------|--------------------------------|
    |         ADDON NAME          | PROFILE  |    STATUS    |           MAINTAINER           |
    |-----------------------------|----------|--------------|--------------------------------|
    | ambassador                  | minikube | disabled     | third-party (ambassador)       |
    | auto-pause                  | minikube | disabled     | google                         |
    | csi-hostpath-driver         | minikube | disabled     | kubernetes                     |
    | dashboard                   | minikube | enabled ✅   | kubernetes                     |
    | default-storageclass        | minikube | enabled ✅   | kubernetes                     |
    | efk                         | minikube | disabled     | third-party (elastic)          |
    | freshpod                    | minikube | disabled     | google                         |
    | gcp-auth                    | minikube | disabled     | google                         |
    | gvisor                      | minikube | disabled     | google                         |
    | helm-tiller                 | minikube | disabled     | third-party (helm)             |
    | ingress                     | minikube | enabled ✅   | unknown (third-party)          |
    | ingress-dns                 | minikube | disabled     | google                         |
    | istio                       | minikube | disabled     | third-party (istio)            |
    | istio-provisioner           | minikube | disabled     | third-party (istio)            |
    | kong                        | minikube | disabled     | third-party (Kong HQ)          |
    | kubevirt                    | minikube | disabled     | third-party (kubevirt)         |
    | logviewer                   | minikube | disabled     | unknown (third-party)          |
    | metallb                     | minikube | disabled     | third-party (metallb)          |
    | metrics-server              | minikube | disabled     | kubernetes                     |
    | nvidia-driver-installer     | minikube | disabled     | google                         |
    | nvidia-gpu-device-plugin    | minikube | disabled     | third-party (nvidia)           |
    | olm                         | minikube | disabled     | third-party (operator          |
    |                             |          |              | framework)                     |
    | pod-security-policy         | minikube | disabled     | unknown (third-party)          |
    | portainer                   | minikube | disabled     | portainer.io                   |
    | registry                    | minikube | disabled     | google                         |
    | registry-aliases            | minikube | disabled     | unknown (third-party)          |
    | registry-creds              | minikube | disabled     | third-party (upmc enterprises) |
    | storage-provisioner         | minikube | enabled ✅   | google                         |
    | storage-provisioner-gluster | minikube | disabled     | unknown (third-party)          |
    | volumesnapshots             | minikube | disabled     | kubernetes                     |
    |-----------------------------|----------|--------------|--------------------------------|

    [root@centos7-tmp-2021 usr]# minikube service list
    |----------------------|------------------------------------|--------------|-----------------------------|
    |      NAMESPACE       |                NAME                | TARGET PORT  |             URL             |
    |----------------------|------------------------------------|--------------|-----------------------------|
    | default              | hello-node                         |         8080 | http://10.222.255.128:31204 |
    | default              | kubernetes                         | No node port |
    | ingress-nginx        | ingress-nginx-controller           | http/80      | http://10.222.255.128:32268 |
    |                      |                                    | https/443    | http://10.222.255.128:31174 |
    | ingress-nginx        | ingress-nginx-controller-admission | No node port |
    | kube-system          | kube-dns                           | No node port |
    | kubernetes-dashboard | dashboard-metrics-scraper          | No node port |
    | kubernetes-dashboard | kubernetes-dashboard               | No node port |
    |----------------------|------------------------------------|--------------|-----------------------------|
    ```
  
3. Kubectl установлен на Windows клиента
   ```
   C:\Users\vlad_Adm>kubectl get nodes
    NAME                        STATUS   ROLES                  AGE   VERSION
    centos7-tmp-2021.ugmk.com   Ready    control-plane,master   27m   v1.23.3
   ```

    Вывод `http://10.222.255.128:31204`:
    ```
    CLIENT VALUES:
    client_address=172.17.0.1
    command=GET
    real path=/
    query=nil
    request_version=1.1
    request_uri=http://10.222.255.128:8080/

    SERVER VALUES:
    server_version=nginx: 1.10.0 - lua: 10001

    HEADERS RECEIVED:
    accept=text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
    accept-encoding=gzip, deflate
    accept-language=ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7
    cache-control=max-age=0
    connection=keep-alive
    cookie=_ga=GA1.1.864707060.1641893305; csrftoken=yVNxUgdrwNGYN98zgJqIKti7AACTMGnMtwVRd4biYygyMkM3TZVnFt5lqL3NkRRp; sessionid=pua3ntdbq2cjhq337iqluq8zi0ibmfg9
    host=10.222.255.128:31204
    upgrade-insecure-requests=1
    user-agent=Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36
    BODY:
    -no body in request-
    ```

