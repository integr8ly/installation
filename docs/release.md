# Releases

## Jira & other non-code process

* Ensure the scope of the release is agreed on with relevant stakeholders.
* All issues should have a fixVersion of the planned patch release e.g. 1.5.0.
* A test plan to cover the installation and upgrade paths for what's changing in the release should be agreed with QE.
* Setup the release dashboard in Jira (See Jira Release Dashboard section below)
* Setup a recurring checkpoint call for the release (once per day) as soon as an ER1 or RC1 is cut

## Jira Release Dashboard

There is a release dashboard that shows all relevant issues for a release and their status (https://issues.jboss.org/secure/Dashboard.jspa?selectPageId=12329297).
This dashboard and all it's sub-filters are driven by 2 main filters:

* RHMI Release - `_fixVersion` (https://issues.jboss.org/issues/?filter=12341116)
* RHMI Release - `_affectedVersion` (https://issues.jboss.org/issues/?filter=12341117)

When a release has started, this dashboard can be reused by updating the fixVersion & affectsVersion accordingly in these 2 filters.
You may need to request permissions to modify these.

## Installation Repo

* Check with the team if there is anything remaining to be merged/cherry-picked to the appropriate branch.

### Minor Release

To cut the first RC for a new minor release (e.g. 1.5.0):

* Checkout master and create a new branch e.g. v1.5 and push this branch to integr8ly upstream
* Run the release script e.g. `./scripts/release.sh -b v1.5 -r release-1.5.0-rc1`

For subsequent RCs, do the following:
       
`./scripts/release.sh -b v1.5 -r release-1.5.0-rc2`

### Patch Release

To cut the first RC for a new patch release (e.g. v1.5.1):

`./scripts/release.sh -b v1.5 -r release-1.5.1-rc1`

To cut subsequent RCs for a patch release:

`./scripts/release.sh -b v1.5 -r release-1.5.1-rc2`

### Final release

When the script above is run for the final release e.g. (non rc release - release-x.y.z) the upgrade files will be reset. This was done manually but is now automated by the release script to reset these files on both the release branch and on master.

Release branch - A commit is pushed to the release branch to reset the files
Master branch - A new branch titled ${releaseTag}-master-upgrade-reset is pushed

For the master branch reset, please go ahead and create a pr from the above branch to master, and review and merge it using the normal procedures.

## SOPs/help repo


### Minor Release

1) Checkout and pull down the latest `master` of https://github.com/RHCloudServices/integreatly-help (private repo)
2) Create a new branch for the release. e.g.:

    ```git checkout -b v1.5```
3) Review any `Known Issues` in the [Installation SOP](https://github.com/RHCloudServices/integreatly-help/blob/master/sops/OSD_SRE_integreatly_install.asciidoc), and add/remove as appropriate for this release.
4) Commit and push back the new branch to the upstream

### Patch Release

1) Checkout and pull down the release branch (e.g. v1.5) of https://github.com/RHCloudServices/integreatly-help (private repo)

    ```git checkout v1.5```
2) Review any `Known Issues` in the [Installation SOP](https://github.com/RHCloudServices/integreatly-help/blob/master/sops/OSD_SRE_integreatly_install.asciidoc), and add/remove as appropriate for this patch release.
3) Commit and push back any changes to the upstream

### Tagging the help repo

Once a release has been signed off, the [help repo](https://github.com/RHCloudServices/integreatly-help) will need to be tagged on the release branch:

```
git checkout v1.5
git fetch origin
git reset --hard HEAD
git tag release-1.5.0
git push origin release-1.5.0
```
