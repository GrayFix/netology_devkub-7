# 13.5 поддержка нескольких окружений на примере Qbec

- Папка с проектом qbec расположена [qbec](./qbec);
- Примеры выполнения для stage:
``` sh
# Выполнение скрипта
root@cpl:/data/qbec# qbec apply stage
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 27ms
4 components evaluated in 6ms

will synchronize 7 object(s)

Do you want to continue [y/n]: y
4 components evaluated in 13ms
create namespaces netology-stage (source 10-namespace)
create deployments kubernetes-05-back -n netology-stage (source 30-deploy-back)
create deployments kubernetes-05-front -n netology-stage (source 40-deploy-front)
create statefulsets kubernetes-05-db -n netology-stage (source 20-deploy-db)
W0405 15:04:26.491537  189793 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
create services kubernetes-05-db -n netology-stage (source 20-deploy-db)
create services kubernetes-05-back -n netology-stage (source 30-deploy-back)
create services kubernetes-05-front -n netology-stage (source 40-deploy-front)
server objects load took 1.603s
---
stats:
  created:
  - namespaces netology-stage (source 10-namespace)
  - deployments kubernetes-05-back -n netology-stage (source 30-deploy-back)
  - deployments kubernetes-05-front -n netology-stage (source 40-deploy-front)
  - statefulsets kubernetes-05-db -n netology-stage (source 20-deploy-db)
  - services kubernetes-05-db -n netology-stage (source 20-deploy-db)
  - services kubernetes-05-back -n netology-stage (source 30-deploy-back)
  - services kubernetes-05-front -n netology-stage (source 40-deploy-front)

waiting for readiness of 3 objects
  - deployments kubernetes-05-back -n netology-stage
  - deployments kubernetes-05-front -n netology-stage
  - statefulsets kubernetes-05-db -n netology-stage

✓ 0s    : statefulsets kubernetes-05-db -n netology-stage :: 1 new pods updated (2 remaining)
  0s    : deployments kubernetes-05-back -n netology-stage :: 0 of 1 updated replicas are available
  0s    : deployments kubernetes-05-front -n netology-stage :: 0 of 1 updated replicas are available
✓ 1s    : deployments kubernetes-05-back -n netology-stage :: successfully rolled out (1 remaining)
✓ 2s    : deployments kubernetes-05-front -n netology-stage :: successfully rolled out (0 remaining)

✓ 2s: rollout complete
command took 5.58s

# Смотрим что получилось
root@cpl:/data/qbec# kubectl -n netology-stage get all
NAME                                       READY   STATUS    RESTARTS   AGE
pod/kubernetes-05-back-5bc687b6f-cbx6p     1/1     Running   0          12s
pod/kubernetes-05-db-0                     1/1     Running   0          12s
pod/kubernetes-05-front-699c678bb8-578hr   1/1     Running   0          12s

NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kubernetes-05-back    ClusterIP   10.233.58.54    <none>        9000/TCP   10s
service/kubernetes-05-db      ClusterIP   10.233.61.85    <none>        5432/TCP   11s
service/kubernetes-05-front   ClusterIP   10.233.47.148   <none>        8000/TCP   10s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kubernetes-05-back    1/1     1            1           12s
deployment.apps/kubernetes-05-front   1/1     1            1           12s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/kubernetes-05-back-5bc687b6f     1         1         1       12s
replicaset.apps/kubernetes-05-front-699c678bb8   1         1         1       12s

NAME                                READY   AGE
statefulset.apps/kubernetes-05-db   1/1     12s
```
- Примеры выполнения для prod:
``` sh
# Выполнение скрипта
root@cpl:/data/qbec# qbec apply prod
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 23ms
5 components evaluated in 9ms

will synchronize 8 object(s)

Do you want to continue [y/n]: y
5 components evaluated in 10ms
create namespaces netology-prod (source 10-namespace)
create deployments kubernetes-05-back -n netology-prod (source 30-deploy-back)
create deployments kubernetes-05-front -n netology-prod (source 40-deploy-front)
create statefulsets kubernetes-05-db -n netology-prod (source 20-deploy-db)
W0405 15:06:01.716925  191069 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
create services kubernetes-05-db -n netology-prod (source 20-deploy-db)
create services kubernetes-05-back -n netology-prod (source 30-deploy-back)
create services kubernetes-05-front -n netology-prod (source 40-deploy-front)
create services external-api-v1 -n netology-prod (source 50-external-service-v1)
server objects load took 1.603s
---
stats:
  created:
  - namespaces netology-prod (source 10-namespace)
  - deployments kubernetes-05-back -n netology-prod (source 30-deploy-back)
  - deployments kubernetes-05-front -n netology-prod (source 40-deploy-front)
  - statefulsets kubernetes-05-db -n netology-prod (source 20-deploy-db)
  - services kubernetes-05-db -n netology-prod (source 20-deploy-db)
  - services kubernetes-05-back -n netology-prod (source 30-deploy-back)
  - services kubernetes-05-front -n netology-prod (source 40-deploy-front)
  - services external-api-v1 -n netology-prod (source 50-external-service-v1)

waiting for readiness of 3 objects
  - deployments kubernetes-05-back -n netology-prod
  - deployments kubernetes-05-front -n netology-prod
  - statefulsets kubernetes-05-db -n netology-prod

✓ 0s    : statefulsets kubernetes-05-db -n netology-prod :: 1 new pods updated (2 remaining)
  0s    : deployments kubernetes-05-front -n netology-prod :: 0 of 3 updated replicas are available
  0s    : deployments kubernetes-05-back -n netology-prod :: 0 of 2 updated replicas are available
  0s    : deployments kubernetes-05-back -n netology-prod :: 1 of 2 updated replicas are available
✓ 1s    : deployments kubernetes-05-back -n netology-prod :: successfully rolled out (1 remaining)
  3s    : deployments kubernetes-05-front -n netology-prod :: 1 of 3 updated replicas are available
  4s    : deployments kubernetes-05-front -n netology-prod :: 2 of 3 updated replicas are available
✓ 6s    : deployments kubernetes-05-front -n netology-prod :: successfully rolled out (0 remaining)

✓ 6s: rollout complete
command took 9.71s

# Смотрим что получилось
root@cpl:/data/qbec# kubectl -n netology-prod get all
NAME                                       READY   STATUS    RESTARTS   AGE
pod/kubernetes-05-back-86987987c5-6zqvr    1/1     Running   0          14s
pod/kubernetes-05-back-86987987c5-dhwh6    1/1     Running   0          14s
pod/kubernetes-05-db-0                     1/1     Running   0          14s
pod/kubernetes-05-front-78d8dd88cd-kzf95   1/1     Running   0          14s
pod/kubernetes-05-front-78d8dd88cd-l8b79   1/1     Running   0          14s
pod/kubernetes-05-front-78d8dd88cd-r2dck   1/1     Running   0          14s

NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP              PORT(S)          AGE
service/external-api-v1       ExternalName   <none>          geocode-maps.yandex.ru   80/TCP,443/TCP   11s
service/kubernetes-05-back    ClusterIP      10.233.8.145    <none>                   9000/TCP         12s
service/kubernetes-05-db      ClusterIP      10.233.61.114   <none>                   5432/TCP         13s
service/kubernetes-05-front   ClusterIP      10.233.7.10     <none>                   8000/TCP         12s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kubernetes-05-back    2/2     2            2           14s
deployment.apps/kubernetes-05-front   3/3     3            3           14s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/kubernetes-05-back-86987987c5    2         2         2       14s
replicaset.apps/kubernetes-05-front-78d8dd88cd   3         3         3       14s

NAME                                READY   AGE
statefulset.apps/kubernetes-05-db   1/1     14s
```

