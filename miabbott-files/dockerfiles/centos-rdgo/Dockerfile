FROM registry.centos.org/centos
COPY walters-buildtools.repo /etc/yum.repos.d/
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install fedpkg \
                   mock \
                   rpmdistro-gitoverlay && \
    yum clean all && \
    adduser unprivileged && \
    usermod -a -G mock unprivileged
USER unprivileged
WORKDIR /rdgo
ENTRYPOINT ["/usr/bin/rpmdistro-gitoverlay"]

# Usage examples:
#  (Note we need --privileged since mock uses container functions internally)
#  alias rdgo='docker run -ti --rm --privileged -v $(pwd):/rdgo cgwalters/rpmdistro-gitoverlay'
#  rdgo init
#  rdgo resolve --fetch-all
#  rdgo build
