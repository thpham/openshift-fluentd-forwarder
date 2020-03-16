#!/bin/bash

# get release version
RELEASE=$(cat /etc/redhat-release)
YUM_ARGS="--setopt=tsflags=nodocs"

# clean up yum to make sure image isn't larger because of installations/updates
yum clean all
rm -rf /var/cache/yum/*
rm -rf /var/lib/yum/*

# set home directory
mkdir -p ${HOME} && \

# install gems for target version of fluentd, eventually
# update to fluentd version that matches version deployed
# into openshift
gem install -N --conservative --minimal-deps --no-document \
  'fluentd:~>1.4' \
  'activesupport:>=2.5.0' \
  'public_suffix:<3.0.0' \
  'fluent-plugin-record-modifier:<1.0.0' \
  'fluent-plugin-rewrite-tag-filter' \
  'fluent-plugin-kubernetes_metadata_filter:2.1.2' \
  fluent-plugin-rewrite-tag-filter \
  fluent-plugin-secure-forward \
  'fluent-plugin-remote_syslog:<1.0.0' \
  fluent-plugin-splunk-hec

gem uninstall fluentd -v 1.8.1

# set up directores so that group 0 can have access like specified in
# https://docs.openshift.com/container-platform/3.7/creating_images/guidelines.html
# https://docs.openshift.com/container-platform/3.7/creating_images/guidelines.html#openshift-specific-guidelines
mkdir -p /etc/fluent
chgrp -R 0 /etc/fluent
chmod -R g+rwX /etc/fluent
chgrp -R 0 ${HOME}
chmod -R g+rwX ${HOME}
chgrp -R 0 /etc/pki
chmod -R g+rwX /etc/pki
mkdir /secrets
chgrp -R 0 /secrets
chmod -R g+rwX /secrets
chgrp -R 0 /var/log
chmod -R g+rwX /var/log