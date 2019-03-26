#!/usr/bin/env bash

REMOTE=${REMOTE:-origin}

#check the current branch we are on
currentBranch=$(git symbolic-ref --short HEAD)
baseBranch=""
releaseTag=""

while getopts ":b:r:h" opt; do
  echo "opt $opt"
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

echo "cutting release ${releaseTag} from branch ${REMOTE}/${baseBranch}"
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

# check if the specified from branch already exists if it does check it out otherwise create it

git checkout -B ${baseBranch} ${REMOTE}/${baseBranch}
if [[ $? > 0 ]]
then
echo "branch ${baseBranch} does not exist or you have local changes. Please create it and push it to ${REMOTE} before running the release"
exit 1
fi

git reset --hard HEAD

releaseExists=$(git tag | grep ${releaseTag} | wc -l)
if [[ "${releaseExists}" -gt "0" ]]
then
echo "
a release with that name already exists
"
exit 1
fi


sed -i.bak -E "s/^integreatly_version: .*$/integreatly_version: ${releaseTag}/g"  ./inventories/group_vars/all/manifest.yaml && rm ./inventories/group_vars/all/manifest.yaml.bak

#commit the change and push
git commit -am "release manifest version  update for ${releaseTag}"
git push ${REMOTE} ${baseBranch}
#tag and push
git tag ${releaseTag}
git push ${REMOTE} ${releaseTag}
