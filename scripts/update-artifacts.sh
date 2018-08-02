readonly CURRENT_DIR=$(dirname $0)
readonly PROJ_ROOT_DIR=$CURRENT_DIR/..

readonly ENMASSE_ARTIFACT_DIR=$PROJ_ROOT_DIR/evals/artifacts/enmasse
readonly ENMASSE_RELEASE_VERSION=${1:-0.21.0}
readonly ENMASSE_RELEASE_URL=https://github.com/EnMasseProject/enmasse/releases/download/$ENMASSE_RELEASE_VERSION/enmasse-$ENMASSE_RELEASE_VERSION.tgz

rm -rf $ENMASSE_ARTIFACT_DIR
mkdir -p $ENMASSE_ARTIFACT_DIR
curl -L $ENMASSE_RELEASE_URL | tar zx --strip-components=1 -C $ENMASSE_ARTIFACT_DIR
cp $CURRENT_DIR/enmasse-playbook.yml $ENMASSE_ARTIFACT_DIR/ansible/playbooks/openshift/
