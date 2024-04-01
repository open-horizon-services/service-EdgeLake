# Install OpenHorizon

Open Horizon is a platform for managing the service software lifecycle of containerized workloads and related machine 
learning assets. It enables autonomous management of applications deployed to distributed web scale fleets of edge 
computing nodes and devices without requiring on-premise administrators.

Open Horizon can be used to easily manage and deploy AnyLog node(s) through their interface.
* [Open Horizon Website](https://www.lfedge.org/projects/openhorizon/)
* [IBM Documentation for Open Horizon](https://developer.ibm.com/components/open-horizon/)
* [Open Source Documentation](https://open-horizon.github.io/)
* [Quick Start](https://open-horizon.github.io/quick-start/)

## Prerequisites
### Management Hub
[Install the Open Horizon Management Hub](https://open-horizon.github.io/quick-start) or have access to an existing hub in order to publish 
this service and register your edge node.  You may also choose to use a downstream commercial distribution based on Open 
Horizon, such as IBM's Edge Application Manager.  If you'd like to use the Open Horizon community hub, you may 
[apply for a temporary account](https://wiki.lfedge.org/display/LE/Open+Horizon+Management+Hub+Developer+Instance) and have credentials sent to you.

A physical / virtual machine for each node, as OpenHorizon is unable to deploy more than 1 instance per node

### Edge Node
You will need an x86 computer running _Linux_ or _macOS_, or a _RaspberryPi_ computer (arm64) running 
RaspberryPi OS or Ubuntu to install and use Grafana deployed by Open Horizon. You will need to install the Open Horizon 
agent software, anax, on the edge node and register it with a hub. [Machine requirements](https://www.ibm.com/docs/en/eam/4.0?topic=devices-preparing-edge-devicehttps://www.ibm.com/docs/en/eam/4.0?topic=devices-preparing-edge-device)

**For 64-bit Intel or AMD device or virtual machine**:
* 64-bit Intel or AMD device or virtual machine
* An internet connection for your device (wired or wifi)

**For Linux on ARM (32-bit)**:
* Hardware requirements - Raspberry Pi 3A+, 3B, 3B+, or 4 (preferred), but also supports  A+, B+, 2B, Zero-W, or Zero-WH
* MicroSD flash card (32 GB preferred)
* An Internet connection for your device (wired or WiFi). Note: Some devices can require extra hardware for supporting Wifi.

### Optional utilities to install  
With `brew` on macOS (you may need to install _that_ as well), `apt-get` on Ubuntu 
or Raspberry Pi OS, `yum` on Fedora, install `gcc`, `make`, `git`, `jq`, `curl`, `net-tools`.  Not all of those may exist 
on all platforms, and some may already be installed.  But reflexively installing those has proven helpful in having the 
right tools available when you need them.

### Support Links
* [Create an API key](https://www.ibm.com/docs/en/eam/4.3?topic=installation-creating-your-api-key) 
* [Install Horizon CLI](https://www.ibm.com/docs/en/eam/4.1?topic=cli-installing-hzn) 
* [Install Docker](https://docs.docker.com/engine/install/) 

## Prepare Machine
1. Update / Upgrade machine  
```shell
sudo apt-get -y update 
sudo apt-get -y upgrade
```

2. Create an Open Horizon [API Key](https://www.ibm.com/docs/en/eam/4.3?topic=installation-creating-your-api-key)

3. Export following params - I tend to store the params as part of `~/.bashrc` (_Alpine_: `~/.profile`), that way when the node
reboots the environment variables still exist
```shell
export HZN_ORG_ID=[ORG_ID]
export HZN_EXCHANGE_USER_AUTH=[USER_AUTH]
export HZN_EXCHANGE_URL=[EXCHANGE_URL]
export HZN_FSS_CSSURL=[FSS_CSSURL]
```

4. Download the installation agent & provide admin permissions
```shell
curl -u "${HZN_ORG_ID}/${HZN_EXCHANGE_USER_AUTH}" -k -o agent-install.sh ${HZN_FSS_CSSURL}/api/v1/objects/IBM/agent_files/agent-install.sh/data
chmod +x agent-install.sh
```

## Install _Hello World_

The _hello world_ pattern will install `hzn` and `docker` as well as validate everything works properly 

1. Test agent is installed by deploying _IBM/pattern-ibm.helloworld_

**Command**
```shell
sudo -s -E ./agent-install.sh -i 'css:' -p IBM/pattern-ibm.helloworld -w '*' -T 120
```
**Output**
```shell
...
Waiting for up to 120 seconds for following services to start:
        IBM/ibm.helloworld
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: no agreements formed yet
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: no agreements formed yet
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: agreement proposal has been received
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: agreement is finalized
Status of the services you are watching:
        IBM/ibm.helloworld      Progress so far: execution is started
Status of the services you are watching:
        IBM/ibm.helloworld      Success
```

2. Check node is running

**Command**
```shell
hzn eventlog list -f
```
**Output**
```shell
  "2024-03-06 00:37:03:   Start node configuration/registration for node test-node.",
  "2024-03-06 00:37:04:   Start service auto configuration for IBM/ibm.helloworld.",
  "2024-03-06 00:37:04:   Complete service auto configuration for IBM/ibm.helloworld.",
  "2024-03-06 00:37:04:   Complete node configuration/registration for node test-node.",
  "2024-03-06 00:37:04:   Start policy advertising with the Exchange for service IBM/ibm.helloworld.",
  "2024-03-06 00:37:05:   Complete policy advertising with the Exchange for service IBM/ibm.helloworld.",
  "2024-03-06 00:37:47:   Node received Proposal message using agreement c577e4956773624647aaca2e32e3f1fafa96107dedfe7f00e0463b3f44265705 for service IBM/ibm.helloworld from the agbot IBM/agbot.",
  "2024-03-06 00:37:47:   Node received Proposal message using agreement 7b258ca1a6824322d20ac0d5e15e54d7ccfe9dc86486ed1ef6cc562bf93aff3b for service IBM/ibm.helloworld from the agbot IBM/agbot.",
  "2024-03-06 00:37:47:   Agreement c577e4956773624647aaca2e32e3f1fafa96107dedfe7f00e0463b3f44265705 already exists, ignoring proposal: ibm.helloworld",
  "2024-03-06 00:37:57:   Agreement reached for service ibm.helloworld. The agreement id is c577e4956773624647aaca2e32e3f1fafa96107dedfe7f00e0463b3f44265705.",
  "2024-03-06 00:37:57:   Start dependent services for IBM/ibm.helloworld.",
  "2024-03-06 00:37:57:   Start workload service for IBM/ibm.helloworld.",
  "2024-03-06 00:37:58:   Image loaded for IBM/ibm.helloworld.",
  "2024-03-06 00:37:59:   Workload service containers for IBM/ibm.helloworld are up and running."
```


3. View general information about this Horizon edge node.

**Command**:
```shell
hzn node list
```

**Output**: 
```json
{
  "id": "$(hostname)",
  "organization": "${HZN_ORG_ID}",
  "pattern": "IBM/pattern-ibm.helloworld",
  "name": "test-node",
  "nodeType": "device",
  "token_last_valid_time": "2024-03-07 22:18:03 +0000 UTC",
  "token_valid": true,
  "ha_group": "",
  "configstate": {
    "state": "configured",
    "last_update_time": "2024-03-07 22:18:04 +0000 UTC"
  },
  "configuration": {
    "exchange_api": "${HZN_EXCHANGE_URL}",
    "exchange_version": "2.110.4",
    "required_minimum_exchange_version": "2.90.1",
    "preferred_exchange_version": "2.110.1",
    "mms_api": "${HZN_FSS_CSSURL}",
    "architecture": "amd64",
    "horizon_version": "2.30.0-1435"
  }
}
```


4. Unregister _IBM/pattern-ibm.helloworld_
```shell
hzn unregister -f
```

5. Validate _hzn_ is installed 

**Command**
```shell
hzn version
```

**Output**
```shell
Horizon CLI version: 2.30.0-1435
Horizon Agent version: 2.30.0-1435
```

6. Docker is already installed via `hzn`, however needs permissions to use not as root
```shell
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker

# optional - install docker-compose 
sudo apt-get -y install docker-compose
```

When using [OpenHorizon Edge Service](OpenHorizon_EdgeService.md), the number of edge nodes increase by one. 
![OpenHorizon_node_state.png](../imgs/OpenHorizon_node_state.png)



