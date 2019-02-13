readonly DIR=$(dirname $0)

# We need the EnMasse playbook downloaded in a known location before starting
# the install. We also need to add in our own play file so that it uses the
# correct host, local, instead of enmasse which is what the default play uses.

if [ $# -eq 0 ] ; then
  ansible-playbook -i $DIR/inventories/hosts $DIR/playbooks/enmasse/enmasse-download.yml
else
  ansible-playbook -i $DIR/inventories/hosts $DIR/playbooks/enmasse/enmasse-download.yml --extra-vars enmasse_temp_download_path=$1
fi

