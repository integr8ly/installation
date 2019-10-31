#!/usr/bin/env bash

REMOTE=${REMOTE:-origin}

#check the current branch we are on
currentBranch=$(git symbolic-ref --short HEAD)
baseBranch=""
releaseTag=""

function reset_current_branch {
    #checkout current branch
    git checkout "$currentBranch"
}

while getopts ":b:r:h" opt; do
  case ${opt} in
    b)
      baseBranch=${OPTARG}
      ;;
    r)
      releaseTag=${OPTARG}
      ;;
    h)
      echo "This script will create a new integreatly release.
      Flags:
       - b <branch to cut the release from>
       - r <the release to create (release-1.3.1)
       - h help
       "
       exit
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ "$baseBranch" == "" || "$releaseTag" == "" ]]
then
echo "Flags:
       - b <branch to cut the release from>
       - r <the release to create (release-1.3.1)
       are required
"
exit 1
fi

if [[ $releaseTag =~ ^release-([0-9]+).([0-9]+).([0-9]+)-?(.*)?$ ]]; then
    MAJOR_VERSION=${BASH_REMATCH[1]}
    MINOR_VERSION=${BASH_REMATCH[2]}
    PATCH_VERSION=${BASH_REMATCH[3]}
    LABEL_VERSION=${BASH_REMATCH[4]}
else
    echo "Invalid release tag $releaseTag"
    exit 1
fi

if [[ $PATCH_VERSION -gt 0 ]]; then
    RELEASE_TYPE="patch"
else
    if [[ $MINOR_VERSION -gt 0 ]]; then
        RELEASE_TYPE="minor"
    else
        RELEASE_TYPE="major"
    fi
fi

echo "cutting ${RELEASE_TYPE} release ${releaseTag} from branch ${REMOTE}/${baseBranch}"

#do a fetch
git fetch ${REMOTE}

#check we have no local changes
dirty=$(git ls-files -m | wc -l)
if [[ "${dirty}" -gt "0" ]]
then
echo "
 the local file system is dirty cannot continue
"
exit 1
fi

trap reset_current_branch EXIT

# check if the specified from branch already exists if it does check it out otherwise create it
git checkout -B ${baseBranch} ${REMOTE}/${baseBranch}
if [[ $? > 0 ]]
then
echo "branch ${baseBranch} does not exist or you have local changes. Please create it and push it to ${REMOTE} before running the release"
exit 1
fi

git reset --hard HEAD

releaseExists=$(git tag | grep ${^releaseTag$} | wc -l)
if [[ "${releaseExists}" -gt "0" ]]
then
echo "
a release with that name already exists
"
exit 1
fi

sed -i.bak -E "s/^integreatly_version: .*$/integreatly_version: ${releaseTag}/g"  ./inventories/group_vars/all/manifest.yaml && rm ./inventories/group_vars/all/manifest.yaml.bak

#commit the change, tag
git commit -am "release manifest version  update for ${releaseTag}"
git tag ${releaseTag}

#reset upgrade playbook and variables if this is the final release
if [[ -z $LABEL_VERSION ]]; then
    echo "resetting upgrade playbook and variables after final release $releaseTag"
    cp scripts/upgrade.template.yml playbooks/upgrade.yml
    sed "s,UPGRADE_FROM_VERSION,$releaseTag,g" scripts/upgrade_vars.template.yml > playbooks/group_vars/all/upgrade.yml
    git commit -am "Reset upgrade variables after final release ${releaseTag}"
fi

#push branch
git push ${REMOTE} ${baseBranch}
git push ${REMOTE} ${releaseTag}
