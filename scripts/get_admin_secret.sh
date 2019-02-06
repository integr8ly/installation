#!/usr/bin/env bash

oc get secret admin-user-credentials --template='{{index .data "password"}}' -n sso | base64 -d