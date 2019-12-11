#!/usr/bin/env bash

set -e

for entry in *.y*ml; do  ansible-playbook -i ../test/inventories/hosts playbooks/$entry --syntax-check; done

ansible-lint playbooks/install.yml
ansible-lint playbooks/upgrade.yml

for entry in roles/*; do echo Examining $entry && ansible-lint $entry; done
