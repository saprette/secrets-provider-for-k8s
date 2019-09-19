#!/bin/bash
set -xeuo pipefail

. utils.sh

function main() {
  deployConjur
  ./test_with_summon.sh
}

function deployConjur() {
  pushd ..
    git clone --single-branch --branch master git@github.com:cyberark/kubernetes-conjur-deploy kubernetes-conjur-deploy-$UNIQUE_TEST_ID
  popd

  cd ../kubernetes-conjur-deploy-$UNIQUE_TEST_ID && ./start
  cd ../test
}

main
