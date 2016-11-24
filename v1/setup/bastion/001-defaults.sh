#!/usr/bin/bash -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source /etc/environment
source $DIR/../../lib/helpers.sh

echo "-------Bastion node, beginning writing all default values to etcd-------"

######################
#     IMAGES
######################

# TODO: this overloads the machine

etcd-set /images/secrets-downloader     "index.docker.io/behance/docker-aws-secrets-downloader:v2.0.0"
etcd-set /images/klam-ssh               "index.docker.io/behance/klam-ssh:v1"

# Add any bastion-specific etcd keys here


######################
#      SERVICES
######################

etcd-set /environment/services "sumologic datadog"

echo "-------Bastion node, done writing all default values to etcd-------"
