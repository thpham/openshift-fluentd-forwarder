oc-3.7 project logging
oc-3.7 apply -f fluentd-forwarder-centos-build-config-template.yaml
oc-3.7 process fluentd-forwarder-centos-build | oc-3.7 apply -f -

oc-3.7 set env bc/fluentd-forwarder-centos USE_SYSTEM_REPOS=1
oc-3.7 start-build fluentd-forwarder-centos --follow=true


oc-3.7 process -f fluentd-forwarder-template.yaml \
-p "P_IMAGE_NAME=fluentd-forwarder-centos" \
-p "P_TARGET_TYPE=splunk_ex" \
-p "P_TARGET_HOST=10.30.27.72" \
-p "P_TARGET_PORT=9997" \
-p "P_SHARED_KEY=ocpaggregatedloggingsharedkey" \
-p "P_ADDITIONAL_OPTS=output_format json" | oc-3.7 create -f -

oc-3.7 rollout latest dc/fluentd-forwarder



ansible-playbook -i /root/tools/openshift/hosts /root/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml


oc project logging
oc apply -f fluentd-forwarder-build-config-template.yaml
oc process fluentd-forwarder-build | oc apply -f -

oc set env bc/fluentd-forwarder USE_SYSTEM_REPOS=1
oc start-build fluentd-forwarder --follow=true


oc process -f fluentd-forwarder-template.yaml \
-p "P_TARGET_TYPE=splunk_ex" \
-p "P_TARGET_HOST=10.30.27.72" \
-p "P_TARGET_PORT=9997" \
-p "P_SHARED_KEY=ocpaggregatedloggingsharedkey" \
-p "P_ADDITIONAL_OPTS=output_format json" | oc create -f -

oc rollout latest dc/fluentd-forwarder


```yaml
apiVersion: v1
data:
  secure-forward.conf: |
    @type secure_forward

    self_hostname ${HOSTNAME}
    shared_key ocpaggregatedloggingsharedkey

    secure yes
    enable_strict_verification yes

    ca_cert_path /var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt

    <server>
      host fluentd-forwarder.logging.svc.cluster.local
      port 24284
    </server>
```


Backup of:

```yaml
apiVersion: v1
data:
  secure-forward.conf: |
    # @type secure_forward

    # self_hostname ${HOSTNAME}
    # shared_key <SECRET_STRING>

    # secure yes
    # enable_strict_verification yes

    # ca_cert_path /etc/fluent/keys/your_ca_cert
    # ca_private_key_path /etc/fluent/keys/your_private_key
      # for private CA secret key
    # ca_private_key_passphrase passphrase

    # <server>
      # or IP
    #   host server.fqdn.example.com
    #   port 24284
    # </server>
    # <server>
      # ip address to connect
    #   host 203.0.113.8
      # specify hostlabel for FQDN verification if ipaddress is used for host
    #   hostlabel server.fqdn.example.com
    # </server>
```
