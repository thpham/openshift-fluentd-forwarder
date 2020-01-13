# start based on a centos image
FROM rhel7

ENV HOME=/opt/app-root/src \
  PATH=/opt/rh/rh-ruby25/root/usr/local/bin:/opt/rh/rh-ruby25/root/usr/bin:/opt/app-root/src/bin:/opt/app-root/bin${PATH:+:${PATH}} \
  LD_LIBRARY_PATH=/opt/rh/rh-ruby25/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} \
  MANPATH=/opt/rh/rh-ruby25/root/usr/share/man:$MANPATH \
  PKG_CONFIG_PATH=/opt/rh/rh-ruby25/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}} \
  XDG_DATA_DIRS=/opt/rh/rh-ruby25/root/usr/share${XDG_DATA_DIRS:+:${XDG_DATA_DIRS}} \
  RUBY_VERSION=2.5 \
  FLUENTD_VERSION=0.12.32 \
  GEM_HOME=/opt/app-root/src \
  DATA_VERSION=1.6.0 \
  TARGET_TYPE=remote_syslog \
  TARGET_HOST=localhost \
  TARGET_PORT=24284 \
  IS_SECURE=yes \
  STRICT_VERIFICATION=yes \
  CA_PATH=/etc/pki/CA/certs/ca.crt \
  CERT_PATH=/etc/pki/tls/certs/local.crt \
  KEY_PATH=/etc/pki/tls/private/local.key \
  KEY_PASSPHRASE= \
  SHARED_KEY=ocpaggregatedloggingsharedkey

LABEL io.k8s.description="Fluentd container for collecting logs from other fluentd instances" \
  io.k8s.display-name="Fluentd Forwarder (${FLUENTD_VERSION})" \
  io.openshift.expose-services="24284:tcp" \
  io.openshift.tags="logging,fluentd,forwarder" \
  name="fluentd-forwarder" \
  architecture=x86_64

RUN yum install -y yum-utils && \
    YUM_OPTS="--setopt=tsflags=nodocs --enablerepo=rhel-7-server-rpms --enablerepo=rhel-server-rhscl-7-rpms --enablerepo=rhel-7-server-optional-rpms" && \
    INSTALL_PKGS="gcc gcc-c++ libcurl-devel make bc gettext hostname iproute" && \
    yum install -y $YUM_OPTS $INSTALL_PKGS && rpm -V $INSTALL_PKGS


RUN INSTALL_RUBY="nss_wrapper rh-ruby25 rh-ruby25-ruby-devel rh-ruby25-rubygem-rake rh-ruby25-rubygem-bundler" && \
    YUM_OPTS="--setopt=tsflags=nodocs --enablerepo=rhel-7-server-rpms --enablerepo=rhel-server-rhscl-7-rpms --enablerepo=rhel-7-server-optional-rpms" && \
    yum install -y $YUM_OPTS $INSTALL_RUBY && rpm -V $INSTALL_RUBY && \
    yum -y clean all --enablerepo='*'

# add files
ADD run.sh fluentd.conf.template passwd.template fluentd-check.sh ${HOME}/
ADD common-*.sh /tmp/

# set permissions on files
RUN chmod g+rx ${HOME}/fluentd-check.sh && \
    chmod +x /tmp/common-*.sh

# execute files and remove when done
RUN /tmp/common-install.sh && \
    rm -f /tmp/common-*.sh

# set working dir
WORKDIR ${HOME}

# external port
EXPOSE 24284

CMD ["sh", "run.sh"]
