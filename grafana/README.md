# Grafana

Grafana is an open-source BI tool managed by [Grafana Labs](https://grafana.com/). We utilize Grafana as our default 
demo BI tool. For details documentation of how to use Grafana, please visit our [official documentation](https://github.com/AnyLog-co/documentation/blob/master/northbound%20connectors/using%20grafana.md)

Using Grafana, users can visualize time series data using pre-defined queries and add new queries using SQL.

By default, this repository provides 3 base models for users to start with:
* [Network Map](network_summary.json) - The dashboard consists of a map showing the location of all the nodes in the 
network, as well as a list of tables and operators that are part of the network.
![grafana_network_map.png](..%2Fimgs%2Fgrafana_network_map.png)


* [Kubernetes Alert](kubearmor_alert.json) - A dashboard demonstration (Alert) events seen by Kubearmor
![grafana_alert.png](..%2Fimgs%2Fgrafana_alert.png)


* [Kubernetes Log](kubearmor_log.json) - A dashboard demonstrating (Log) events seen by Kubearmor
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

* Log into Grafana and Declare a _(JSON) Data Source_
  1. [Login to Grafana](https://grafana.com/docs/grafana/latest/getting-started/getting-started/) - The default HTTP port that AnyLog GUI listens to is 3000 - On a local machine go to ```http://localhost:3000/```.

<img src="../imgs/grafana_login.png" alt="Grafana page" width="50%" height="50%" />

2. In _Data Sources_ section, create a new JSON data source
   * select a JSON data source.
   * On the name tab provide a unique name to the connection.
   * On the URL Tab add the REST address offered by the AnyLog node (i.e. http://10.0.0.25:2049)
   * On the ***Custom HTTP Headers***, name the default database. If no header is set, then all accessible databases to 
   the node will be available to query


|<img src="../imgs/grafana_datasource_connector.png" alt="Data Source Option" /> | <img src="../imgs/grafana_datasource_configuration.png" alt="Data Source Config" /> | 
| :---: | :---: |


## Uploading Dashboard

1. In a new Dashboard goto the _Settings_  
<img src="../imgs/grafana_base_dashboard.png" alt="Empty Dashboard" />


2. Go _JSON Model_ and add desired model

| <img src="../imgs/grafana_json_model_empty.png" alt="Empty JSON Model" width="75%" height="75%" /> | <img src="../imgs/grafana_json_model.png" alt="JSON Model" width="75%" height="75%"/> |
|:--------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------:|

3. Save Changes 

4. Once the changes are saved, you should see a new Dashboard 

| Before |                                After                                |
| :---: |:-------------------------------------------------------------------:|
| <img src="../imgs/grafana_no_dashboard.png" alt="No Dashboards" /> | <img src="../imgs/grafana_new_dashboard.png" alt="New Dashboard" /> | 

5. For each of the widgets update the following information:

<img src="../imgs/grafana_edit_button.png" alt="Edit Widget" width="75%" height="75%" />

* Data Source 

![grafana_update_datasource.png](..%2Fimgs%2Fgrafana_update_datasource.png)

* Metric value (AnyLog table name)

![grafana_update_table.png](..%2Fimgs%2Fgrafana_update_table.png)

Once these changes are saved, the outcome should look something like this: 
![grafana_outcome.png](..%2Fimgs%2Fgrafana_outcome.png)

