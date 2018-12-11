# Customising an Integreatly Cluster

## Modifying what is poured into a cluster

You can change what is installed by default by modifying the ```inventories/group_vars/all/manifest.yaml```

Each component has a flag that will stop it from being installed into the cluster.

Each component also has a version. At this point this version is just a reflection of what is installed and cannot be used to install newer versions.

**Note on Disabling Launcher**
Currently Che is linked to launcher's sso instance. If you choose not to install launcher, che will also not be installed. 


**Note on RH-SSO**
Installing backing RH-SSO is not optional


## Adding new components and customising existing components

# Prerequisites 

- Familiar with Ansible
- Have credentials to login as an admin in the Integreatly cluster
- Ensure logged into your cluster via oc


## Pull down your cluster's inventory file

Each Integreatly cluster has a secret in the webapp namespace with an inventory file that
can be used to help you add customisations using ansible playbooks.

``` 
oc get secret inventory -n webapp --template '{{index .data "generated_inventory"}}'  | base64 -D > inventory

```

Each of the components has a set of variables exposed via this inventory file. Each variable has a comment explaining what the value is. If there are things that you need which are missing, please create a issue on the installer repo.

## Limitations 

You do not have ssh access to the cluster so all customisations are limited to what can be done by the user you are logged in as via the OpenShift API and also via the various product APIs.


## Example Customisation

See the following repo for some examples of how to do customisations using the in cluster inventory file https://github.com/integr8ly/example-customisations




