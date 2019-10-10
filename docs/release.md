# Releases

## Jira & other non-code process

* Ensure the scope of the release is agreed on with relevant stakeholders.
* All issues should have a fixVersion of the planned patch release e.g. 1.5.0.
* A test plan to cover the installation and upgrade paths for what's changing in the release should be agreed with QE.
* Setup the release dashboard in Jira (See Jira Release Dashboard section below)
* Setup a recurring checkpoint call for the release (once per day) as soon as an ER1 or RC1 is cut


RANDOM UPDATE 

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


## Resetting the upgrade playbook


### Minor Release

There may be logic in the upgrade playbook that is targetted at a specific release only.
After the minor release branch is created, the upgrade playbook in `playbooks/upgrades/upgrade.yml` should be reviewed and reset on `master` to remove any version specific blocks, tasks or roles being included.

As this is a manual task, here are some guidelines for doing the review.

* Any blocks that include a version specific upgrade task such as `upgrade_sso_72_to_73` can be removed
* Any blocks that are doing an install of a new product can be removed.
* Any blocks that are calling out to a generic `upgrade` task in a product role can usually be kept. These are likely to be doing an `oc apply` to resources that have been modified between releases and are safe to apply. Alternatively, they may be changing the version of a product operator, and the operator could be upgrading the product.

All changes should be PR'd against `master`.
Any release specific upgrade changes that need to be merged while a release is in progress should probably only land on the release branch. Discretion is advised based on the upgrade change being proposed and the above guidelines.

### Patch Release

The upgrade playbook in `playbooks/upgrades/upgrade.yml` should be emptied of all tasks except for the version prerequisite check and manifest update task.
A patch release relies on the previous patch version having being installed/upgraded to already.
For example


## SOPs/help repo


### Minor Release

1) Checkout and pull down the latest `master` of https://github.com/fheng/integreatly-help (private repo)
2) Create a new branch for the release. e.g.:

    ```git checkout -b v1.5```
3) Review any `Known Issues` in the [Installation SOP](https://github.com/fheng/integreatly-help/blob/master/sops/OSD_SRE_integreatly_install.asciidoc), and add/remove as appropriate for this release.
4) Commit and push back the new branch to the upstream

### Patch Release

1) Checkout and pull down the release branch (e.g. v1.5) of https://github.com/fheng/integreatly-help (private repo)

    ```git checkout v1.5```
2) Review any `Known Issues` in the [Installation SOP](https://github.com/fheng/integreatly-help/blob/master/sops/OSD_SRE_integreatly_install.asciidoc), and add/remove as appropriate for this patch release.
3) Commit and push back any changes to the upstream

### Tagging the help repo

Once a release has been signed off, the [help repo](https://github.com/fheng/integreatly-help) will need to be tagged on the release branch:

```
git checkout v1.5
git fetch origin
git reset --hard HEAD
git tag release-1.5.0
git push origin release-1.5.0
```
