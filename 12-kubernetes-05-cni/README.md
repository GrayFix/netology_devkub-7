# 12.5 Сетевые решения CNI

1. CNI Calico выбран в kubespray по умолчанию. Я так и не понял откуда брать hello-world. Нашел первый попавшийся в интернете. Примеры настройки политики можно посмотреть по [ссылке](example).
   - Развертывается три деплоя приложения hello-world с разными именами и разными label - [myapp](example/myapp.yaml), [myapp2](example/myapp2.yaml), [myapp3](example/myapp3.yaml);
   - Политикой [test-network-policy](example/netpol.yaml) для подов из деплоя `myapp` разрешается доступ до порта 3000/tcp только от подов с селекторами `app: myapp2`.

    Пример доступа из подов деплоя myapp3:
    ```
    app@myapp3-7d8f8b8785-zvr7x:/app$ curl -m 1 10.233.69.2:3000
    curl: (28) Connection timed out after 1002 milliseconds
    ```
    Пример доступа из подов деплоя myapp2:
    ```
    app@myapp2-7bc68f656-vfsgg:/app$ curl -m 1 10.233.69.2:3000
    <html>
    <head>
        <title>Polar Squad</title>
        <link rel="shortcut icon" type="image/x-icon" href="/assets/favicon.ico" />
        <link
        href="//fonts.googleapis.com/css?family=Raleway:400,300,600"
        rel="stylesheet"
        type="text/css"
        />
        <link
        rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/skeleton/2.0.4/skeleton.min.css"
        type="text/css"
        />
    ```   
2. Утилита `calicoctl` устанавливается kubespray. 
   Примеры команд `calicoctl get`:
    ```
    root@kube-cpl:/data# calicoctl get nodes
    NAME
    kube-cpl
    kube-w01
    kube-w02
    kube-w03
    kube-w04

    root@kube-cpl:/data# calicoctl get ippool
    NAME           CIDR             SELECTOR
    default-pool   10.233.64.0/18   all()

    root@kube-cpl:/data# calicoctl get profile
    NAME
    projectcalico-default-allow
    kns.default
    kns.ingress-nginx
    kns.kube-node-lease
    kns.kube-public
    kns.kube-system
    ksa.default.default
    ksa.ingress-nginx.default
    ksa.ingress-nginx.ingress-nginx
    ksa.kube-node-lease.default
    ksa.kube-public.default
    ksa.kube-system.attachdetach-controller
    ksa.kube-system.bootstrap-signer
    ksa.kube-system.calico-kube-controllers
    ksa.kube-system.calico-node
    ksa.kube-system.certificate-controller
    ksa.kube-system.clusterrole-aggregation-controller
    ksa.kube-system.coredns
    ksa.kube-system.cronjob-controller
    ksa.kube-system.daemon-set-controller
    ksa.kube-system.default
    ksa.kube-system.deployment-controller
    ksa.kube-system.disruption-controller
    ksa.kube-system.dns-autoscaler
    ksa.kube-system.endpoint-controller
    ksa.kube-system.endpointslice-controller
    ksa.kube-system.endpointslicemirroring-controller
    ksa.kube-system.ephemeral-volume-controller
    ksa.kube-system.expand-controller
    ksa.kube-system.generic-garbage-collector
    ksa.kube-system.horizontal-pod-autoscaler
    ksa.kube-system.job-controller
    ksa.kube-system.kube-proxy
    ksa.kube-system.namespace-controller
    ksa.kube-system.node-controller
    ksa.kube-system.nodelocaldns
    ksa.kube-system.persistent-volume-binder
    ksa.kube-system.pod-garbage-collector
    ksa.kube-system.pv-protection-controller
    ksa.kube-system.pvc-protection-controller
    ksa.kube-system.replicaset-controller
    ksa.kube-system.replication-controller
    ksa.kube-system.resourcequota-controller
    ksa.kube-system.root-ca-cert-publisher
    ksa.kube-system.service-account-controller
    ksa.kube-system.service-controller
    ksa.kube-system.statefulset-controller
    ksa.kube-system.token-cleaner
    ksa.kube-system.ttl-after-finished-controller
    ksa.kube-system.ttl-controller
    ```
