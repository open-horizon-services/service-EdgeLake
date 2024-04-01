# Importing EdgeLake related dashboards into Grafana

## Related documentation
* An overview of the AnyLog KubeARmor integration is available in 
[integration wiki page](https://wiki.lfedge.org/display/OH/AnyLog+-+KubeArmor+Integration).
* Directions for deploying KubeArmor with EdgeLake can be found [here](EdgeLake_KubeArmor_integration.md).
* Instructions to create and manage Grafana instances with EdgeLake/AnyLog,
  can be found in AnyLog's [official documentation - Using Grafana](https://github.com/AnyLog-co/documentation/blob/master/northbound%20connectors/using%20grafana.md).

## Grafana Dashboards examples (for KubeArmor)
The following document provides 3 sample Grafana dashboards
* [Network Map](../grafana/network_summary.json) - The dashboard consists of:
  1. a map showing the nodes in the network
  2. a list of the operator nodes
  3. a list of  tables supported in the network
![grafana_network_map.png](..%2Fimgs%2Fgrafana_network_map.png)


* [Kubernetes Alert](../grafana/kubearmor_alert.json) - A dashboard representing alerts from kubearmor-relay.

 
![grafana_alert.png](..%2Fimgs%2Fgrafana_alert.png)


* [Kubernetes Log](../grafana/kubearmor_log.json) - A dashboard representing logs from kubearmor-relay.


![grafana_log.png](..%2Fimgs%2Fgrafana_log.png)


## Setting Up Grafana

* An [installation of Grafana](https://grafana.com/docs/grafana/latest/setup-grafana/installation/) - We support _Grafana_ version 7.5 and higher, we recommend using _Grafana_ version 9.5.16 or higher. 
```shell
docker run --name=grafana \
  -e GRAFANA_ADMIN_USER=admin \
  -e GRAFANA_ADMIN_PASSWORD=admin \
  -e GF_AUTH_DISABLE_LOGIN_FORM=false \
  -e GF_AUTH_ANONYMOUS_ENABLED=true \
  -e GF_SECURITY_ALLOW_EMBEDDING=true \
  -e GF_INSTALL_PLUGINS=simpod-json-datasource,grafana-worldmap-panel \
  -e GF_SERVER_HTTP_PORT=3000 \
  -v grafana-data:/var/lib/grafana \
  -v grafana-log:/var/log/grafana \
  -v grafana-config:/etc/grafana \
  -it -d -p 3000:3000 --rm grafana/grafana:9.5.16
```

Directions to install Grafana as a OpenHorizon service can be found [here](https://github.com/open-horizon-services/service-grafana)

###  Log into Grafana and Declare a _(JSON) Data Source_

1. [Login to Grafana](https://grafana.com/docs/grafana/latest/getting-started/getting-started/) - The default Grafana HTTP port is 3000  
   * URL: http://localhost:3000/ 
   * username: admin | password: admin

<img src="../imgs/grafana_login.png" alt="Grafana page" width="50%" height="50%" />

2. In _Data Sources_ section, create a new JSON data source
   * select a JSON data source.
   * On the name tab provide a unique name to the connection.
   * On the URL tab add the REST address offered by the EdgeLake node (i.e. http://10.0.0.25:2049)
   * On the ***Custom HTTP Headers***, name the default database. If no header is set, then all EdgeLake hosted databases will be available to a query process.


|<img src="../imgs/grafana_datasource_connector.png" alt="Data Source Option" /> | <img src="../imgs/grafana_datasource_configuration.png" alt="Data Source Config" /> | 
| :---: | :---: |


## Uploading Dashboard

1. In a new Dashboard goto the _Settings_  
<img src="../imgs/grafana_base_dashboard.png" alt="Empty Dashboard" />


2. Go _JSON Model_ and add desired model - A model is the JSON object being used to generate the grafana dashboard (for example: [Kubernetes Alert](../grafana/kubearmor_alert.json)).

| <img src="../imgs/grafana_json_model_empty.png" alt="Empty JSON Model" width="75%" height="75%" /> | <img src="../imgs/grafana_json_model.png" alt="JSON Model" width="75%" height="75%"/> |
|:--------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------:|

3. Save Changes


4. Once the changes are saved, you should see a new Dashboard 

| Before |                                After                                |
| :---: |:-------------------------------------------------------------------:|
| <img src="../imgs/grafana_no_dashboard.png" alt="No Dashboards" /> | <img src="../imgs/grafana_new_dashboard.png" alt="New Dashboard" /> | 

5. For each of the widgets update the following information:
   * Data Source 
   * Metric value (EdgeLake table name)

Once these changes are saved, the outcome should look something like this:

|          View when accessing Dashboard          | Update Data Source | Update Metric Value | Outcome | 
|:-----------------------------------------------:| :---: | :---: | :---:  |
| ![Edit Widget](imgs/grafana_edit_button.png) | ![grafana_update_datasource.png](..%2Fimgs%2Fgrafana_update_datasource.png) | ![grafana_update_table.png](..%2Fimgs%2Fgrafana_update_table.png) | ![grafana_outcome.png](..%2Fimgs%2Fgrafana_outcome.png) |   
