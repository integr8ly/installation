
# Integreatly Installation

## Overview

The purpose of this repository is to provide a set of Ansible playbooks that can be used to install a range of Red Hat middleware products on Openshift.

These products include:

* Single Sign On
* Managed Services Broker
* EnMasse
* Eclipse Che
* Launcher
* 3Scale

## Prerequisites

* Ansible v2.6
* Openshift Container Platform v3.10
* Openshift CLI (OC) v3.10
* SSH Access to Openshift master(s)
* Cluster administrator permissions

## Installation Steps

The following section demonstrates how to install each of the products listed above on an existing Openshift cluster.

### 1. Clone installation GIT repository locally

```shell
git clone https://github.com/integr8ly/installation.git
```

### 2. Update inventory hosts file

Prior to running the playbooks the master hostname and associated SSH username **must** be set in the inventory host file to match the target cluster configuration. The following example sets the SSH username to ```evals``` and the master hostname to ```master.evals.example.com```:

```yaml
~/installation/evals/inventories/hosts

[local:vars]
ansible_connection=local

[local]
127.0.0.1

[OSEv3:children]
master

[OSEv3:vars]
ansible_user=evals

[master]
master.evals.example.com
```

### 3. Run Install Playbooks

There are currently two options for installing:

* [Install all products from a single playbook](#install-all-products-from-a-single-playbook)
* [Install each product separately using their associated install playbooks](#install-each-product-individually)

#### Install all products from a single playbook

All products can be installed using the ```install.yml``` playbook located in the ```evals/playbooks/``` directory.

Before running the playbook, create a new OAuth Application on GitHub. This can
be done at https://github.com/settings/developers. Note the `Client ID` and `Client Secret` of the created
OAuth Application.

The installer has a number of important variables, namely:

* `eval_github_client_id` - `Client ID` of the created GitHub OAuth Application.
* `eval_github_client_secret` - `Client Secret` of the created GitHub OAuth Application.
* `eval_self_signed_certs` - Whether the OpenShift cluster uses self-signed certs or not. Defaults to `true`.

Run the playbook:

```shell
oc login https://<openshift-master-url>
cd evals/
ansible-playbook -i inventories/hosts playbooks/install.yml -e eval_github_client_id=<client-id> -e eval_github_client_secret=<client-secret> -e eval_self_signed_certs=<boolean> -e @./inventories/group_vars/all/common.yml
```

#### Install each product individually

Each product has an associated install playbook available from the ```evals/playbooks/``` directory.

#### Run Single Sign On install playbook

```shell
oc login https://<openshift-master-url>
cd evals/
ansible-playbook -i inventories/hosts playbooks/rhsso.yml
```

Upon completion, a new identity provider named ```rh_sso``` should be presented on the Openshift master console login screen.

Default login credentials are evals@example.com / Password1

To configure custom account credentials, simply override the rhsso role environment variables by specifying user parameters as part of the install command:

```shell
ansible-playbook -i inventories/hosts playbooks/rhsso.yml -e rhsso_evals_username=<username> -e rhsso_evals_password=<password>
```

#### Run EnMasse install playbook

```shell
oc login https://<openshift-master-url>
cd evals/
ansible-playbook -i inventories/hosts playbooks/enmasse.yml
```

Once the playbook has completed a service named `EnMasse (standard)` will be available
in the Service Catalog. This can be provisioned into your namespace to use EnMasse.

#### Run Che install playbook

Before running the playbook, create a new OAuth Application on GitHub. This can
be done at https://github.com/settings/developers. Note the `Client ID` and
`Client Secret` fields of the OAuth Application, these are required by the Che
playbook.

Set the following variables:

* `eval_github_client_id` - The `Client ID` of the created GitHub OAuth Application.
* `eval_github_client_secret` - The `Client Secret` of the created GitHub OAuth Application.
* `che_route_suffix` - The router suffix of the OpenShift cluster.
* `che_keycloak_host` - The route to the previously created SSO, without protocol.
* `che_keycloak_user` - Username to authenticate as, this would be the admin user by default.
* `che_keycloak_password` - Password of the user.
* `che_namespace` - The namesapce to provision che into.
* `che_infra_namespace` - This can usually be the same as `che_namespace`.

```shell
oc login https://<openshift-master-url>
cd evals/
ansible-playbook -i inventories/hosts playbooks/che-install.yml
```

#### Run Launcher install playbook

Before running the playbook, create a new OAuth Application on GitHub. This can
be done at https://github.com/settings/developers. Note the `Client ID` and
`Client Secret` fields of the OAuth Application, these are required by the
Launcher playbook.

The Launcher playbook also requires information about the existing SSO that was
provisioned previously. It needs to know the route of the SSO. This can be
retrieved using:

```shell
oc get route secure-sso -o jsonpath='{.spec.host}' -n rhsso
```

It also needs to know the realm to interact with. By default this would be
`openshift`. Finally it needs the credentials of a user to login as, by default
this would be the `admin` user created by the SSO playbook.

Specify the following variables in the inventory files or as `--extra-vars` when
running the playbook.

* `launcher_openshift_sso_route` - The route to the previously created SSO, without protocol.
* `launcher_openshift_sso_realm` - The realm to create resources in the SSO, this would be `openshift` by default.
* `launcher_openshift_sso_username` - Username to authenticate as, this would be the admin user by default.
* `launcher_openshift_sso_password` - Password of the user.
* `eval_github_client_id` - The `Client ID` of the created GitHub OAuth Application.
* `eval_github_client_secret` - The `Client Secret` of the created GitHub OAuth Application.

If using self signed certs set `launcher_sso_validate_certs` to `no/false`.
Without this, an error will be thrown similar to this:

```
fatal: [127.0.0.1]: FAILED! => {"msg": "The conditional check 'launcher_sso_auth_response.status == 200' failed. The error was: error while evaluating conditional (launcher_sso_auth_response.status == 200): 'dict object' has no attribute 'status'"}
```

Next, run the playbook.

```shell
oc login https://<openshift-master-url>
cd evals
ansible-playbook -i inventories/hosts playbooks/launcher.yml
```

Once the playbook has completed it will print a debug message saying to update
the `Authorization callback URL` of the GitHub OAuth Application. Once this is
done the launcher setup has finished.

#### Run 3Scale install playbook

Note: 3Scale requires access to ReadWriteMany PVs. As such, it will only work on Openshift clusters that have RWX PVs available.

```shell
oc login https://<openshift-master-url>
cd evals/
ansible-playbook -i inventories/hosts playbooks/3scale.yml -e threescale_route_suffix=<openshift-router-suffix>
```

##### Run Webapp install playbook

```shell
oc login https://<openshift-master-url>
cd evals/
ansible-playbook -i inventories/hosts playbooks/webapp.yml
```

## Uninstallation steps

Run the uninstall.yml playbook from inside the evals directory:
```shell
cd evals/
ansible-playbook -i inventories/hosts playbooks/uninstall.yml
```

By default this will delete all user-created namespaces as well, if you wish to keep these namespaces then add the following flag:
```
-e keep_namespaces=true
```