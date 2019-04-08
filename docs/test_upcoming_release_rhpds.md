# Testing a new release before it is available in RHPDS

- provision an existing integreatly workshop from the production catalog (this will ensure you have valid ssl certs)
- ssh to the bastion and clone the installer.
        
```
   ssh -i ~/.ssh/ocp-workshop.pem ec2-user@<bastion>
   sudo su
   git clone https://github.com/integr8ly/installation.git
   cd installation
   git checkout <release-1.x.x>
```  
- update the hosts file
```
  oc get nodes
```
Find the master node and add it under the ```inventories/hosts.template ``` file

- Run the uninstall
```
ansible-playbook -i inventories/hosts.template playbook/uninstall.yml
```

- Run the install

```
ansible-playbook -i inventories/hosts.template playbook/install.yml -e 'eval_self_signed_certs=false'
```
