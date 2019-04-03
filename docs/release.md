# Releases

## New Releases

1) Check with the team to see do any of our components need a new release (gitea operator, webapp operator, keycloak operator etc)
2) To cut a brand new release checkout master and create a new branch e.g. v2.7 and push this branch to integr8ly upstream
3) Run the release script:
    
    ``` ./scripts/release.sh -b v2.7 -r release-2.7.0-rc1```

## New RCs and Patch releases     
If you are cutting a new rc or a patch release for an existing release then do the following

1) Check with the team if there is anything remaining to be cherry picked to the release branch
2) Run the release script:

For example to cut rc2 for release 2.7.0
       
       ``` ./scripts/release.sh -b v2.7 -r release-2.7.0-rc2```
       
To create rc1 of a patch release       

    ``` ./scripts/release.sh -b v2.7 -r release-2.7.1-rc1```
       
            