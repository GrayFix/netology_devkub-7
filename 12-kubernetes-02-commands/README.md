# 12.2 Команды для работы с Kubernetes

1. Deployment Hello world в двух экземлярах:
    ```
    [root@centos7-tmp-2021 kube-rbac]# kubectl scale deploy hello-node --replicas=2
    deployment.apps/hello-node scaled
    
    [root@centos7-tmp-2021 kube-rbac]# kubectl get deploy
    NAME         READY   UP-TO-DATE   AVAILABLE   AGE
    hello-node   2/2     2            2           14h

    [root@centos7-tmp-2021 kube-rbac]# kubectl get pods
    NAME                          READY   STATUS    RESTARTS   AGE
    hello-node-6b89d599b9-2c4z9   1/1     Running   0          14h
    hello-node-6b89d599b9-c9b7b   1/1     Running   0          14h
    ```
2. Пример настройки авторизации по сертификату и роли с доступом на просмотр. По официальной документации `https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/`:
    ```
    # Создаем закрытый ключ
    openssl genrsa -out read-user.key 2048

    # Создаем запрос на сертификат, в качестве CN задается имя пользователя, в O можно задать группу
    openssl req -new -key read-user.key -out read-user.csr

    # Упаковываем запрос на сертификат в BASE64
    cat read-user.csr | base64 | tr -d "\n"

    # Добавляем запрос в kubernetes. Тут можно задать время жизни сертификата параметром expirationSeconds. По умолчанию 1 год.
    cat <<EOF | kubectl apply -f -
    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
    name: read-user
    spec:
    request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ216Q0NBWU1DQVFBd1ZqRUxNQWtHQTFVRUJoTUNXRmd4RlRBVEJnTlZCQWNNREVSbFptRjFiSFFnUTJsMAplVEVjTUJvR0ExVUVDZ3dUUkdWbVlYVnNkQ0JEYjIxd1lXNTVJRXgwWkRFU01CQUdBMVVFQXd3SmNtVmhaQzExCmMyVnlNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXJwTE11WmZoNEdnL3c5MkYKbVdtSUNNU0pOV1FWbWpkMXFTb3ZMT2o5ZXRvM1NaWG5tTklwb01SZ01FSittMXlicnBhbDdJT1EzVmJKVHJOYwpESkFiOElaNnFJWlMydW56K2NOY0p6OHo3MWV0a0krUTg3dlY0bWVPazlIVE9aK25zcTlidlFCVHBTcWpOZmNhClg4WVZBb3BoVUFUVm10S3pPZjJnc014ZXY0SjRHbERwVmM3Rm9MaUVtWFBmN1J2U2x4L0lKMTZmMWk3QWcrdHYKTVdyU0kyVkUrRFdUeHlJZngrcUpRNXc0Q3l4aWZhWHkyUk5PTVMvYTNYd3dnUXBsMEEvVitGcmVVaVB5UGdTMgo4Rkxza3JBZW9FelJFRkV5RDBzWVNuUzQ5dTRkUlgzdStKTjduTkhJYmI2cG1xT2NHSlFrZ21pS3YzRmlaT1pRClh1SGwvUUlEQVFBQm9BQXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSVhya0pqbTJYNEpZM1gzSlJ1K2ZhcXYKQmE1bUp3dWFLOXZDQVNKc3F0OElhaExCK1IwY3A4cmhZVzdKMmRMMzBJZURqUWl1Vktwdlh4SkFaY3BiaUoxWApzY2ZTQTMyTzIwZnJIM3pqWlNFV25BSFRKdFV6aVBJUlZkVkEweGIzaWFmazVoY2JZMEJlcktUSkZqQytOV1YrCkdFM1hSZ0FSWVlsdzU1SXdtbm5ZUkJhYm4zM2JDSjRVdDZnSDFQYVBWK1Nqc25sM042Wk8xSTRYNkIwYStyc0sKeWJvMHVneGNLU0lmVnhITTFIbUhQSTBDSzFjaGxWakNSbkF2T2FoSTVNamFDR3VHU2ZQNzRITzI3MllsdVl6MApkaUllaG1pUkFweEpZaUVzM2NZbURmTHJLTm92MHZTb1NMaHlTeGNnQ29Udld0d1NkWVdlSEpDK0Z1ZWxHWkk9Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
    signerName: kubernetes.io/kube-apiserver-client
    usages:
    - client auth
    EOF

    # Подписываем запрос и разрешаем доступ
    kubectl certificate approve read-user

    #Получаем публичную часть ключа для клиента
    kubectl get csr read-user -o jsonpath='{.status.certificate}'| base64 -d > read-user.crt

    #Создаем роль для namespace default с правом на просмотр и чтение pods и deplyment
    kubectl create role default-read-user --namespace default --resource="deployments","pods" --verb="get","list","watch"

    #CСвязываем роль и пользователя
    kubectl create rolebinding default-read-user-binding --role=default-read-user --user=read-user

    # Добавляем сертификат пользователя в .kube/config. Параметром --embed-certs=true прописываем сертификат в файл конфигурации
    kubectl config set-credentials read-user --client-key=read-user.key --client-certificate=read-user.crt --embed-certs=true

    #Добавляем контекст для созданного пользователя:
    kubectl config set-context read-user --cluster=minikube --namespace=default  --user=read-user
    ```

    Пример выполнения комманд от созданного пользоватлея
    ```
    # Просмотр pods
    [root@centos7-tmp-2021 .kube]# kubectl --context=read-user-context get po
    NAME                          READY   STATUS    RESTARTS   AGE
    hello-node-6b89d599b9-2c4z9   1/1     Running   0          15h
    hello-node-6b89d599b9-c9b7b   1/1     Running   0          14h

    # Просмотр описания конкретного pod
    [root@centos7-tmp-2021 .kube]# kubectl --context=read-user-context describe po hello-node-6b89d599b9-2c4z9
    Name:         hello-node-6b89d599b9-2c4z9
    Namespace:    default
    Priority:     0
    Node:         centos7-tmp-2021.ugmk.com/10.222.255.128
    Start Time:   Sun, 13 Mar 2022 22:32:52 +0500
    Labels:       app=hello-node
                pod-template-hash=6b89d599b9
    Annotations:  <none>
    Status:       Running
    IP:           172.17.0.2
    IPs:
    IP:           172.17.0.2
    Controlled By:  ReplicaSet/hello-node-6b89d599b9
    Containers:
    echoserver:
        Container ID:   docker://d990b956eff9f0e2e6c46a8579ee76e94087f863dc6ec60de7b20ee894f417a4
        Image:          k8s.gcr.io/echoserver:1.4
        Image ID:       docker-pullable://k8s.gcr.io/echoserver@sha256:5d99aa1120524c801bc8c1a7077e8f5ec122ba16b6dda1a5d3826057f67b9bcb
        Port:           <none>
        Host Port:      <none>
        State:          Running
        Started:      Sun, 13 Mar 2022 22:32:53 +0500
        Ready:          True
        Restart Count:  0
        Environment:    <none>
        Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-tnr4h (ro)
    Conditions:
    Type              Status
    Initialized       True
    Ready             True
    ContainersReady   True
    PodScheduled      True
    Volumes:
    kube-api-access-tnr4h:
        Type:                    Projected (a volume that contains injected data from multiple sources)
        TokenExpirationSeconds:  3607
        ConfigMapName:           kube-root-ca.crt
        ConfigMapOptional:       <nil>
        DownwardAPI:             true
    QoS Class:                   BestEffort
    Node-Selectors:              <none>
    Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                                node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
    Events:                      <none>

    #Прав на удаление нет
    [root@centos7-tmp-2021 .kube]# kubectl --context=read-user-context delete po hello-node-6b89d599b9-2c4z9
    Error from server (Forbidden): pods "hello-node-6b89d599b9-2c4z9" is forbidden: User "read-user" cannot delete resource "pods" in API group "" in the namespace "default"
    ```

3. Увеличение количества подов в deployment Hello Word
```
[root@centos7-tmp-2021 .kube]# kubectl scale deploy hello-node --replicas 5
deployment.apps/hello-node scaled

[root@centos7-tmp-2021 .kube]# kubectl get deploy
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   5/5     5            5           15h

[root@centos7-tmp-2021 .kube]# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-2c4z9   1/1     Running   0          15h
hello-node-6b89d599b9-9h7pr   1/1     Running   0          6s
hello-node-6b89d599b9-c9b7b   1/1     Running   0          15h
hello-node-6b89d599b9-qlzms   1/1     Running   0          6s
hello-node-6b89d599b9-wgcdx   1/1     Running   0          6s

```