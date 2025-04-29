#!/bin/bash
set -eo pipefail

default_docker_id="jevolk/tuwunel"
docker_id=${docker_id:=$default_docker_id}
docker_acct=${docker_acct:=$(echo $docker_id | cut -d"/" -f1)}
docker_repo=${docker_repo:=$(echo $docker_id | cut -d"/" -f2)}

CI="${CI:-true}"
BASEDIR=$(dirname "$0")

default_cargo_profiles='["test", "bench"]'
default_feat_sets='["none", "default", "all"]'
default_rust_toolchains='["nightly", "stable"]'
default_rust_targets='["x86_64-unknown-linux-gnu"]'
default_sys_names='["debian"]'
default_sys_targets='["x86_64-linux-gnu"]'
default_sys_versions='["testing-slim"]'

if test ! -z "$cargo_profile"; then
    env_cargo_profiles="[\"${cargo_profile}\"]"
fi

if test ! -z "$feat_set"; then
    env_feat_sets="[\"${feat_set}\"]"
fi

if test ! -z "$rust_target"; then
    env_rust_targets="[\"${rust_target}\"]"
fi

if test ! -z "$rust_toolchain"; then
    env_rust_toolchains="[\"${rust_toolchain}\"]"
fi

if test ! -z "$sys_name"; then
    env_sys_name="[\"${sys_name}\"]"
fi

if test ! -z "$sys_target"; then
    env_sys_target="[\"${sys_target}\"]"
fi

if test ! -z "$sys_version"; then
    env_sys_version="[\"${sys_version}\"]"
fi

set -a
bake_target="${bake_target:-$@}"
cargo_profiles="${env_cargo_profiles:-$default_cargo_profiles}"
feat_sets="${env_feat_sets:-$default_feat_sets}"
rust_targets="${env_rust_targets:-$default_rust_targets}"
rust_toolchains="${env_rust_toolchains:-$default_rust_toolchains}"
sys_names="${env_sys_names:-$default_sys_names}"
sys_targets="${env_sys_targets:-$default_sys_targets}"
sys_versions="${env_sys_versions:-$default_sys_versions}"

runner_name=$(echo $RUNNER_NAME | cut -d"." -f1)
runner_num=$(echo $RUNNER_NAME | cut -d"." -f2)
rocksdb_opt_level=3
rocksdb_portable=1
git_checkout="HEAD"
use_chef="true"
complement_count=1
complement_skip="TestPartialStateJoin.*"
complement_skip="${complement_skip}|TestRoomDeleteAlias/Pa.*/Can_delete_canonical_alias"
complement_skip="${complement_skip}|TestUnbanViaInvite.*"
complement_skip="${complement_skip}|TestRoomDeleteAlias/Pa.*/Regular_users_can_add_and_delete_aliases_when.*"
complement_skip="${complement_skip}|TestToDeviceMessagesOverFederation/stopped_server"
complement_run=".*"
set +a

###############################################################################

export DOCKER_BUILDKIT=1
if test "$CI" = "true"; then
    export BUILDKIT_PROGRESS="plain"
    echo "plain"
fi

uwu_docker_build_args=""
args="$uwu_docker_build_args"
args="$args --builder owo"
args="$args --set *.platform=${sys_platform}"

if test ! -z "$runner_num"; then
    #cpu_num=$(expr $runner_num % $(nproc))
    #args="$args --cpuset-cpus=${cpu_num}"
    args="$args --set *.args.nprocs=1"
    # https://github.com/moby/buildkit/issues/1276
else
    nprocs=$(nproc)
    args="$args --set *.args.nprocs=${nprocs}"
fi

trap 'set +x; date; echo -e "\033[1;41;37mFAIL\033[0m"' ERR
env
date

arg="$args -f $BASEDIR/bake.hcl"
if test "$BUILDKIT_PROGRESS" = "plain"; then
	echo "PRINTING"
    docker buildx bake --print $arg $bake_target
fi

if test "$NO_BAKE" = "1"; then
    exit 0
fi

trap '' ERR
set -ux

docker buildx bake $arg $bake_target

set +x
echo -e "\033[1;42;37mPASS\033[0m"
