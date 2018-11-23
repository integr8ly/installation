# Customising an Integreatly Cluster

# Prerequisites 

- Familiar with Ansible
- Have credentials to login as an admin in the Integreatly cluster
- Ensure logged into your cluster via oc


## Pull down your cluster's inventory file

Each Integreatly cluster has a secret in the webapp namespace with an inventory file that
can be used to help you add customisations using ansible playbooks.

``` 
oc get secret manifest -n webapp --template '{{index .data "generated_inventory"}}'  | base64 -D > inventory

```

Each of the components has a set of variables exposed via this inventory file. Each variable has a comment explaining what the value is. If there are things that you need which are missing, please create a issue on the installer repo.

## Limitations 

You do not have ssh access to the cluster so all customisations are limited to what can be done by the user you are logged in as via the OpenShift API and also via the various product APIs.


## Example Customisation

See the following repo for some examples of how to do customisations using the in cluster inventory file https://github.com/integr8ly/example-customisations




