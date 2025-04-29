#!/bin/bash
set -eo pipefail

default_uwu_id="jevolk/tuwunel"
uwu_id=${uwu_id:=$default_uwu_id}
uwu_acct=${uwu_acct:=$(echo $uwu_id | cut -d"/" -f1)}
uwu_repo=${uwu_repo:=$(echo $uwu_id | cut -d"/" -f2)}

CI="${CI:-0}"
BASEDIR=$(dirname "$0")

runner_name=$(echo $RUNNER_NAME | cut -d"." -f1)
runner_num=$(echo $RUNNER_NAME | cut -d"." -f2)

###############################################################################

tester_image="complement-tester--none--debian--testing-slim--x86_64-linux-gnu"
testee_image="complement-testee--test--nightly--x86_64-unknown-linux-gnu--none--debian--testing-slim--x86_64-linux-gnu"
name="complement_tester_nightly"
sock="/var/run/docker.sock"
arg="--rm --name $name -v $sock:$sock --network=host $tester_image ${testee_image}"

trap 'set +x; date; echo -e "\033[1;41;37mFAIL\033[0m"' ERR
date
env
set -x -e
cid=$(docker run -d $arg)
set +x
trap 'docker container stop $cid; set +x; date; echo -e "\033[1;41;37mFAIL\033[0m"' INT
docker wait "$cid" 2>/dev/null
echo -e "\033[1;42;37mPASS\033[0m"
