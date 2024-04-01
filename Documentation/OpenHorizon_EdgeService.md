# OpenHorizon Edge Service

[OpenHorizon Edge Service](https://cp-console.ieam42-edge-8e873dd4c685acf6fd2f13f4cdfb05bb-0000.us-south.containers.appdomain.cloud/oidc/login.jsp) is an online GUI-based deployment process for containerized workload or application that 
runs at the edge of a network.  

* [Install OpenHorizon](OpenHorizon_install.md)
* [Deploy via Pattern](OpenHorizon_policy.md)

## Deploy AnyLog
By deploying AnyLog, users can monitor Distributed Edge Nodes and Data from a single point, without centralizing the data.

To include AnyLog in your edge deployments, follow a 3 steps process:
1.	Request a license key from AnyLog using the following link (once) https://anylog.co/download-anylog/.
2.	Update the service definition for each monitored node.
3. Publish the AnyLog-Node Service for each monitored node.

This process is detailed below. 

### Associate AnyLog Deployment with OpenHorizon

1. Log into [IBM Edge Application Manager](https://cp-console.ieam42-edge-8e873dd4c685acf6fd2f13f4cdfb05bb-0000.us-south.containers.appdomain.cloud/edge#/#0?content=snapshot)

2. Under _Services_ add an "Edge Device"

3. Declare _AnyLog_ as a device image - Docker login credentials are received using: [AnyLog Downloads](https://anylog.co/download-anylog)

![OpenHorizon_device_info.png](imgs%2FOpenHorizon_device_info.png)

4. Configure Service variables 
* `INIT_TYPE` (**value**: training) - Which AnyLog scripts to use for the deployment 
* `LICENSE_KEY` - AnyLog license key 
* `NODE_TYPE` (**value**: operator) - which AnyLog node type to deploy (for training purposes we support: _operator_, _query_ and _master_)
* `NODE_NAME` - AnyLog node name
* `COMPANY_NAME` - company the node is associated with 
* `ANYLOG_SERVER_PORT` (**value**: 32148) - Port used for communicating between AnyLog nodes 
* `ANYLOG_SERVER_PORT` (**value**: 32149) - Port used for communicating used for communicating with an AnyLog node via REST
* `LEDGER_CONN` (**value**: 132.177.125.232:32048) - A remote AnyLog instance used as the "manager" for AnyLog 
* `ENABLE_MQTT` (**value**: true) - Enable receiving data from a remote MQTT broker 
* `ENABLE_MONITORING` (**value**: true) - Enable monitoring of the Node 

![OpenHorizon_serivce_info.png](imgs%2FOpenHorizon_serivce_info.png)

5. Under "Deployment Options", Enable _Host Network Mode_

![OpenHorizon_deployment_options.png](imgs%2FOpenHorizon_deployment_options.png)

6. Save changes - you should see "anylog-node" as a published service 

![OpenHorizon_published_service.png](imgs%2FOpenHorizon_published_service.png)

7. Create an AnyLog pattern 
![OpenHorizon_sample_pattern.png](imgs%2FOpenHorizon_sample_pattern.png)

## Create AnyLog node as a Service on Open Horizon

1. Request the AnyLog license key to download AnyLog from the _Docker_ repository using: [AnyLog Downloads](https://anylog.co/download-anylog) 

2. Update variables in the `service.definition.json` configuration file at ([Operator Node](deployments/operator/service.definition.json)) with the following:

| Variable       | Update with                             | Default Value | Comments     |
| -------------- | --------------------------------------- |  ------------ | ------------ |
| INIT_TYPE | training | training | Used to decide which AnyLog scripts to use for the deployment |   
| LICENSE_KEY    | The Docker Hub key provided by AnyLog   |               |  Request key using [AnyLog Downloads](https://anylog.co/download-anylog) |
| NODE_TYPE      | operator                                | operator      |  A node configured to host data |
| NODE_NAME      | [your company name]_operator[node id]   |               |  For example: ibm_operator123 |
| COMPANY_NAME   | [your company name]                     |               |  For example: ibm |
| LEDGER_CONN    | `132.177.125.232:32048`                   | `132.177.125.232:32048` | The Network ID (the IP and Port of the Master) |

3. Deploy Node - Note, `hzn` is not able to deploy more than a single instance on a given machine 
```shell
# Operator Node 
cd ~/service-anylog/deployments/operator/
hzn register --policy node.policy.json

# Query Node 
cd ~/service-anylog/deployments/query/
hzn register --policy node.policy.json
```

4. Validate node is running - the example is of 
* Validate via `docker log`
```shell
docker logs c33bd07d4808467d90fc1ef41ef2bff81d6502d5ca0bfb6b97ce614becda42b6-anylog-node

<<COMMENT
...
AL anylog-operator1 > 
    Process         Status       Details                                                                     
    ---------------|------------|---------------------------------------------------------------------------|
    TCP            |Running     |Listening on: 198.74.50.131:32148, Threads Pool: 6                         |
    REST           |Running     |Listening on: 198.74.50.131:32149, Threads Pool: 5, Timeout: 20, SSL: False|
    Operator       |Running     |Cluster Member: True, Using Master: 172.105.4.104:32048, Threads Pool: 3   |
    Publisher      |Not declared|                                                                           |
    Blockchain Sync|Running     |Sync every 30 seconds with master using: 132.177.125.232:32048             |
    Scheduler      |Running     |Schedulers IDs in use: [0 (system)] [1 (user)]                             |
    Distributor    |Not declared|                                                                           |
    Blobs Archiver |Running     |                                                                           |
    Consumer       |Not declared|                                                                           |
    MQTT           |Running     |                                                                           |
    Message Broker |Running     |Listening on: 198.74.50.131:32150, Threads Pool: 5                         |
    SMTP           |Not declared|                                                                           |
    Streamer       |Running     |Default streaming thresholds are 60 seconds and 10,240 bytes               |
    Query Pool     |Running     |Threads Pool: 3                                                            |
    Kafka Consumer |Not declared|                                                                           |

AL anylog-operator1 > 
Subscription ID: 0001
User:         ibglowct
Broker:       driver.cloudmqtt.com:18785
Connection:   Connected

     Messages    Success     Errors      Last message time    Last error time      Last Error
     ----------  ----------  ----------  -------------------  -------------------  ----------------------------------
              0           0           0  
     
     Subscribed Topics:
     Topic            QOS DBMS         Table            Column name Column Type Mapping Function        Optional Policies 
     ----------------|---|------------|----------------|-----------|-----------|-----------------------|--------|--------|
     anylogedgex-demo|  0|open_horizon|['[sourceName]']|timestamp  |timestamp  |now()                  |False   |        |
                     |   |            |                |value      |float      |['[readings][][value]']|False   |        |
<< 
```

* Test Network
```shell
curl -X GET 127.0.0.1:32149 -H "command: test network"

<<COMMNET
Address               Node Type Node Name         Status 
---------------------|---------|-----------------|------|
132.177.125.232:32048|master   |anylog-master    |  +   |
129.41.87.0:32348    |query    |openhorizon-query|  +   |
198.74.50.131:32148  |operator |anylog-operator1 |  +   |
<< 
``` 

