Integreatly
===========

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Overview](#overview)
- [Installing Integreatly](#installing-integreatly)
  - [Prerequisites](#prerequisites)
  - [Installation Steps](#installation-steps)
    - [1. Clone installation GIT repository locally](#1-clone-installation-git-repository-locally)
    - [2. Update inventory hosts file](#2-update-inventory-hosts-file)
    - [3. Check the connection with the OpenShift cluster](#3-check-the-connection-with-the-openshift-cluster)
    - [4. Run Install Playbooks](#4-run-install-playbooks)
      - [Install all products from a single playbook](#install-all-products-from-a-single-playbook)
        - [1. Create GitHub OAuth to enable GitHub authorization for Launcher](#1-create-github-oauth-to-enable-github-authorization-for-launcher)
        - [2. Run the playbook](#2-run-the-playbook)
        - [3. Add the generated `Authorization callback URL` to GitHub OAuth](#3-add-the-generated-authorization-callback-url-to-github-oauth)
        - [4. Check the installation](#4-check-the-installation)
      - [Install each product individually](#install-each-product-individually)
        - [Run Single Sign On install playbook](#run-single-sign-on-install-playbook)
        - [Run EnMasse install playbook](#run-enmasse-install-playbook)
        - [Run Che install playbook](#run-che-install-playbook)
        - [Run Launcher install playbook](#run-launcher-install-playbook)
        - [Run 3Scale install playbook](#run-3scale-install-playbook)
        - [Run Webapp install playbook](#run-webapp-install-playbook)
  - [Uninstallation steps](#uninstallation-steps)
  - [Troubleshooting](#troubleshooting)
    - [Message `"You need to install \"jmespath\" prior to running json_query filter"` is shown when the installation fails](#message-you-need-to-install-%5Cjmespath%5C-prior-to-running-json_query-filter-is-shown-when-the-installation-fails)
- [Contributing with Integreatly](#contributing-with-integreatly)
  - [Updating index of README.md](#updating-index-of-readmemd)
  - [Using Red Hat Product Demo System to have an OpenShift instance (Valid just for partners and redhatters)](#using-red-hat-product-demo-system-to-have-an-openshift-instance-valid-just-for-partners-and-redhatters)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Overview

The purpose of this repository is to provide a set of Ansible playbooks that can be used to install a range of Red Hat middleware products on Openshift.

These products include:

* Single Sign On
* Managed Services Broker
* EnMasse
* Eclipse Che
* Launcher
* 3Scale

# Installing Integreatly

## Prerequisites

* Ansible >= v2.6
* Openshift Container Platform >= v3.10
* Openshift CLI (OC) v3.10
* SSH Access to Openshift master(s)
* Cluster administrator permissions
* The ssh user defined in the inventory, `ansible_user`, needs have sudo permission

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

**NOTE:** It is possible to add the variable `ansible_ssh_private_key_file` for the master host when the ssh connection requires a public key.(E.g`ansible_ssh_private_key_file=~/.ssh/ocp-workshop.pem`)

### 3. Check the connection with the OpenShift cluster

Run the following command in order to check the connection with the OpenShift cluster from the `/installation/evals`.

```shell
$ ansible -m ping all
```

Following an example of the expected output.

```shell
$ ansible -m ping all
127.0.0.1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
master.example.openshiftworkshop.com | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 4. Run Install Playbooks

There are currently two options for installing:

* [Install all products from a single playbook](#install-all-products-from-a-single-playbook)
* [Install each product separately using their associated install playbooks](#install-each-product-individually)

#### Install all products from a single playbook

All products can be installed using the ```install.yml``` playbook located in the ```evals/playbooks/``` directory.

Before running the installer, please consider the following variables:

| Variable | Description |
| --- | --- |
| eval_self_signed_certs | Whether the OpenShift cluster uses self-signed certs or not. Defaults to `true`|
| github_client_id | GitHub OAuth client ID to enable GitHub authorization for Launcher. If not defined, GitHub authorization for Launcher will be disabled |
| github_client_secret | GitHub OAuth client secret to enable GitHub authorization for Launcher. If not defined, GitHub authorization for Launcher will be disabled |

##### 1. Create GitHub OAuth to enable GitHub authorization for Launcher

* Login into GitHub
* Go to `Settings >> Developer Settings >> New OAuth App`
* Add the following fields values

| Field | Value |
| --- | --- |
| Application Name | Any value |
| Home Page URL | http://localhost |
| Authorization callback URL | http://localhost |

**NOTE:** The callback URL is a placeholder for now and will be changed after the installation playbook is finished.

* Click on `Register Application`
* The values found in GitHub OAuth App, `Client ID` and `Client Secret`, will be required in the next step to install Integreatly enabling GitHub authorization for Launcher.

##### 2. Run the playbook

```shell
$ oc login https://<openshift-master-url> -u <user> -p <password>
$ cd evals/
$ $ ansible-playbook -i inventories/hosts playbooks/install.yml -e github_client_id=<your_client-id> -e github_client_secret=<your_client_secret>
```

**NOTE:** The following playbook will install Integreatly without to enable GitHub authorization for Launcher.

```shell
$ ansible-playbook -i inventories/hosts playbooks/install.yml
```

##### 3. Add the generated `Authorization callback URL` to GitHub OAuth

Following and example of the output made at the end of the playbook with this URL.

```shell
TASK [debug] *************************************************************************************************************************************************************************************************
ok: [127.0.0.1] => {
    "msg": "All services have been provisioned successfully. Please add 'https://launcher-sso-launcher.apps.example.openshiftworkshop.com/auth/realms/launcher_realm/broker/github/endpoint' as the Authorization callback URL of your GitHub OAuth Application."
}
```

The `http://localhost` placeholder added in the GitHub OAuth App should be replaced with this value.

##### 4. Check the installation

**IMPORTANT:** Once the installation has finished you will no longer be able to login via the Openshift console or oc cli as the admin if there is an sso redirect in place. The new admin user is `admin@example.com` password is `Password1`

The URL for the Integraly view is `https://tutorial-web-app-webapp.apps.<domain>/` (e.g `https://tutorial-web-app-webapp.apps.example.openshiftworkshop.com/` when the master is `https://master.example.openshiftworkshop.com/` )

Following an example of this interface.

**NOTE:** The project [Webapp](https://github.com/integr8ly/tutorial-web-app) is responsible for the Integraly interface. You can find the URL looking for the router created for this project. As the following example.

Also, with the evals users created by the installer is possible to check the services in the OpenShift catalog.

**NOTE**: The default login credentials are `evals@example.com` / `Password1`

Following an example.


#### Install each product individually

Each product has an associated install playbook available from the ```evals/playbooks/``` directory.

##### Run Single Sign On install playbook

```shell
$ oc login https://<openshift-master-url>
$ cd evals/
$ ansible-playbook -i inventories/hosts playbooks/rhsso.yml
```

Upon completion, a new identity provider named ```rh_sso``` should be presented on the Openshift master console login screen.

**NOTE**: The default login credentials are `evals@example.com` / `Password1`

To configure custom account credentials, simply override the rhsso role environment variables by specifying user parameters as part of the install command:

```shell
$ ansible-playbook -i inventories/hosts playbooks/rhsso.yml -e rhsso_evals_username=<username> -e rhsso_evals_password=<password>
```

##### Run EnMasse install playbook

```shell
$ oc login https://<openshift-master-url>
$ cd evals/
$ ansible-playbook -i inventories/hosts playbooks/enmasse.yml
```

Once the playbook has completed a service named `EnMasse (standard)` will be available
in the Service Catalog. This can be provisioned into your namespace to use EnMasse.

##### Run Che install playbook

Set the following variables:

| Variable | Description |
| --- | --- |
| che_route_suffix | The router suffix of the OpenShift cluster |
| che_keycloak_host | The route to the previously created SSO, without protocol |
| che_keycloak_user | Username to authenticate as, this would be the admin user by defaul |
| che_keycloak_password | Password of the user |
| che_namespace | The namesapce to provision che into |
| che_infra_namespace | This can usually be the same as `che_namespace` |

```shell
$ oc login https://<openshift-master-url>
$ cd evals/
$ ansible-playbook -i inventories/hosts playbooks/che-install.yml
```

##### Run Launcher install playbook

The Launcher playbook also requires information about the existing SSO that was
provisioned previously. It needs to know the route of the SSO. This can be
retrieved using:

```shell
$ oc get route sso -o jsonpath='{.spec.host}' -n rhsso
```

It also needs to know the realm to interact with. By default this would be
`openshift`. Finally it needs the credentials of a user to login as, by default
this would be the `admin` user created by the SSO playbook.

Specify the following variables in the inventory files or as `--extra-vars` when
running the playbook.

| Variable | Description |
| --- | --- |
| launcher_openshift_sso_route | The route to the previously created SSO, without protocol |
| launcher_openshift_sso_realm | The realm to create resources in the SSO, this would be `openshift` by default |
| launcher_openshift_sso_username | Username to authenticate as, this would be the admin user by default |
| launcher_openshift_sso_password | Password of the user |

If using self signed certs set `launcher_sso_validate_certs` to `no/false`.
Without this, an error will be thrown similar to this:

```
fatal: [127.0.0.1]: FAILED! => {"msg": "The conditional check 'launcher_sso_auth_response.status == 200' failed. The error was: error while evaluating conditional (launcher_sso_auth_response.status == 200): 'dict object' has no attribute 'status'"}
```

Next, run the playbook.

```shell
$ oc login https://<openshift-master-url>
$ cd evals
$ ansible-playbook -i inventories/hosts playbooks/launcher.yml
```

Once the playbook has completed it will print a debug message saying to update
the `Authorization callback URL` of the GitHub OAuth Application. Once this is
done the launcher setup has finished.

##### Run 3Scale install playbook

**Note:** 3Scale requires access to ReadWriteMany PVs. As such, it will only work on Openshift clusters that have RWX PVs available.

```shell
$ oc login https://<openshift-master-url>
$ cd evals/
$ ansible-playbook -i inventories/hosts playbooks/3scale.yml -e threescale_route_suffix=<openshift-router-suffix>
```

##### Run Webapp install playbook

```shell
$ oc login https://<openshift-master-url>
$ cd evals/
$ ansible-playbook -i inventories/hosts playbooks/webapp.yml
```


## Uninstallation steps

Run the uninstall.yml playbook from inside the evals directory:
```shell
$ cd evals/
$ ansible-playbook -i inventories/hosts playbooks/uninstall.yml
```

By default this will delete all user-created namespaces as well, if you wish to keep these namespaces then add the following flag:
```
-e keep_namespaces=true
```

## Troubleshooting

### Message `"You need to install \"jmespath\" prior to running json_query filter"` is shown when the installation fails

The issue means that python version where the ansible is installed did not have this required module. In order to fix it is required to install the missing module. Following the command to install it via `pip`.

```shell
$ pip install jmespath
```

**NOTE:** The module need to be installed in the same version of python used by Ansible. Use the command `$ ansible --version` to check this path.

# Contributing with Integreatly

## Updating index of README.md

Use the [doctoc](https://www.npmjs.com/package/doctoc) to update the index. Following the commands.

```shell
$ npm install -g doctoc
$ doctoc README.md
```

## Using Red Hat Product Demo System to have an OpenShift instance (Valid just for partners and redhatters)

* Login to https://rhpds.redhat.com/
* Go to `RHPDS >> Change Group` and select `rhpds-access`.
* Go to `Services >> Catalog` and choose the Service `Workshop >> Integreatly Workshop`
* Following information to request this service.

  | Field | Value |
  | --- | --- |
  | Region | Choose your regions |
  | City or Customer | Add a name with will be used to create the URL as `https://master.value.openshiftworkshop.com` |
  | FDC/Campaign/Deal Reg ID | 000000 |
  | Openshift Version | Select the Openshift Version that you would like to use (E.g 3.10.14) |
  | Notes | Any value |

**NOTE:** To move forward and request the OpenShift instance is required click on in the checkbox.

After 30 minutes you will receive a mail titled as `Your Red Hat Product Demo System service provision request for <your cluster> has completed.` . At the bottom of the email, you will see the Web App URL and admin username/password to have access to this cluster.
