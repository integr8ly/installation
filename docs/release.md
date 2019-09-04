# Releases

## New Releases

### Installation Repo

1) Check with the team to see do any of our components need a new release (gitea operator, webapp operator, keycloak operator etc)
2) To cut a brand new release checkout master and create a new branch e.g. v2.7 and push this branch to integr8ly upstream
3) Run the release script:
    
    ``` ./scripts/release.sh -b v2.7 -r release-2.7.0-rc1```


### Resetting the upgrade playbook on master

There may be logic in the upgrade playbook that is targetted at the upcoming release only.
Once the release branch is created, the upgrade playbook should be reviewed and reset on `master` to remove any version specific blocks, tasks or roles being included.

As this is a manual task, here are some guidelines for doing the review.

* Any blocks that include a version specific upgrade task such as `upgrade_sso_72_to_73` can be removed
* Any blocks that are doing an install of a new product can be removed.
* Any blocks that are calling out to a generic `upgrade` task in a product role can usually be kept. These are likely to be doing an `oc apply` to resources that have been modified between releases and are safe to apply. Alternatively, they may be changing the version of a product operator, and the operator could be upgrading the product.

All changes should be PR'd against `master`.
Any release specific upgrade changes that need to be merged while a release is in progress should probably only land on the release branch. Discretion is advised based on the upgrade change being proposed and the above guidelines.

### SOPs/help repo

1) Checkout and pull down the latest `master` of https://github.com/fheng/integreatly-help (private repo)
2) Create a new branch for the release. e.g.:

    ```git checkout -b v2.7```
3) Review any `Known Issues` in the [Installation SOP](https://github.com/fheng/integreatly-help/blob/master/sops/OSD_SRE_integreatly_install.asciidoc), and add/remove as appropriate for this release.
4) Commit and push back the new branch to the upstream

## New RCs and Patch releases     
If you are cutting a new rc or a patch release for an existing release then do the following

1) Check with the team if there is anything remaining to be cherry picked to the release branch
2) Run the release script:

For example to cut rc2 for release 2.7.0
       
       ``` ./scripts/release.sh -b v2.7 -r release-2.7.0-rc2```
       
To create rc1 of a patch release       

    ``` ./scripts/release.sh -b v2.7 -r release-2.7.1-rc1```
       
            
