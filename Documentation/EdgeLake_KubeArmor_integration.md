# EdgeLake / KubeArmor Integration

EdgeLake comes pre-configured with the _GRPC_ protocol files for [KubeArmor](https://kubearmor.io/)

## Requirements
* [Kubernetes Installation](https://kubernetes.io/docs/setup/) for KubeArmor 
* [Docker / OpenHorizon](OpenHorizon_install.md) for EdgeLake
* Locally installed _[gRPC](https://pypi.org/project/grpcio/)_ and _[gRPC-tools](https://pypi.org/project/grpcio-tools/)_
```shell
sudo python3 -m pip install grpcio
sudo python3 -m pip install grpcio-tools
```

## Prepare EdgeLake and KubeArmor

1. Setup EdgeLake and KubeArmor on your machine
   * [Deploy AnyLog](Deploy_EdgeLake.md) 
   * [Deploy Kubearmor](https://docs.kubearmor.io/kubearmor/quick-links/deployment_guide) with proxy

2. For _KubeArmor_, deploy a proxy service
   * For demo purposes, KubeArmor deployed their _NginX_ test application - Steps can be found [here](https://docs.kubearmor.io/kubearmor/quick-links/deployment_guide)
```shell
# proxy command 
kubectl port-forward --address ${INTERNAL_IP} service/kubearmor 32769:32767 -n kubearmor
```
 

3. Locate the EdgeLake volume for local-scripts
```shell
moshe@anylog-gcp-publisher:~$ docker volume ls 
DRIVER    VOLUME NAME
local     edgelake-operator_edgelake-operator-anylog
local     edgelake-operator_edgelake-operator-blockchain
local     edgelake-operator_edgelake-operator-data
local     edgelake-operator_edgelake-operator-local-scripts
local     minikube
moshe@anylog-gcp-publisher:~$ docker inspect edgelake-operator_edgelake-operator-local-scripts
[
    {
        "CreatedAt": "2024-01-19T23:11:12Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "edgelake-publisher",
            "com.docker.compose.version": "2.17.2",
            "com.docker.compose.volume": "edgelake-publisher-local-scripts"
        },
        "Mountpoint": "/var/snap/docker/common/var-lib-docker/volumes/edgelake-operator_edgelake-operator-local-scripts/_data",
        "Name": "edgelake-operator_edgelake-operator-local-scripts",
        "Options": null,
        "Scope": "local"
    }
]
```

4. Locate _gRPC_ file(s) 
```shell
moshe@anylog-gcp-publisher:~$ sudo ls -l /var/snap/docker/common/var-lib-docker/volumes/edgelake-operator_edgelake-operator-local-scripts/_data/grpc/
total 20
-rw-r--r-- 1 root root 1576 Jan 19 04:58 README.md
-rw-r--r-- 1 root root  920 Jan 19 04:58 compile.py
-rw-r--r-- 1 root root 5289 Jan 19 04:58 dummy_kube_server.py
drwxr-xr-x 2 root root 4096 Jan 21 01:34 kubearmor
moshe@anylog-gcp-publisher:~$ sudo ls -l /var/snap/docker/common/var-lib-docker/volumes/edgelake-operator_edgelake-operator-local-scripts/_data/grpc/kubearmor
total 48
-rw-r--r-- 1 root root     0 Jan 19 04:58 __init__.py
-rw-r--r-- 1 root root  1083 Jan 19 04:58 deploy_kubearmor_healthcheck.al
-rw-r--r-- 1 root root  1354 Jan 21 01:34 deploy_kubearmor_system.al
-rw-r--r-- 1 root root  1519 Jan 19 04:58 grpc_client.al
-rw-r--r-- 1 root root  2566 Jan 19 04:58 kubearmor.proto
-rw-r--r-- 1 root root  6356 Jan 19 04:58 kubearmor_system_policy.al
```

5. Compile protocol file 
```shell
sudo python3 /var/snap/docker/common/var-lib-docker/volumes/anylog-publisher_edgelake-publisher-local-scripts/_data/grpc/compile.py /var/snap/docker/common/var-lib-docker/volumes/anylog-publisher_edgelake-publisher-local-scripts/_data/grpc/kubearmor/kubearmor.proto
```

6. Update `deploy_kubearmor_system.al` file 
```anylog
#-----------------------------------------------------------------------------------------------------------------------
# Deploy process to accept data from KubeArmor
# Steps:
#   1. Compile proto file
#   2. Set params
#   3. Declare Policy
#   4. gRPC client
#-----------------------------------------------------------------------------------------------------------------------
# process $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/deploy_kubearmor_system.al
# Compile proto file
#:compile-proto:
# on error goto compile-error
# compile proto where protocol_file=$EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/kubearmor/kubearmor.proto

# Set Params
:set-params:

grpc_client_ip = kubearmor.kubearmor.svc.cluster.local
grpc_client_port = 32767
grpc_dir = $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/
grpc_proto = kubearmor
grpc_value = (Filter = all)
grpc_limit = 0
set grpc_ingest = true
set grpc_debug = false

grpc_service = LogService
grpc_request = RequestMessage

set alert_flag_1 = false
set alert_level = 0
ingestion_alerts = ''
table_name = bring [Operation]

set default_dbms = kubearmor # <-- update to your default database name 
set company_name = kubearmor # <-- update to your company name 

:run-grpc-client:
grpc_name = kubearmor-message
grpc_function = WatchMessages
grpc_response = Message

process $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/kubearmor_message.al
process $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al

grpc_name = kubearmor-alert
grpc_function = WatchAlerts
grpc_response = Alert

process $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/kubearmor_alert.al
process $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al

grpc_name = kubearmor-logs
grpc_function = WatchLogs
grpc_response = Logs
process $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/kubearmor_log.al
process $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al
```

## Deploy KubeArmor Connector in EdgeLake
1. Attach to EdgeLake operator node 
```shell
# ctrl-d to detach 
cd servvice-edgelake 
make attach operator 
```

2. Execute `deploy_kubearmor_system.al` process
```anylog
process $EDGELAKE_PATH/deployment-scripts/grpc/kubearmor/deploy_kubearmor_system.al
```

3. Validate _gRPC_ is Runnig
```anylog
get grpc client
```


**Expected Output**:

```anylog
EL edgelake-operator +> get grpc client 

Name (ID)         Status Connection                                  Proto Name Request Msg    Policy Type Policy Name       Policy ID         Data Msgs Timeouts Error 
-----------------|------|-------------------------------------------|----------|--------------|-----------|-----------------|-----------------|---------|--------|-----|
kubearmor-alert  |Active|kubearmor.kubearmor.svc.cluster.local:32767|kubearmor |RequestMessage|mapping    |kubearmor-alert  |kubearmor-alert  |     2846|    4883|     |
kubearmor-message|Active|kubearmor.kubearmor.svc.cluster.local:32767|kubearmor |RequestMessage|mapping    |kubearmor-message|kubearmor-message|        0|    4891|     |
kubearmor-logs   |Active|kubearmor.kubearmor.svc.cluster.local:32767|kubearmor |RequestMessage|mapping    |kubearmor-logs   |kubearmor-logs   |    87496|    4885|     |

```

4. Detach from Operator node - `ctrl-d`

### Query Data
1. Attach to EdgeLake operator node 
```shell
# ctrl-d to detach 
cd servvice-edgelake 
make attach operator 
```

2. Get row count for each table - make sure to  
```anylog
run client () sql kubearmor format=table "select count(*) from logs;" 

run client () sql kubearmor format=table "select count(*) from alert;"
```

3. Detach from Query node - `ctrl-d`

Steps to create Grafana dashboards can be found [here](Import_Grafana_Dashboards.md)

