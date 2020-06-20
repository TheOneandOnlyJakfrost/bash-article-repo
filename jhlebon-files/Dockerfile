# Quick and easy way to get a homey pet container.
FROM registry.fedoraproject.org/fedora:28
MAINTAINER Jonathan Lebon <jonathan@jlebon.com>

COPY . /files

# we install in /usr/local
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd --groups wheel --uid 1000 jlebon && \
    chown -R jlebon:jlebon /files

USER jlebon

RUN cd /files && source utils/setup

CMD ["/bin/bash"]

LABEL RUN="/usr/bin/docker run -ti --rm --privileged \
            -v /:/host --workdir \"/host/\$PWD\" \${OPT1} \
            \${IMAGE}"
