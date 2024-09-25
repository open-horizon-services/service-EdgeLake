# EdgeLake Service for  OpenHorizon

EdgeLake is a decentralized network to manage IoT data. Nodes in the network are compute instances that execute the EdgeLake 
Software. Joining a network requires the following steps:
1. Install the EdgeLake Software on one or more computer instances.
2. Configure each installed node (compute instance) such that:
   1. The node joins an exiting network (or creates a new network).
   2. The node offers data management and monitoring services.  


**Table of Content**:
* [Install OpenHorizon](Install_OpenHorizon.md)
* [Deploy EdgeLake](#deploy-edgelake)
  * [Master + Query](#master--query)
  * [Operator](#operator)
  * [Validate Node](#validate-node)
  * [Other](#other)
* [EdgeLake KubeArmor Integration](Documentation/EdgeLake_KubeArmor_integration.md) - Accepting KubeArmor data into EdgeLake
* [Import Grafana Dashboards](Documentation/Import_Grafana_Dashboards.md) - Importing KubeArmor related gauges into Grafana 

# General Configuration of Network

A basic network setup consists of a _master node_, 2 or more _operator nodes_  and a _query_ node - as shown in the image below. 
These nodes can be deployed either on the same physical machine, or unique machines.

![Demo Diagram](imgs/deployment_diagram.png)


## Deploy EdgeLake

In the following directions, the _Master_ and _Query_ nodes will be deployed directly via Docker, while the _Operator_ 
node will be deployoed via OpenHorizon.  

### Master / Query

1. Update the dotenv configuration file for the desired node - [Master](docker-makefiles/edgelake_master.env) | [Query](docker-makefiles/edgelake_query.env)
Make sure the following params get update accordingly:
   * Node Name
   * Company Name
   * LEDGER_CONN associated with Master node

2. Deploy  Node
```shell
make up EDGELAKE_TYPE=master

make up EDGELAKE_TYPE=query
```
**Note**: EdgeLake version can be updated via DOCKER_IMAGE_VERSION in [Makefile](Makefile)

### Operator

1. Update the dotenv configuration file for the [Operator](docker-makefiles/edgelake_operator.env) node
Make sure the following params get update accordingly:
   * Node Name
   * Company Name
   * LEDGER_CONN
   * Cluster Name
   * Database name


2. Make sure there aren't any services running - note existing services will redeploy as part of `agent-run` in step
```shell
hzn unregister -f
```

3. Using `publish` command deploy EdgeLake
   * publish-service
   * publish-service-policy
   * publish-deployment-policy 
   * agent-run
```shell
make publish EDGELAKE_TYPE=operator
```

### Validate Node

* Test Node
```shell
make test-node EDGELAKE_TYPE=master 

<<COMMENT
Test Node Against: 127.0.0.1:32049
edgelake-master@172.235.53.13:32048 running
Test                                        Status                                                                      
-------------------------------------------|---------------------------------------------------------------------------|
Metadata Version                           |3988d68a8225634033a02eb1eced9b5b                                           |
Metadata Test                              |Pass                                                                       |
TCP test using 172.235.53.13:32048         |[From Node 172.235.53.13:32048] edgelake-master@172.235.53.13:32048 running|
REST test using http://172.235.53.13:32049 |edgelake-master@172.235.53.13:32048 running                                |

root@openhorizon-demo:~/service-edgelake# make test-node EDGELAKE_TYPE=query
Test Node Against: 127.0.0.1:32349
edgelake-query@172.235.53.13:32348 running
Test                                        Status                                                                     
-------------------------------------------|--------------------------------------------------------------------------|
Metadata Version                           |3988d68a8225634033a02eb1eced9b5b                                          |
Metadata Test                              |Pass                                                                      |
TCP test using 172.235.53.13:32348         |[From Node 172.235.53.13:32348] edgelake-query@172.235.53.13:32348 running|
REST test using http://172.235.53.13:32349 |edgelake-query@172.235.53.13:32348 running                                | 
<<COMMENT
```

* Test Network
```shell
make test-network EDGELAKE_TYPE=query

<<COMMENT
Test Network Against: 127.0.0.1:32349

Address             Node Type Node Name       Status 
-------------------|---------|---------------|------|
172.235.53.13:32048|master   |edgelake-master|  +   |
172.235.53.13:32348|query    |edgelake-query |  +   |
root@openhorizon-demo:~/service-edgelake# make test-network EDGELAKE_TYPE=master
Test Network Against: 127.0.0.1:32049

Address             Node Type Node Name       Status 
-------------------|---------|---------------|------|
172.235.53.13:32048|master   |edgelake-master|  +   |
172.235.53.13:32348|query    |edgelake-query |  +   |
<<COMMENT
```

### Other
* Help 
```shell
make help EDGELAKE_TYPE=operator

<<COMMENT
=====================
Docker Deployment Options
=====================
build            pull latest image for anylogco/edgelake:1.3.2408
up               bring up docker container based on EDGELAKE_TYPE
attach           attach to docker container based on EDGELAKE_TYPE
logs             view docker container logs based on EDGELAKE_TYPE
down             stop docker container based on EDGELAKE_TYPE
clean            (stop and) remove volumes and images for a docker container basd on EDGELAKE_TYPE
tset-node        using cURL make sure EdgeLake is accessible and is configured properly
test-network     using cURL make sure EdgeLake node is able to communicate with nodes in the network
make: hzn: Command not found
==============================
OpenHorizon Deployment Options
==============================
publish-service            publish service to OpenHorizon
remove-service             remove service from OpenHorizon
publish-service-policy     publish service policy to OpenHorizon
remove-service-policy      remove service policy from OpenHorizon
publish-deployment-policy  publish deployment policy to OpenHorizon
remove-deployment-policy   remove deployment policy from OpenHorizon
agent-run                  start OpenHorizon service
agent-stop                  stop OpenHorizon service
<<COMMENT
```
* Check
```shell
make check EDGELAKE_TYPE=operator

<<COMMENT
=====================
ENVIRONMENT VARIABLES
=====================
EDGELAKE_TYPE          default: generic                               actual: operator
DOCKER_IMAGE_BASE      default: anylogco/edgelake                     actual: anylogco/edgelake
DOCKER_IMAGE_NAME      default: edgelake                              actual: edgelake
DOCKER_IMAGE_VERSION   default: latest                                actual: 1.3.2408
DOCKER_HUB_ID          default: anylogco                              actual: anylogco
HZN_ORG_ID             default: myorg                                 actual: myorg
HZN_LISTEN_IP          default: 127.0.0.1                             actual: 127.0.0.1
SERVICE_NAME                                                          actual: service-edgelake-operator
SERVICE_VERSION                                                       actual: 1.3.2408
===================
EDGELAKE DEFINITION
===================
NODE_TYPE              default: generic                               actual: operator
NODE_NAME              default: edgelake-node                         actual: edgelake-operator
COMPANY_NAME           default: New Company                           actual: New Company
ANYLOG_SERVER_PORT     default: 32548                                 actual: 32148
ANYLOG_REST_PORT       default: 32549                                 actual: 32149
LEDGER_CONN            default: 127.0.0.1:32049                       actual: 66.228.62.212:32048
<<COMMENT
```

Review [Deploy EdgeLake](Documentation/Deploy_EdgeLake.md) for farther details and specific examples - 
[Docker-based](Documentation/Deploy_EdgeLake.md#makefile-commands-for-docker-deployment-) and 
[OpenHorizon-Based](Documentation/Deploy_EdgeLake.md#makefile-commands-for-openhorizon-deployment-)
 