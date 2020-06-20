#!/bin/sh
set -xeuo pipefail
base=$1
prefix=$2
tag=$3
ctr=$(buildah from --net=host ${base})
cleanup () {
    buildah rm ${ctr} || true
}
trap cleanup ERR

podman pull ${base}

buildah copy ${ctr} *.sh /usr/lib/container/
buildah copy ${ctr} repos/ /usr/lib/container/repos/
buildah copy ${ctr} walters-gpg.txt /usr/share/walters-gpg.txt
buildah copy ${ctr} entrypoint.sh /usr/libexec/container-entrypoint
buildah run --net=host ${ctr} -- /usr/lib/container/base.sh
# Hack around buildah not accepting arrays for entrypoint
buildah commit ${ctr} ${prefix}:${tag}
buildah rm ${ctr}
