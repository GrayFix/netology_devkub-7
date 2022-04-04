# 13.1 контейнеры, поды, deployment, statefulset, services, endpoints

Оговорка, все нагрузки созданы на основе образов `praqma/network-multitool`.

1. Тестовый конфиг для запуска приложения:
  - Манифесты расположены в папке [stage](stage);
  - Первым запускается сервис для БД [10-service-db.yaml](stage/10-service-db.yaml), далее запускается сама БД в виде `StatefulSet` [20-deploy-db.yaml](stage/20-deploy-db.yaml);
  - `StatefulSet` зависит от прописанного в манифесте сервиса и без него не запускается;
  - Сам деплой приложения состоит из двух подов `frontend` и `backend` [30-deploy-app.yaml](stage/30-deploy-app.yaml);
  - `Frontend` слушает порт 8000, `backend` слушает порт 9000;
  - Для `backend` пода переменной окружения `DB_HOST` задан хост БД `kubernetes-01-stage-db`;
  - Для работы с тестовым окружением создан сервис [40-service-app.yaml](stage/40-service-app.yaml);
  - Пример выполнения:
```
root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/stage# kubectl get deploy,StatefulSet,po,svc -o wide
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS         IMAGES                                              SELECTOR
deployment.apps/kubernetes-01-stage-app   1/1     1            1           97s   frontend,backend   praqma/network-multitool,praqma/network-multitool   app=stage-app

NAME                                      READY   AGE   CONTAINERS   IMAGES
statefulset.apps/kubernetes-01-stage-db   1/1     97s   postgresql   praqma/network-multitool

NAME                                           READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
pod/kubernetes-01-stage-app-55479959d4-k77xb   2/2     Running   0          97s   10.233.90.24   node1   <none>           <none>
pod/kubernetes-01-stage-db-0                   1/1     Running   0          97s   10.233.90.23   node1   <none>           <none>

NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE    SELECTOR
service/kubernetes                ClusterIP   10.233.0.1      <none>        443/TCP             171m   <none>
service/kubernetes-01-stage-app   ClusterIP   10.233.43.148   <none>        8000/TCP,9000/TCP   97s    app=stage-app
service/kubernetes-01-stage-db    ClusterIP   10.233.55.197   <none>        5432/TCP            97s    app=stage-db

root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/stage# kubectl exec -it pod/kubernetes-01-stage-app-55479959d4-k77xb -c backend -- bash
bash-5.1# curl $DB_HOST:5432
Praqma Network MultiTool (with NGINX) - kubernetes-01-stage-db-0 - 10.233.90.23 - HTTP: 5432 , HTTPS: 8443
<br>
<hr>
<br>

<h1>05 Jan 2022 - Press-release: `Praqma/Network-Multitool` is now `wbitt/Network-Multitool`</h1>
```

2. Конфиг для production окружения:
  - Манифесты расположены в папке [prod](prod);
  - Манифесты с БД не сильно отличаются от `stage`, изменены только метки: [10-service-db.yaml](prod/10-service-db.yaml) и [20-deploy-db.yaml](prod/20-deploy-db.yaml);
  - Деплой для `backend` состоит из манифестов [30-deploy-back.yaml](prod/30-deploy-back.yaml) и [40-service-back.yaml](prod/40-service-back.yaml) и содержит один под;
  - Для пода `backend` переменной окружения `DB_HOST` задан хост БД `kubernetes-01-stage-db`;
  - Деплой для `frontend` состоит из манифестов [50-deploy-front.yaml](prod/50-deploy-front.yaml) и [60-service-front.yaml](prod/60-service-front.yaml) и содержит один под;
  - Для пода `frontend` переменной окружения `BACKEND_HOST` задан хост бэкенда `kubernetes-01-prod-back`;
  - Пример выполнения:
```
root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/prod# kubectl get deploy,StatefulSet,po,svc -o wide
NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                     SELECTOR
deployment.apps/kubernetes-01-prod-back    1/1     1            1           50s   backend      praqma/network-multitool   app=prod-back
deployment.apps/kubernetes-01-prod-front   1/1     1            1           50s   frontend     praqma/network-multitool   app=prod-front

NAME                                     READY   AGE   CONTAINERS   IMAGES
statefulset.apps/kubernetes-01-prod-db   1/1     50s   postgresql   praqma/network-multitool

NAME                                            READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
pod/kubernetes-01-prod-back-65c96b6774-9wv2k    1/1     Running   0          50s   10.233.90.26   node1   <none>           <none>
pod/kubernetes-01-prod-db-0                     1/1     Running   0          50s   10.233.90.25   node1   <none>           <none>
pod/kubernetes-01-prod-front-7788f59684-5mmkv   1/1     Running   0          50s   10.233.90.27   node1   <none>           <none>

NAME                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE    SELECTOR
service/kubernetes                 ClusterIP   10.233.0.1      <none>        443/TCP    177m   <none>
service/kubernetes-01-prod-back    ClusterIP   10.233.28.7     <none>        9000/TCP   50s    app=prod-back
service/kubernetes-01-prod-db      ClusterIP   10.233.34.94    <none>        5432/TCP   51s    app=prod-db
service/kubernetes-01-prod-front   ClusterIP   10.233.43.179   <none>        8000/TCP   50s    app=prod-front

root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/prod# kubectl exec -it pod/kubernetes-01-prod-back-65c96b6774-9wv2k -- bash  

bash-5.1# curl $DB_HOST:5432
Praqma Network MultiTool (with NGINX) - kubernetes-01-prod-db-0 - 10.233.90.25 - HTTP: 5432 , HTTPS: 8443
<br>
<hr>
<br>

<h1>05 Jan 2022 - Press-release: `Praqma/Network-Multitool` is now `wbitt/Network-Multitool`</h1>


root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/prod# kubectl exec -it pod/kubernetes-01-prod-front-7788f59684-5mmkv -- bash
bash-5.1# curl $BACKEND_HOST:9000
Praqma Network MultiTool (with NGINX) - kubernetes-01-prod-back-65c96b6774-9wv2k - 10.233.90.26 - HTTP: 9000 , HTTPS: 9443
<br>
<hr>
<br>

<h1>05 Jan 2022 - Press-release: `Praqma/Network-Multitool` is now `wbitt/Network-Multitool`</h1>
```

3. Endpoint на внешний ресурс api:
  - Манифесты расположены в папке [endpoints](endpoints);
  - Вариант 1: манифест [70-external-service-v1.yaml](endpoints/70-external-service-v1.yaml). Создается сервис и в описании сразу указывается что нужно использвоать внешнее имя `geocode-maps.yandex.ru`. Создание `endpoints` не требуется;
  - Вариант 2: манифесты [80-external-service-v2.yaml](endpoints/80-external-service-v2.yaml) и [81-external-endpoints-v2.yaml](endpoints/81-external-endpoints-v2.yaml). Создается сервис c путыми селекторами. Для сервиса создается одноименные ендпоинты. В ендпоинтах прописан IP адрес внешнего сервиса.
  - Пример выполнения:

```
root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/endpoints# kubectl get svc,ep -o wide
NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP              PORT(S)          AGE    SELECTOR
service/external-api-v1   ExternalName   <none>          geocode-maps.yandex.ru   80/TCP,443/TCP   34s    <none>
service/external-api-v2   ClusterIP      10.233.17.106   <none>                   80/TCP,443/TCP   34s    <none>
service/kubernetes        ClusterIP      10.233.0.1      <none>                   443/TCP          3h2m   <none>

NAME                        ENDPOINTS                              AGE
endpoints/external-api-v2   213.180.193.58:80,213.180.193.58:443   34s
endpoints/kubernetes        10.129.0.18:6443                       3h2m
```

Обращение к сервису по варианту 1.
```
root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/endpoints# curl external-api-v1 -v
*   Trying 213.180.193.58:80...
* TCP_NODELAY set
* Connected to external-api-v1 (213.180.193.58) port 80 (#0)
> GET / HTTP/1.1
> Host: external-api-v1
> User-Agent: curl/7.68.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not found
< Content-Length: 0
<
* Connection #0 to host external-api-v1 left intact
```

Вывод tcpdump при обращении по варианту 1. Видно общение в внешним сервисом.
```
root@cpl:/home/grayfix# tcpdump -i any port 80
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked v1), capture size 262144 bytes
07:47:48.056792 IP cpl.cluster.local.35122 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [S], seq 2297202495, win 64240, options [mss 1460,sackOK,TS val 3378524122 ecr 0,nop,wscale 7], length 0
07:47:48.057437 IP front-geocode-search-api.slb.maps.yandex.net.http > cpl.cluster.local.35122: Flags [S.], seq 3707764613, ack 2297202496, win 43338, options [mss 1410,sackOK,TS val 1092319938 ecr 3378524122,nop,wscale 8], length 0
07:47:48.057512 IP cpl.cluster.local.35122 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [.], ack 1, win 502, options [nop,nop,TS val 3378524123 ecr 1092319938], length 0
07:47:48.057597 IP cpl.cluster.local.35122 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [P.], seq 1:80, ack 1, win 502, options [nop,nop,TS val 3378524123 ecr 1092319938], length 79: HTTP: GET / HTTP/1.1
07:47:48.057885 IP front-geocode-search-api.slb.maps.yandex.net.http > cpl.cluster.local.35122: Flags [.], ack 80, win 169, options [nop,nop,TS val 1092319939 ecr 3378524123], length 0
07:47:48.058114 IP front-geocode-search-api.slb.maps.yandex.net.http > cpl.cluster.local.35122: Flags [P.], seq 1:46, ack 80, win 169, options [nop,nop,TS val 1092319939 ecr 3378524123], length 45: HTTP: HTTP/1.1 404 Not found
07:47:48.058129 IP cpl.cluster.local.35122 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [.], ack 46, win 502, options [nop,nop,TS val 3378524123 ecr 1092319939], length 0
07:47:48.058480 IP cpl.cluster.local.35122 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [F.], seq 80, ack 46, win 502, options [nop,nop,TS val 3378524124 ecr 1092319939], length 0
07:47:48.058826 IP front-geocode-search-api.slb.maps.yandex.net.http > cpl.cluster.local.35122: Flags [F.], seq 46, ack 81, win 169, options [nop,nop,TS val 1092319940 ecr 3378524124], length 0
07:47:48.058849 IP cpl.cluster.local.35122 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [.], ack 47, win 502, options [nop,nop,TS val 3378524124 ecr 1092319940], length 0
```

Обращение к сервису по варианту 2.
```
root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/endpoints# curl external-api-v2 -v
*   Trying 10.233.17.106:80...
* TCP_NODELAY set
* Connected to external-api-v2 (10.233.17.106) port 80 (#0)
> GET / HTTP/1.1
> Host: external-api-v2
> User-Agent: curl/7.68.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not found
< Content-Length: 0
<
* Connection #0 to host external-api-v2 left intact
```

Вывод tcpdump при обращении по варианту 2. Также видно общение в внешним сервисом.
```
root@cpl:/home/grayfix# tcpdump -i any port 80
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on any, link-type LINUX_SLL (Linux cooked v1), capture size 262144 bytes
07:49:55.170462 IP cpl.cluster.local.36828 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [S], seq 909611048, win 65495, options [mss 65495,sackOK,TS val 1648034346 ecr 0,nop,wscale 7], length 0
07:49:55.172898 IP front-geocode-search-api.slb.maps.yandex.net.http > cpl.cluster.local.36828: Flags [S.], seq 2719992464, ack 909611049, win 43338, options [mss 1410,sackOK,TS val 449161586 ecr 1648034346,nop,wscale 8], length 0
07:49:55.172948 IP cpl.cluster.local.36828 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [.], ack 1, win 512, options [nop,nop,TS val 1648034348 ecr 449161586], length 0
07:49:55.173119 IP cpl.cluster.local.36828 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [P.], seq 1:80, ack 1, win 512, options [nop,nop,TS val 1648034348 ecr 449161586], length 79: HTTP: GET / HTTP/1.1
07:49:55.173547 IP front-geocode-search-api.slb.maps.yandex.net.http > cpl.cluster.local.36828: Flags [.], ack 80, win 169, options [nop,nop,TS val 449161589 ecr 1648034348], length 0
07:49:55.173781 IP front-geocode-search-api.slb.maps.yandex.net.http > cpl.cluster.local.36828: Flags [P.], seq 1:46, ack 80, win 169, options [nop,nop,TS val 449161589 ecr 1648034348], length 45: HTTP: HTTP/1.1 404 Not found
07:49:55.173796 IP cpl.cluster.local.36828 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [.], ack 46, win 512, options [nop,nop,TS val 1648034349 ecr 449161589], length 0
07:49:55.182773 IP cpl.cluster.local.36828 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [F.], seq 80, ack 46, win 512, options [nop,nop,TS val 1648034358 ecr 449161589], length 0
07:49:55.184070 IP front-geocode-search-api.slb.maps.yandex.net.http > cpl.cluster.local.36828: Flags [F.], seq 46, ack 81, win 169, options [nop,nop,TS val 449161598 ecr 1648034358], length 0
07:49:55.184134 IP cpl.cluster.local.36828 > front-geocode-search-api.slb.maps.yandex.net.http: Flags [.], ack 47, win 512, options [nop,nop,TS val 1648034359 ecr 449161598], length 0
```