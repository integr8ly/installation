# Monitoring customization

It's possible to add your own monitoring and alerting to the cluster after it's installed.

## Adding your own monitoring rule

### HTTP(s) service monitoring

The easiest way to add your rule is by using *BlackboxTarget*. The Blackbox Target CR accepts the following properties in the spec:

* *blackboxTargets*: A list of targets for the blackbox exporter to probe.

The `blackboxTargets` should be provided as an array in the form of:

```yaml
  blackboxTargets:
    - service: example
      url: https://example.com
      module: http_extern_2xx
```

where `service` will be added as a label to the metric, `url` is the URL of the route to probe and `module` can be one of:

* *http_2xx*: Probe http or https targets via GET using the cluster certificates
* *http_post_2xx*: Probe http or https targets via POST using the cluster certificates
* *http_extern_2xx*: Probe http or https targets via GET relying on a valid external certificate

Follow up on the example here - [https://github.com/integr8ly/application-monitoring-operator/blob/master/deploy/examples/BlackboxTarget.yaml]

The process of adding your own alert is this:

1) Create yaml file with the BlackboxTarget CR (by modifying `BlackboxTarget.yaml` example above):

```yaml
apiVersion: applicationmonitoring.integreatly.org/v1alpha1
kind: BlackboxTarget
metadata:
  name: custom-mycustomservice-blackboxtarget
spec:
  blackboxTargets:
    - service: mycustomservice
      url: http://mycustomservice-my-nodejsproject.apps.vsazel-a4c3.open.redhat.com/  #replace with your service
      module: http_extern_2xx
```

and import CR to your cluster:

```bash
$ oc project middleware-monitoring
$ oc create -f BlackboxTarget.yaml 
blackboxtarget.applicationmonitoring.integreatly.org/example-blackboxtarget created
```

2) Create yaml file with the alerting CR `PrometheusRule`. 

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata: 
  labels:
    monitoring-key: custom-monitoring
    prometheus: application-monitoring
    role: alert-rules
  name: custom-alerts
spec:   
  groups: 
    - name: mycustomservice.rules
      rules: 
      - alert: ExampleCustomServiceUnavailableAlert
        annotations:
          message: >-
            Custom Service unavailable: If this console is
            unavailable, the clients won't be able to do something.
        expr: >
          probe_success{job="blackbox",service="mycustomservice"} < 1 or
            absent(probe_success{job="blackbox",service="mycustomservice"})
        for: 5m
        labels:
          severity: critical
```
and import it same as in previous case

```bash
$ oc project middleware-monitoring
$ oc create -f CustomMonitoringRule.yaml 
prometheusrule.monitoring.coreos.com/custom-alerts created
```
3) 

![Prometheus alert](prometheus-alert-working.png).

In *Prometheus* UI you should see the new alert. Check if it's working by killing the monitored service (decreasing pod count to 0).

### Kubernetes monitoring

TBD