
# Integreatly Installation

## Overview

The purpose of this repository is to provide a set of Ansible playbooks that can be used to install a range of Red Hat middleware products on Openshift.

These products include:

* Single Sign On
* EnMasse
* Fuse iPaaS

## Prerequisites

* Ansible v2.6
* Openshift Container Platform v3.9
* Openshift CLI (OC) v3.9
* SSH Access to Openshift master(s)
* Cluster administrator permissions

## Installation Steps

### Existing Openshift v3.9 clusters

The following section demonstrates how to install each of the products listed above on an existing Openshift cluster.

#### 1. Clone installation GIT repository locally

```shell
git clone https://github.com/integr8ly/installation.git
```

#### 2. Update inventory hosts file

Prior to running the playbooks the master hostname and associated SSH username need to be added to the inventory file. The following example sets the SSH username to ```evals``` and the master hostname to ```master.evals.example.com```:

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
openshift_master_config=/etc/origin/master/master-config.yaml

[master]
master.evals.example.com
```

#### 3. Run Single Sign On install playbook

```shell
cd evals/
ansible-playbook -i inventories/hosts playbooks/rhsso.yml
```

Upon completion, a new identity provider named ```rh_sso``` should be presented on the Openshift master console login screen.

Default login credentials are evals@example.com / Password1

To configure custom account credentials, simply override the rhsso role environment variables by specifying user parameters as part of the install command:

```shell
ansible-playbook -i inventories/hosts playbooks/rhsso.yml -e rhsso_service_username=<username> -e rhsso_service_password=<password>
```

#### 4. Run EnMasse install playbook

```shell
cd evals/
ansible-playbook -i inventories/hosts playbooks/enmasse.yml
```

Once the playbook has completed a service named `EnMasse (standard)` will be available
in the Service Catalog. This can be provisioned into your namespace to use EnMasse.

#### 5. Run Fuse iPaaS install playbook

```shell
cd evals/
ansible-playbook -i inventories/hosts playbooks/ipaas.yml
```
