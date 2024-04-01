# Deploying EdgeLake

Transform your edge nodes into members of a permissioned decentralized network, optimized to manage and monitor data and resources at the edge.

Deploy EdgeLake instances on your nodes at the edge.
* Enable services on each node.
* Stream data from your PLCs, Sensors, and applications to the edge nodes.
* Query the distributed data from a single point (as if the data is hosted in a centralized database).
* Manage your edge resources from a single point (the network of nodes reflects a Single System Image).

## Prepare Node
**Option 1**: [Install OpenHorizon Service](OpenHorizon_install.md) 
1. Install _make_ 
```shell
sudo apt-get -y install make
```

2. Follow directions in [OpenHorizon Installation](OpenHorizon_install.md) to install _docker_ and connect to OpenHorizon


3. Clone [service-edgelake](https://github.com/open-horizon-services/service-edgelake) 
```shell
git clone https://github.com/open-horizon-services/service-edgelake
cd service-edgelake
```

**Option 2**: Manually install requirements (without OpenHorizon)
1. Install _make_
 ```shell
sudo apt-get -y install make
```

2. Install docker and set permissions for non-sudo user
```shell
sudo snap install docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker 
```

3. Install _docker-compose_
```shell
sudo apt-get -y install docker-compose
```

4. Clone [service-edgelake](https://github.com/open-horizon-services/service-edgelake) 
```shell
git clone https://github.com/open-horizon-services/service-edgelake
cd service-edgelake
```

## Deploy via Open-Horizon Patterns 
1. Update _input_ section for _userInput_ section for deployment policy pattern - Edit `LEDGER_CONN` in _Query_ and _Operator_ using IP address of _Master node_
    * [deployment.policy.master.json](../hzn/deployment.policy.master.json)
    * [deployment.policy.operator.json](../hzn/deployment.policy.master.json)
    * [deployment.policy.query.json](../hzn/deployment.policy.query.json)
```json
{            
    "serviceOrgid": "$HZN_ORG_ID",
    "serviceUrl": "$SERVICE_NAME",
    "serviceVersionRange": "[0.0.0,INFINITY)",
    "inputs": [
        {"name":"NODE_TYPE","value":"master"},
        {"name":"NODE_NAME","value":"edgelake-master"},
        {"name":"COMPANY_NAME","value":"New Company"},
        {"name":"ANYLOG_SERVER_PORT","value":"32048"},
        {"name":"ANYLOG_REST_PORT","value":"32049"},
        {"name":"TCP_BIND","value":"false"},
        {"name":"REST_BIND","value":"false"},
        {"name":  "DB_TYPE", "value":  "sqlite"},
        {"name":  "DB_USER", "value":  ""},
        {"name":  "DB_PASSWD", "value":  ""},
        {"name":  "DB_IP", "value":  "127.0.0.1"},
        {"name":  "DB_PORT", "value":  "5432"},
        {"name":  "AUTOCOMMIT", "value":  "false"},
        {"name":"LEDGER_CONN","value":"127.0.0.1:32048"},
        {"name":"DEPLOY_LOCAL_SCRIPT","value":"false"}
    ]
}
```

2. Publish Service 
```shell
make publish-service EDGELAKE_TYPE=[node_type]
```

3. Publish Policy for Service
```shell
make publish-service-policy EDGELAKE_TYPE=[node_type]
```

4. Publish Deployment policy 
```shell
make publish-deployment-policy EDGELAKE_TYPE=[node_type]
```

5. Start EdgeLake service
```shell
make agent-run EDGELAKE_TYPE=[node_type]
```

Once Service and Service Policy are defined, then users just need to execute steps 4 and 5 for each unique node being deployed 

### Makefile Commands for OpenHorizon deployment 
* help 
```text
Usage: make [target] EDGELAKE_TYPE=[edgelake-type]
Targets:
  all                                 Get help for both OpenHorizon and docker deployments
  build                               Pull the docker image
  publish-service                     Publish service to OpenHorizon
  remove-service                      Remove service from OpenHorizon
  publish-service-policy              Publish service policy to OpenHorizon
  remove-service-policy               Remove service policy from OpenHorizon
  publish-deployment-policy           Publish deployment policy to OpenHorizon
  remove-deployment-policy            Remove deployment policy from OpenHorizon
  agent-run                           Start service via OpenHorizon
  agent-stop                          Stop service via OpenHorizon
  deploy-check                        Check status of machine against OpenHorizon
  help-open-horizon                   Show this help message
  supported EdgeLake types: generic, master, operator, and query
```

* Master Node 
```shell
# Publish Service 
make publish-service EDGELAKE_TYPE=master

# Publish Service Policy 
make service-policy EDGELAKE_TYPE=master

# Publish Deployment Policy 
make publish-deployment-policy EDGELAKE_TYPE=master

# Start container (deploy agent) 
make agent-run EDGELAKE_TYPE=master

# Unregister Node / takedown container 
make agent-stop EDGELAKE_TYPE=master
```

* Query Node 
```shell
# Publish Deployment Policy 
make publish-deployment-policy EDGELAKE_TYPE=query

# Start container (deploy agent) 
make agent-run EDGELAKE_TYPE=query

# Unregister Node / takedown container 
make agent-stop EDGELAKE_TYPE=query
```

* Operator Node 
```shell
# Publish Deployment Policy 
make publish-deployment-policy EDGELAKE_TYPE=query

# Start container (deploy agent) 
make agent-run EDGELAKE_TYPE=query

# Unregister Node / takedown container 
make agent-stop EDGELAKE_TYPE=query
```

* Validate Connectivity commands - configured with _default_ port values
```shell
# validate node is accessible via REST
make test-node EDGELAKE_TYPE=operator 

# validate node is able to communicate and has a valid blockchain file 
make test-node EDGELAKE_TYPE=operator 

# validate node is able to communicate with other nodes witin its network
make test-network EDGELAKE_TYPE=operator 
```

**Note**: Once a _Service_ and _Service-Policy_ have been published, there is no need to republish them 

## Deploy via make and docker-compose 
1. Update .env configurations for the node(s) being deployed - Edit `LEDGER_CONN` in _Query_ and _Operator_ using IP address of _Master node_
    * [docker_makefile/edgelake_master.env](../docker_makefile/edgelake_master.env)
    * [docker_makefile/edgelake_operator.env](../docker_makefile/edgelake_operator.env)
    * [docker_makefile/edgelake_query.env](../docker_makefile/edgelake_query.env)
```dotenv
#--- General ---
# Information regarding which AnyLog node configurations to enable. By default, even if everything is disabled, AnyLog starts TCP and REST connection protocols
NODE_TYPE=master
# Name of the AnyLog instance
NODE_NAME=edgelake-master
# Owner of the AnyLog instance
COMPANY_NAME=New Company

#--- Networking ---
# Port address used by AnyLog's TCP protocol to communicate with other nodes in the network
ANYLOG_SERVER_PORT=32048
# Port address used by AnyLog's REST protocol
ANYLOG_REST_PORT=32049
# A bool value that determines if to bind to a specific IP and Port (a false value binds to all IPs)
TCP_BIND=false
# A bool value that determines if to bind to a specific IP and Port (a false value binds to all IPs)
REST_BIND=false

#--- Database ---
# Physical database type (sqlite or psql)
DB_TYPE=sqlite
# Username for SQL database connection
DB_USER=""
# Password correlated to database user
DB_PASSWD=""
# Database IP address
DB_IP=127.0.0.1
# Database port number
DB_PORT=5432
# Whether to set autocommit data
AUTOCOMMIT=false

#--- Blockchain ---
# TCP connection information for Master Node
LEDGER_CONN=127.0.0.1:32048

#--- Advanced Settings ---
# Whether to automatically run a local (or personalized) script at the end of the process
DEPLOY_LOCAL_SCRIPT=false
```

2. Start Node using makefile
```shell
make up EDGELAKE_TYPE=[NODE_TYPE]
```

### Makefile Commands for docker deployment 

* help
```text
Usage: make [target] EDGELAKE_TYPE=[anylog-type]
Targets:
  all           Get help for both docker and OpenHorizon deployments
  build         Pull the docker image
  up            Start the containers
  attach        Attach to EdgeLake instance
  test          Using cURL validate node is running
  exec          Attach to shell interface for container
  down          Stop and remove the containers
  logs          View logs of the containers
  clean         Clean up volumes and network
  help-docker   Show this help message
  supported EdgeLake types: master, operator and query
Sample calls: make up EDGELAKE_TYPE=[node_type] | make attach EDGELAKE_TYPE=[node_type] | make clean EDGELAKE_TYPE=[node_type]
```

* Master Node 
```shell
# deploy container 
make up EDGELAKE_TYPE=master 

# attach to container (ctrl-d to detach) 
make up attach EDGELAKE_TYPE=master 

# bring down container 
make down EDGELAKE_TYPE=master

# Clean container from system
make clean EDGELAKE_TYPE=master
```
* Query Node 
```shell
# deploy container 
make up EDGELAKE_TYPE=query 

# attach to container (ctrl-d to detach)   
make up attach EDGELAKE_TYPE=query 

# bring down container
make down EDGELAKE_TYPE=query

# clean container from system
make clean EDGELAKE_TYPE=query
```

* Operator Node 
```shell
# deploy container 
make up EDGELAKE_TYPE=operator 

# attach to container (ctrl-d to detach)   
make up attach EDGELAKE_TYPE=operator 

# bring down container
make down EDGELAKE_TYPE=operator

# Clean container from system
make clean EDGELAKE_TYPE=operator
```

* Validate Connectivity commands - configured with _default_ port values
```shell
# validate node is accessible via REST
make test-node EDGELAKE_TYPE=operator 

# validate node is able to communicate and has a valid blockchain file 
make test-node EDGELAKE_TYPE=operator 

# validate node is able to communicate with other nodes witin its network
make test-network EDGELAKE_TYPE=operator 
```