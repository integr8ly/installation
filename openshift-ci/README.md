## OpenShift CI

### Dockerfile.tools

Base image used on CI for all builds and test jobs.

#### Build and Test

```
$ docker build -t registry.svc.ci.openshift.org/openshift/release:intly-golang-1.13 - < Dockerfile.tools
$ IMAGE_NAME=registry.svc.ci.openshift.org/openshift/release:intly-golang-1.13 test/run
```