# 13.2 разделы и монтирование
1. Подготовка nfs:
    ``` sh
    root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/endpoints# helm repo add stable https://charts.helm.sh/stable && helm repo update
    "stable" has been added to your repositories
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "stable" chart repository
    Update Complete. ⎈Happy Helming!⎈

    root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/endpoints# helm install nfs-server stable/nfs-server-provisioner
    WARNING: This chart is deprecated
    NAME: nfs-server
    LAST DEPLOYED: Mon Apr  4 10:09:34 2022
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    The NFS Provisioner service has now been installed.

    A storage class named 'nfs' has now been created
    and is available to provision dynamic volumes.

    You can use this storageclass by creating a `PersistentVolumeClaim` with the
    correct storageClassName attribute. For example:

        ---
        kind: PersistentVolumeClaim
        apiVersion: v1
        metadata:
        name: test-dynamic-volume-claim
        spec:
        storageClassName: "nfs"
        accessModes:
            - ReadWriteOnce
        resources:
            requests:
            storage: 100Mi

    root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-01-objects/endpoints# kubectl get sc
    NAME   PROVISIONER                                       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
    nfs    cluster.local/nfs-server-nfs-server-provisioner   Delete          Immediate           true                   14s

    ```
2. Общая папка для тестового конфига:
  - У нас в тесте два контейнера в одном поде. Общая папка подключается через `emptyDir`;
  - Пример конфгурации:
    ``` yaml
    ....
            volumeMounts:
            - mountPath: "/storage"
                name: stage-storage
        volumes:
            - name: stage-storage
            emptyDir: {}
    ```
  - Изменения внесены в файл [stage/30-deploy-app.yaml](stage/30-deploy-app.yaml);
3. Общая папка для прода:
  - Т.к. в условиях задачи нужно создать почтоянный том с использованием `nfs-server-provisioner` сам том создавать не нужно
  - Создается только PVC, остальное провиженер сделает сам;
  - Определение PVC для продуктивного тома:
    ``` yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
    name: prod-storage
    spec:
    accessModes:
    - ReadWriteMany
    resources:
        requests:
        storage: 1Gi
    storageClassName: nfs
    ```
  - Изменения в манифестах `frontend` и `backend`:
    ``` yaml
    ...
            volumeMounts:
            - mountPath: "/storage"
                name: prod-storage
        volumes:
        - name: prod-storage
            persistentVolumeClaim:
            claimName: prod-storage
    ```
  - Конейнеры все равно не запускались с ошибкой:
    ```
    Events:
    Type     Reason       Age                 From               Message
    ----     ------       ----                ----               -------
    Normal   Scheduled    35m                 default-scheduler  Successfully assigned default/kubernetes-01-prod-back-78d848c6b8-d9xsq to node1
    Warning  FailedMount  33m                 kubelet            Unable to attach or mount volumes: unmounted volumes=[prod-storage], unattached volumes=[prod-storage kube-api-access-ckpfl]: timed out waiting for the condition
    Warning  FailedMount  30m (x10 over 35m)  kubelet            MountVolume.SetUp failed for volume "pvc-4891b0e2-912e-44e2-88d3-e063e74e31fb" : mount failed: exit status 32
    Mounting command: mount
    Mounting arguments: -t nfs -o vers=3 10.233.32.155:/export/pvc-4891b0e2-912e-44e2-88d3-e063e74e31fb /var/lib/kubelet/pods/e2dca006-5577-437c-9388-942cff08c7b5/volumes/kubernetes.io~nfs/pvc-4891b0e2-912e-44e2-88d3-e063e74e31fb
    Output: mount: /var/lib/kubelet/pods/e2dca006-5577-437c-9388-942cff08c7b5/volumes/kubernetes.io~nfs/pvc-4891b0e2-912e-44e2-88d3-e063e74e31fb: bad option; for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program.
    Warning  FailedMount  30m  kubelet  Unable to attach or mount volumes: unmounted volumes=[prod-storage], unattached volumes=[kube-api-access-ckpfl prod-storage]: timed out waiting for the condition
    Normal   Pulling      28m  kubelet  Pulling image "praqma/network-multitool"
    Normal   Pulled       28m  kubelet  Successfully pulled image "praqma/network-multitool" in 1.335934257s
    Normal   Created      28m  kubelet  Created container backend
    Normal   Started      28m  kubelet  Started container backend
    ```
  - Сама папка монтируется по NFS демоном `kubelet` с рабочей ноды. На рабочей ноде не были устанлвены клиентские компоненты NFS. После установки `apt install nfs-client` поды нормально стартовали.
  - Примеры выполнения:
``` sh
# Создаем текстовый файл в поде бэкенда
root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-02-mounts/prod# kubectl exec -it kubernetes-01-prod-back-78d848c6b8-d9xsq -- sh -c "echo 'Example netology string' > /storage/test.txt"

# Проверяем текстовый файл в поде бэкенда
root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-02-mounts/prod# kubectl exec -it kubernetes-01-prod-back-78d848c6b8-d9xsq -- cat /storage/test.txt
Example netology string

# Проверяем текстовый файл в поде фронтенда
root@kube-cpl:/data/netology_devkub-7/13-kubernetes-config-02-mounts/prod# kubectl exec -it kubernetes-01-prod-front-bcbcbc458-mxjl4 -- cat /storage/test.txt
Example netology string
```