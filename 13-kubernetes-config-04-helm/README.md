# 13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet
1. Helm чарт для приложения:
  - Расположен в папке [charts](./charts);
  - Состоит из StatefullSet db и двух Deployments backend и frontend;
  - Namespace по умолчанию netology;
  - При определенни переменной prod изменяется количество реплик определенных по умолчанию, а также деплоится Endpoints на внешний сервис;
2. Запустить 2 версии в разных неймспейсах
  - Деплои приложения в `namespace=app1`, повторный деплой в тот же namespace, в namespace=app2 и проверка prod:
    ``` sh
    # Первый деплой в namespace=app1
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# helm install netology charts/netology/ --set namespace=app1
    NAME: netology
    LAST DEPLOYED: Tue Apr  5 11:59:10 2022
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    ---------------------------------------------------------

    Content of NOTES.txt appears after deploy.
    Deployed to app1 namespace.

    ---------------------------------------------------------

    # Второй деплой в namespace=app1 под тем-же именем
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# helm install netology charts/netology/ --set namespace=app1
    Error: INSTALLATION FAILED: cannot re-use a name that is still in use

    # Второй деплой в namespace=app1 под другим именем
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# helm install netology-2 charts/netology/ --set namespace=app1
    Error: INSTALLATION FAILED: rendered manifests contain a resource that already exists. Unable to continue with install: Namespace "app1" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "netology-2": current value is "netology"

    # Деплой в namespace=app2 под именем netology
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# helm install netology charts/netology/ --set namespace=app2
    Error: INSTALLATION FAILED: cannot re-use a name that is still in use

    # Деплой в namespace=app2 под новым именем
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# helm install netology-3 charts/netology/ --set namespace=app2
    NAME: netology-3
    LAST DEPLOYED: Tue Apr  5 12:00:12 2022
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    ---------------------------------------------------------

    Content of NOTES.txt appears after deploy.
    Deployed to app2 namespace.

    ---------------------------------------------------------

    #Вывод `helm list`
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# helm list
    NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
    netology        default         1               2022-04-05 11:59:10.026988215 +0000 UTC deployed        kubernetes-04-0.1.0             latest
    netology-3      default         1               2022-04-05 12:00:12.638958414 +0000 UTC deployed        kubernetes-04-0.1.0             latest
    nfs-server      default         1               2022-04-04 10:09:34.527624601 +0000 UTC deployed        nfs-server-provisioner-1.1.3    2.3.0

    #Вывод `kubectl -n app1 get sts,po,svc`
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# kubectl -n app1 get sts,po,svc
    NAME                                READY   AGE
    statefulset.apps/kubernetes-04-db   1/1     5m12s

    NAME                                       READY   STATUS    RESTARTS   AGE
    pod/kubernetes-04-back-7c6c6849d7-dmvd9    1/1     Running   0          5m12s
    pod/kubernetes-04-db-0                     1/1     Running   0          5m12s
    pod/kubernetes-04-front-7ccb4765c8-bjb8z   1/1     Running   0          5m12s

    NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    service/kubernetes-04-back    ClusterIP   10.233.32.81    <none>        9000/TCP   5m12s
    service/kubernetes-04-db      ClusterIP   10.233.63.109   <none>        5432/TCP   5m12s
    service/kubernetes-04-front   ClusterIP   10.233.20.48    <none>        8000/TCP   5m12s

    #Вывод `kubectl -n app2 get sts,po,svc`
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# kubectl -n app2 get sts,po,svc
    NAME                                READY   AGE
    statefulset.apps/kubernetes-04-db   1/1     4m35s

    NAME                                       READY   STATUS    RESTARTS   AGE
    pod/kubernetes-04-back-7c6c6849d7-zz7h5    1/1     Running   0          4m35s
    pod/kubernetes-04-db-0                     1/1     Running   0          4m35s
    pod/kubernetes-04-front-7ccb4765c8-sm8jf   1/1     Running   0          4m35s

    NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    service/kubernetes-04-back    ClusterIP   10.233.53.28    <none>        9000/TCP   4m35s
    service/kubernetes-04-db      ClusterIP   10.233.18.44    <none>        5432/TCP   4m35s

    #Тест деплоя в prod
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# helm install netology-4 charts/netology/ --set namespace=app3,prod=true
    NAME: netology-4
    LAST DEPLOYED: Tue Apr  5 12:05:32 2022
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    ---------------------------------------------------------

    Content of NOTES.txt appears after deploy.
    Deployed to app3 namespace.

    ---------------------------------------------------------

    #Проверка prod
    root@cpl:/data/netology_devkub-7/13-kubernetes-config-04-helm# kubectl -n app3 get sts,po,svc
    NAME                                READY   AGE
    statefulset.apps/kubernetes-04-db   1/1     34s

    NAME                                       READY   STATUS    RESTARTS   AGE
    pod/kubernetes-04-back-7c6c6849d7-2kwsz    1/1     Running   0          34s
    pod/kubernetes-04-back-7c6c6849d7-4c9g8    1/1     Running   0          34s
    pod/kubernetes-04-back-7c6c6849d7-8tngk    1/1     Running   0          34s
    pod/kubernetes-04-db-0                     1/1     Running   0          34s
    pod/kubernetes-04-front-7ccb4765c8-m5d6b   1/1     Running   0          34s
    pod/kubernetes-04-front-7ccb4765c8-n5qhw   1/1     Running   0          34s

    NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP              PORT(S)          AGE
    service/external-api-v1       ExternalName   <none>          geocode-maps.yandex.ru   80/TCP,443/TCP   34s
    service/kubernetes-04-back    ClusterIP      10.233.22.18    <none>                   9000/TCP         34s
    service/kubernetes-04-db      ClusterIP      10.233.10.85    <none>                   5432/TCP         34s
    service/kubernetes-04-front   ClusterIP      10.233.43.115   <none>                   8000/TCP         34s

    ```
- Получается что в helm в прицнипе нельзя деплоить приложения под одним именем, а также один namespace может быть использоваться только одним деплоем;

3. Упаковка на jsonnet
  - Получившееся нечто расположено в папке [jsonnet](./jsonnet);
  - Основные параметры задаются в файле [jsonnet/00-default-vars.libsonnet](./jsonnet/00-default-vars.libsonnet)
  - Является аналогом чартов из пункта 2;
  - Имеет отдельные настройки для `stage` и `prod` окружений, для прода количество создаваемых подов вычислается при помощи множителей `replicasProdBackMult` и `replicasProdFrontMult`;
  - Пример развертывания на stage окружении `jsonnet -y main.jsonnet --ext-str env=stage | kubectl apply -f -`
    ``` sh
    # Выполняем сборку jsonnet и деплой в Kubernetes
    root@cpl:/data/jsonnet# jsonnet -y main.jsonnet --ext-str env=stage | kubectl apply -f -
    namespace/netology created
    statefulset.apps/kubernetes-04-db created
    service/kubernetes-04-db created
    deployment.apps/kubernetes-04-back created
    service/kubernetes-04-back created
    deployment.apps/kubernetes-04-front created
    service/kubernetes-04-front created

    # Проверка получившегося
    root@cpl:/data/jsonnet# kubectl -n netology get all
    NAME                                       READY   STATUS    RESTARTS   AGE
    pod/kubernetes-04-back-68db8cc6d8-rx5hb    1/1     Running   0          18s
    pod/kubernetes-04-db-0                     1/1     Running   0          18s
    pod/kubernetes-04-front-7db5dc44b9-fjg7h   1/1     Running   0          18s

    NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    service/kubernetes-04-back    ClusterIP   10.233.54.143   <none>        9000/TCP   18s
    service/kubernetes-04-db      ClusterIP   10.233.58.31    <none>        5432/TCP   18s
    service/kubernetes-04-front   ClusterIP   10.233.5.95     <none>        8000/TCP   18s

    NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/kubernetes-04-back    1/1     1            1           18s
    deployment.apps/kubernetes-04-front   1/1     1            1           18s

    NAME                                             DESIRED   CURRENT   READY   AGE
    replicaset.apps/kubernetes-04-back-68db8cc6d8    1         1         1       18s
    replicaset.apps/kubernetes-04-front-7db5dc44b9   1         1         1       18s

    NAME                                READY   AGE
    statefulset.apps/kubernetes-04-db   1/1     18s

    ```
  - Пример развертывания на prod окружении `jsonnet -y main.jsonnet --ext-str env=prod | kubectl apply -f -`
    ``` sh
    # Запуск для prod
    root@cpl:/data/jsonnet# jsonnet -y main.jsonnet --ext-str env=prod | kubectl apply -f -
    namespace/netology created
    statefulset.apps/kubernetes-04-db created
    service/kubernetes-04-db created
    deployment.apps/kubernetes-04-back created
    service/kubernetes-04-back created
    deployment.apps/kubernetes-04-front created
    service/kubernetes-04-front created
    service/external-api-v1 created

    # Проверка
    root@cpl:/data/jsonnet# kubectl -n netology get all
    NAME                                       READY   STATUS              RESTARTS   AGE
    pod/kubernetes-04-back-68db8cc6d8-92bf7    0/1     ContainerCreating   0          3s
    pod/kubernetes-04-back-68db8cc6d8-wwj88    0/1     ContainerCreating   0          3s
    pod/kubernetes-04-db-0                     0/1     ContainerCreating   0          4s
    pod/kubernetes-04-front-7db5dc44b9-5xm7x   0/1     ContainerCreating   0          3s
    pod/kubernetes-04-front-7db5dc44b9-l4srn   0/1     ContainerCreating   0          3s
    pod/kubernetes-04-front-7db5dc44b9-xh6m2   0/1     ContainerCreating   0          3s

    NAME                          TYPE           CLUSTER-IP     EXTERNAL-IP              PORT(S)          AGE
    service/external-api-v1       ExternalName   <none>         geocode-maps.yandex.ru   80/TCP,443/TCP   3s
    service/kubernetes-04-back    ClusterIP      10.233.17.35   <none>                   9000/TCP         3s
    service/kubernetes-04-db      ClusterIP      10.233.7.32    <none>                   5432/TCP         4s
    service/kubernetes-04-front   ClusterIP      10.233.42.40   <none>                   8000/TCP         3s

    NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/kubernetes-04-back    0/2     2            0           4s
    deployment.apps/kubernetes-04-front   0/3     3            0           3s

    NAME                                             DESIRED   CURRENT   READY   AGE
    replicaset.apps/kubernetes-04-back-68db8cc6d8    2         2         0       3s
    replicaset.apps/kubernetes-04-front-7db5dc44b9   3         3         0       3s

    NAME                                READY   AGE
    statefulset.apps/kubernetes-04-db   0/1     4s
    ```
  - Очень сложная в поддержке и написании штука, использовать точно не буду в работе. Лучше Helm, входящие параметры всегда можно переопределить и подсунуть при деплое не трогая чарты. 