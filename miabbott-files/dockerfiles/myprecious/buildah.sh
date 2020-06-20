#!/bin/bash
set -xeou pipefail

cleanup() {
  ctr=$1; shift
  buildah umount "$ctr"
  buildah rm "$ctr"
}

dnf_cmd() {
  dnf -y --installroot "$mp" --releasever "$releasever" "$@"
}

if [ $# -eq 0 ]; then
  echo "Must supply value for releasever"
  exit 1
fi
releasever=$1; shift

registry="docker-registry.registry.upshift.redhat.com"

token="$(cat /home/miabbott/.secrets/upshift-registry-sa.secret)"

# create base container
ctr=$(buildah from registry.fedoraproject.org/fedora:"$releasever")

trap 'cleanup $ctr' ERR

# mount container filesystem
mp=$(buildah mount "$ctr")

# set the maintainer label
buildah config --label maintainer="Micah Abbott <miabbott@redhat.com>" "$ctr"

# install update-ca-trust via ca-certificates
dnf_cmd install ca-certificates

# get Red Hat certs
curl -kL -o $mp/etc/pki/ca-trust/source/anchors/Red_Hat_IT_Root_CA.crt https://password.corp.redhat.com/RH-IT-Root-CA.crt
curl -kL -o $mp/etc/pki/ca-trust/source/anchors/legacy.crt https://password.corp.redhat.com/legacy.crt
curl -kL -o $mp/etc/pki/ca-trust/source/anchors/Eng-CA.crt https://engineering.redhat.com/Eng-CA.crt
chroot "$mp" bash -c "update-ca-trust"

# setup yum repos
curl -L -o "$mp"/etc/yum.repos.d/rcm-tools-fedora.repo https://download.devel.redhat.com/rel-eng/RCMTOOLS/rcm-tools-fedora.repo

# coreutils-single conflicts with coreutils so have to swap?
if [ "$releasever" == "29" ]; then
  dnf_cmd swap coreutils-single coreutils-full
fi

# reinstall all pkgs with docs
sed -i '/tsflags=nodocs/d' "$mp"/etc/dnf/dnf.conf
dnf -y --installroot "$mp" --releasever "$releasever" --disablerepo=beaker-client --disablerepo=qa-tools reinstall '*'

# OCP4 or die, yo
OC_URL="https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz"
OC_TARGZ="${OC_URL:(-9)}"
tmpdir=$(mktemp -d)
curl -L -o "${tmpdir}/${OC_TARGZ}" "${OC_URL}"
tar -zxvf "${tmpdir}/${OC_TARGZ}" -C "${tmpdir}"
cp "${tmpdir}/oc" "$mp/usr/local/bin/oc"
chmod +x "$mp/usr/local/bin/oc"
rm -rf "${tmpdir}"

# install tools needed for building ostree/rpm-ostree stack
if [ "$releasever" == "30" ]; then
  dnf_cmd install --excludepkg fedora-release @buildsys-build dnf-plugins-core
else
  dnf_cmd install @buildsys-build dnf-plugins-core
fi
dnf_cmd builddep ostree rpm-ostree

# install the rest
dnf_cmd install \
                   awscli \
                   bind-utils \
                   brewkoji \
                   btrfs-progs-devel\
                   conserver-client \
                   createrepo_c \
                   cyrus-sasl-gssapi \
                   device-mapper-devel \
                   fuse \
                   gcc \
                   gdb \
                   git \
                   git-evtag \
                   git-review \
                   glib2-devel \
                   glibc-static \
                   golang \
                   golang-github-cpuguy83-go-md2man \
                   gpg \
                   gpgme-devel \
                   hostname \
                   iputils \
                   libassuan-devel \
                   libgpg-error-devel \
                   libguestfs-tools \
                   libseccomp-devel \
                   libselinux-devel \
                   libvirt-devel \
                   lz4 \
                   jq \
                   koji \
                   krb5-workstation \
                   man \
                   openldap-clients \
                   podman \
                   python-qpid-messaging \
                   python-saslwrapper \
                   python2-virtualenv \
                   python3-flake8 \
                   python3-pylint \
                   python3-virtualenv \
                   redhat-rpm-config \
                   rhpkg \
                   rpm-ostree \
                   rsync \
                   rubygems \
                   ruby-devel \
                   ShellCheck \
                   skopeo \
                   sshpass \
                   sudo \
                   tig \
                   tmux \
                   tree \
                   vim \
                   wget

# install keybase
dnf_cmd install https://prerelease.keybase.io/keybase_amd64.rpm

# install bat
#cp /etc/resolv.conf "$mp"/etc/resolv.conf
#mount -t proc /proc "$mp"/proc
#mount -t sysfs /sys "$mp"/sys
#chroot "$mp" git clone https://github.com/sharkdp/bat
#chroot "$mp" bash -c "(cd bat && /usr/bin/cargo install --root /usr/local bat && /usr/bin/cargo clean)"
#chroot "$mp" bash -c "(mv /usr/bin/cat /usr/bin/cat.old && ln -s /usr/local/bin/bat /usr/bin/cat)"
#chroot "$mp" bash -c "rm -rf bat"
#umount "$mp/proc"
#umount "$mp/sys"

# clean up
dnf_cmd clean all

# setup sudoers
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> "$mp"/etc/sudoers
echo "Defaults secure_path = /usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >> "$mp"/etc/sudoers

# add my username/uid
chroot "$mp" bash -c "/usr/sbin/useradd --groups wheel --uid 1000 miabbott"

# config the user
buildah config --user miabbott "$ctr"

# commit the image
buildah commit "$ctr" miabbott/myprecious:"$releasever"

# unmount and remove the container
cleanup "$ctr"

# tag and push image
podman login -u unused -p "$token" "$registry"
podman tag localhost/miabbott/myprecious:"$releasever" "$registry"/miabbott/myprecious:"$releasever"
podman push "$registry"/miabbott/myprecious:"$releasever"
