#!/bin/bash
set -euxo pipefail

# Restore secret to original value
set_namespace $CONJUR_NAMESPACE_NAME

configure_cli_pod
$cli_with_timeout "exec $(get_conjur_cli_pod_name) -- conjur variable values add secrets/test_secret \"supersecret\""

set_namespace $TEST_APP_NAMESPACE_NAME

$cli_with_timeout "delete secret dockerpullsecret --ignore-not-found=true"

$cli_with_timeout "delete clusterrole secrets-access-${UNIQUE_TEST_ID} --ignore-not-found=true"

$cli_with_timeout "delete secret test-k8s-secret --ignore-not-found=true"

$cli_with_timeout "delete serviceaccount ${TEST_APP_NAMESPACE_NAME}-sa --ignore-not-found=true"

$cli_with_timeout "delete rolebinding secrets-access-role-binding --ignore-not-found=true"

if [ "${PLATFORM}" = "kubernetes" ]; then
  $cli_with_timeout "delete deployment test-env --ignore-not-found=true"
elif [ "${PLATFORM}" = "openshift" ]; then
  $cli_with_timeout "delete deploymentconfig test-env --ignore-not-found=true"
fi

$cli_with_timeout "delete configmap conjur-master-ca-env --ignore-not-found=true"

 echo "Verifying there are no (terminating) pods of type test-env"
 $cli_with_timeout "get pods --namespace=$TEST_APP_NAMESPACE_NAME --selector app=test-env --no-headers | wc -l | tr -d ' ' | grep '^0$'"
