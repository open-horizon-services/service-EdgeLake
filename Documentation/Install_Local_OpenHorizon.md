# Install Open Horizon

The following installs Open Horizon locally 

### Requirements
* **Operating System**: Ubuntu 18.04 LTS (or higheer) 
* **RAM**: 4GB 
* **CPU**: 4 Core
* **Storage**: 50GB

## Install Open Horizon 
1. Update & execute `~/.bashrc`
```shell
export MONGO_IMAGE_TAG=4.0.6 >> ~/.bashrc 
export HZN_LISTEN_IP=[MAACHINE_IP] >> ~/.bashrc
source ~/.bashrc
```

2. Start OpenHorizon via cURL - details can be found in [index](Install_Local_OpenHorizon_index.md)
```shell
for cmd in update upgrade ; do 
  sudo apt-get -y ${cmd}
done 
 
curl -sSL https://raw.githubusercontent.com/open-horizon/devops/master/mgmt-hub/deploy-mgmt-hub.sh -A -R | bash
```

3. Update & execute `~/.bashrc`
```shell
export HZN_ORG_ID=myorg >> ~/.bashrc
export HZN_EXCHANGE_USER_AUTH=admin:[USER_AUTH_PASS] >> ~/.bashrc
source ~/.bashrc
```

4. Before starting a (new) service via OpenHorizon, make sure to unregister the existing service(s)
```shell
hzn unregister -f
```

## Validate  

* Validate OpenHorizon is using the correct credentials
```shell
hzn ex user list -o ${HZN_ORG_ID} -u ${HZN_EXCHANGE_USER_AUTH}
<<COMMENT
{
  "myorg/admin": {
    "password": "********",
    "email": "not@used",
    "admin": true,
    "hubAdmin": false,
    "lastUpdated": "2024-07-31T19:14:31.367005421Z[UTC]",
    "updatedBy": "root/root"
  }
}
<<
```

* Check node is running
```shell
hzn eventlog list -f

<<COMMENT
  ...
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
  ...
<<COMMENT
```

* View general information about this Horizon edge node.

**Command**:
```shell
hzn node list

<<COMMENT
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
<<COMMENT
```

