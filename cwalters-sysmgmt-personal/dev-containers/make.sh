#!/usr/bin/bash
ver=$1
shift

case $ver in
    f28|f29|f30) ./build.sh  registry.fedoraproject.org/${ver}/fedora-toolbox:${ver:1} cgwalters/fedora-toolbox ${ver:1};;
    c7) ./build.sh registry.centos.org/centos/centos:7 cgwalters/centos-dev 7;;
    r7) ./build.sh registry.access.redhat.com/rhel7 cgwalters/rhel-dev 7;;
    r8) ./build.sh docker-registry.engineering.redhat.com/rhel-appstream/rhel8 cgwalters/rhel-dev 8;;
esac
