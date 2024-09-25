# Index for OpenHorizon Install 

The following provides sample output for step 3 of [OpenHorizon Installation](Install_OpenHorizon.md) 

1. Started Horizon management hub services: 
   * Agbot
   * CSS
   * Exchange
   * FDO
   * MongoDB
   * Postgres DB
   * Postgres DB 
   * FDO Vault

2. Created exchange resources: system organization (IBM) admin user, user organization (_myorg_) and admin user, and agbot 
Automatically generated these passwords/tokens:

**Important**: save these generated passwords/tokens in a safe place. You will not be able to query them from Horizon. 
Authentication to the Exchange is in the format `<organization>/<identity>:<password>` or `$HZN_ORG_ID/$HZN_EXCHANGE_USER_AUTH`.

```shell
export EXCHANGE_ROOT_PW=[UNIQUE_AUTHENTICAATION]
export HZN_ORG_ID=root
export HZN_EXCHANGE_USER_AUTH=root:[UNIQUE_AUTHENTICAATION]

export EXCHANGE_HUB_ADMIN_PW=[UNIQUE_AUTHENTICAATION]
export HZN_ORG_ID=root
export HZN_EXCHANGE_USER_AUTH=hubadmin:[UNIQUE_AUTHENTICAATION]

export EXCHANGE_SYSTEM_ADMIN_PW=[UNIQUE_AUTHENTICAATION]
export HZN_ORG_ID=IBM
export HZN_EXCHANGE_USER_AUTH=admin:[UNIQUE_AUTHENTICAATION]

export AGBOT_TOKEN=[UNIQUE_AUTHENTICAATION]
export HZN_ORG_ID=IBM
export HZN_EXCHANGE_USER_AUTH=agbot:[UNIQUE_AUTHENTICAATION]

export EXCHANGE_USER_ADMIN_PW=[UNIQUE_AUTHENTICAATION]
export HZN_ORG_ID=myorg
export HZN_EXCHANGE_USER_AUTH=admin:[UNIQUE_AUTHENTICAATION]

export HZN_DEVICE_TOKEN=[UNIQUE_AUTHENTICAATION]
export HZN_ORG_ID=myorg
export HZN_EXCHANGE_USER_AUTH=node1:[UNIQUE_AUTHENTICAATION]
```

3. Installed and configured the Horizon agent and CLI (hzn)
4. Created a Horizon developer key pair 
5. Installed the Horizon examples 
6. Created and registered an edge node to run the helloworld example edge service  
7. Created a vault instance: http://127.0.0.1:8200/ui/vault/auth?with=token Automatically generated this key/token:
```shell
export VAULT_UNSEAL_KEY=[UNIQUE_AUTHENTICAATION]
export VAULT_ROOT_TOKEN=[UNIQUE_AUTHENTICAATION]
```
**Important**: save this generated key/token in a safe place. You will not be able to query them from Horizon.

8. Created a FDO Owner Service instance. Run test-fdo.sh to simulate the transfer of a device and automatic workload 
provisioning. FDO Owner Service on port 8042 API credentials:
```shell
export FDO_OWN_SVC_AUTH=apiUser:[UNIQUE_AUTHENTICAATION]
```

9. Added the hzn auto-completion file to ~/.bashrc (but you need to source that again for it to take effect in this 
shell session)

For what to do next, see: https://github.com/open-horizon/devops/blob/master/mgmt-hub/README.md#all-in-1-what-next
Before running the commands in the What To Do Next section, copy/paste/run these commands in your terminal:
```shell
export HZN_ORG_ID=myorg
export HZN_EXCHANGE_USER_AUTH=admin:[UNIQUE_AUTHENTICAATION]
```