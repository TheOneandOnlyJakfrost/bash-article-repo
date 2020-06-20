FROM registry.fedoraproject.org/fedora:32
LABEL com.coreos.toolbox=true
ADD build.sh /tmp
RUN /tmp/build.sh && rm -f /tmp/build.sh
