#!/bin/bash
set -xeou pipefail

releasever=28

dnf_cmd() {
  dnf -y --installroot $mp --releasever $releasever $@
}

ctr=$(buildah from registry.fedoraproject.org/fedora:$releasever)

mp=$(buildah mount $ctr)

dnf_cmd install @buildsys-build dnf-plugins-core

dnf_cmd builddep rpm-ostree

dnf_cmd install cargo python3-sphinx python3-devel \
                ostree-devel ostree-grub2 createrepo_c jq PyYAML \
                libubsan libasan libtsan elfutils fuse sudo python-gobject-base \
                selinux-policy-devel python2-createrepo_c \
                rpm-python parallel clang rsync ansible

dnf_cmd clean all

chroot $mp bash -c "/usr/sbin/useradd --groups wheel --uid 9000 tester"

buildah config --user tester $ctr

buildah commit $ctr miabbott/rpm-ostree-devel:$releasever

buildah umount $ctr
buildah rm $ctr
