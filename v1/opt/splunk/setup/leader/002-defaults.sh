#!/usr/bin/bash -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../../../../lib/helpers.sh
source /etc/environment
# logging-config defaults
etcd-set /splunk/config/label-index "index"
etcd-set /splunk/config/label-type "type"
etcd-set /splunk/config/label-sourcetype "source_type"
etcd-set /splunk/config/label-volume "volume"
etcd-set /splunk/config/heavyforwarder-endpoint "http://localhost:8089"
etcd-set /splunk/config/heavyforwarder-auth "admin:changeme"
etcd-set /splunk/config/heavyforwarder/restart 1
etcd-set /splunk/config/heavyforwarder/restarthour 0
etcd-set /splunk/config/logging-config/poller-frequency 10
etcd-set /splunk/config/logging-config/enable 0
# secops defaults
etcd-set /splunk/config/secops/enable-forwarder 0
etcd-set /splunk/config/secops/forwarder-server-list ""
etcd-set /splunk/config/secops/sslpassword ""
etcd-set /splunk/config/secops/forwarder-cert ""
etcd-set /splunk/config/secops/ca-cert ""
etcd-set /splunk/config/secops/index "os"
etcd-set /splunk/config/secops/sourcetype "syslog"
etcd-set /splunk/config/secops/rootca-format "pem"
etcd-set /splunk/config/secops/certpath-format "crt"
# cloudops defaults
etcd-set /splunk/config/cloudops/enable-forwarder 0
etcd-set /splunk/config/cloudops/forwarder-cert ""
etcd-set /splunk/config/cloudops/ca-cert ""
etcd-set /splunk/config/cloudops/forwarder-server-list ""
etcd-set /splunk/config/cloudops/hvc-endpoint ""
etcd-set /splunk/config/cloudops/lvc-endpoint ""
etcd-set /splunk/config/cloudops/sslpassword ""
etcd-set /splunk/config/cloudops/index "ethos-sandbox-ue1"
etcd-set /splunk/config/cloudops/sourcetype "journald"
etcd-set /splunk/config/cloudops/rootca-format "crt"
etcd-set /splunk/config/cloudops/certpath-format "crt"
# hec defaults
etcd-set /splunk/config/hec/enable-forwarder 0
etcd-set /splunk/config/hec/endpoint ""
etcd-set /splunk/config/hec/token ""
etcd-set /splunk/config/hec/default-index ""
# forwarder defaults
etcd-set /splunk/config/heavyforwarder/fluentd-proxy 0
etcd-set /splunk/config/heavyforwarder/journald-proxy 0
etcd-set /splunk/config/heavyforwarder/fluentd-token "ethos"
etcd-set /splunk/config/heavyforwarder/system-token "system"
etcd-set /splunk/config/heavyforwarder/default-port 9997
etcd-set /splunk/config/heavyforwarder/proxy-port 9998
etcd-set /splunk/config/universalforwarder/cloudops-port 1515
etcd-set /splunk/config/universalforwarder/secops-port 1514
etcd-set /splunk/config/universalforwarder/restart 1
etcd-set /splunk/config/universalforwarder/restarthour 0
# Log scrubbing variables
etcd-set /splunk/config/syslog-scrub-regex "s/\(-e\ [^=]*\)=[^\ ]*/\1=****** /g"
etcd-set /splunk/config/scrub-syslog 1
etcd-set /splunk/config/heavyforwarder/scrub-syslog 0
# make logging elb availible to etcd
etcd-set /environment/LOGGING_ELB $FLUENTD_INTERNAL_ELB
