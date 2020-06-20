FROM registry.fedoraproject.org/fedora:27
LABEL maintainer="Micah Abbott <miabbott@redhat.com>"
RUN dnf -y install lighttpd && \
    dnf clean all
EXPOSE 80
ENTRYPOINT ["/usr/sbin/lighttpd"]
CMD ["-D", "-f", "/etc/lighttpd/lighttpd.conf"]
