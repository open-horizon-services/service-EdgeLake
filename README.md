# EdgeLake Service for  OpenHorizon

EdgeLake is a decentralized network to manage IoT data. Nodes in the network are compute instances that execute the EdgeLake 
Software. Joining a network requires the following steps:
1. Install the EdgeLake Software on one or more computer instances.
2. Configure each installed node (compute instance) such that:
   1. The node joins an exiting network (or creates a new network).
   2. The node offers data management and monitoring services.  


**Table of Content**:
* [Install OpenHorizon](Documentation/OpenHorizon_install.md) - Steps to install OpenHorizon
* [Deploying EdgeLake](Documentation/Deploy_EdgeLake.md) - Using the `make` command, install EdgeLake via _Open Horizon policy_ or _docker-compose_
* [EdgeLake KubeArmor Integration](Documentation/EdgeLake_KubeArmor_integration.md) - Accepting KubeArmor data into EdgeLake
* [Import Grafana Dashboards](Documentation/Import_Grafana_Dashboards.md) - Importing KubeArmor related gauges into Grafana 

# General Configuration of Network

A basic network setup consists of a _master node_, 2 or more _operator nodes_  and a _query_ node - as shown in the image below. 
These nodes can be deployed either on the same physical machine, or unique machines.

![Demo Diagram](imgs/deployment_diagram.png)


## Usage

The [make](Makefile) command allows deploying an EdgeLake node based on a user-define 
[node type (_Master_, _Operator_ or _Query_)](https://github.com/EdgeLake/EdgeLake/blob/main/README.md#edgelake).

### All Makefile targets

* `default` - shows help for both OpenHorizon and docker-compose deployment
* `build` - Pull the docker image 
* `help-docker` - Show this help message
* `help-open-horizon` - Show this help message

* `up` - Start the containers 
* `attach` - Attach to EdgeLake instance 
* `test` - Using cURL validate node is running 
* `exec` - Attach to shell interface for container 
* `down` - Stop and remove the containers 
* `logs` - View logs of the containers 
* `clean` - Clean up volumes and network

* `publish-service` - Publish service to OpenHorizon 
* `remove-service` - Remove service from OpenHorizon 
* `publish-service-policy` - Publish service policy to OpenHorizon 
* `remove-service-policy` - Remove service policy from OpenHorizon 
* `publish-deployment-policy` - Publish deployment policy to OpenHorizon 
* `remove-deployment-policy` - Remove deployment policy from OpenHorizon 
* `agent-run` - Start service via OpenHorizon 
* `agent-stop` - Stop service via OpenHorizon 
* `deploy-check` - Check status of machine against OpenHorizon 

### Examples 

**Docker-based Deployment**:
```shell
# deploy container 
make up EDGELAKE_TYPE=[NODE_TYPE]

# attach to container (ctrl-d to detach) 
make attach EDGELAKE_TYPE=[NODE_TYPE]

# bring down container
make down EDGELAKE_TYPE=[NODE_TYPE]

# clean container from system
make clean EDGELAKE_TYPE=[NODE_TYPE]
```

**OpenHorizon-based Deployment**
```shell
# Publish Service 
make publish-service EDGELAKE_TYPE=[node_type]

# Publish Service Policy 
make publish-service-policy EDGELAKE_TYPE=[node_type]

# Publish Deployment Policy 
make publish-deployment-policy EDGELAKE_TYPE=[node_type]

# Start container (deploy agent) 
make agent-run EDGELAKE_TYPE=[node_type]

# Unregister Node / takedown container 
make agent-stop EDGELAKE_TYPE=[node_type]
```

Review [Deploy EdgeLake](Documentation/Deploy_EdgeLake.md) for farther details and specific examples - 
[Docker-based](Documentation/Deploy_EdgeLake.md#makefile-commands-for-docker-deployment-) and 
[OpenHorizon-Based](Documentation/Deploy_EdgeLake.md#makefile-commands-for-openhorizon-deployment-)
 