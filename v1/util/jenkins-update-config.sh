#!/usr/bin/bash -x

JENKINS_DIRECTORY=$1

USAGE_MESSAGE="Control Jenkins: Please provide the Jenkins home directory"

if [[ ! $1 ]]; then
  echo "$USAGE_MESSAGE"
  exit 1;
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../lib/helpers.sh

CONTROL_JENKINS_OKTA_METADATA=$(etcd-get /jenkins/config/okta/metadata)
CONTROL_JENKINS_GIT_URL=$(etcd-get /jenkins/config/git/url)
CONTROL_JENKINS_GIT_API_URL=$(etcd-get /jenkins/config/git/api-url)
CONTROL_JENKINS_GIT_CLIENT_ID=$(etcd-get /jenkins/config/git/client-id)
CONTROL_JENKINS_GIT_CLIENT_SECRET=$(etcd-get /jenkins/config/git/client-secret)
CONTROL_JENKINS_GIT_SCOPES=$(etcd-get /jenkins/config/git/scopes)

if [[ -n "$CONTROL_JENKINS_GIT_URL" && -n "$CONTROL_JENKINS_GIT_API_URL" && -n "$CONTROL_JENKINS_GIT_CLIENT_ID" && "$CONTROL_JENKINS_GIT_CLIENT_SECRET" && -n "$CONTROL_JENKINS_GIT_SCOPES" ]]; then
  CONTROL_JENKINS_ADMIN_GROUP=$(etcd-get /jenkins/config/git/admin-group)
  CONTROL_JENKINS_RO_GROUP=$(etcd-get /jenkins/config/git/read-group)

  # use the secure Jenkins config
  mv -f $JENKINS_DIRECTORY/config-github.xml $JENKINS_DIRECTORY/config.xml

  # replace the admin group
  if [[ -n $CONTROL_JENKINS_ADMIN_GROUP ]]; then
    sed -i "s/\[CONTROL_JENKINS_ADMIN_GROUP\]/${CONTROL_JENKINS_ADMIN_GROUP}/g" $JENKINS_DIRECTORY/config.xml
  else
    sed -i "/\[CONTROL_JENKINS_ADMIN_GROUP\]/d" $JENKINS_DIRECTORY/config.xml
  fi

  # replace the read only group
  if [[ -n $CONTROL_JENKINS_ADMIN_GROUP ]]; then
    sed -i "s/\[CONTROL_JENKINS_RO_GROUP\]/${CONTROL_JENKINS_RO_GROUP}/g" $JENKINS_DIRECTORY/config.xml
  else
    sed -i "/\[CONTROL_JENKINS_RO_GROUP\]/d" $JENKINS_DIRECTORY/config.xml
  fi

  sed -i "s/\[CONTROL_JENKINS_GIT_URL\]/${CONTROL_JENKINS_GIT_URL}/g" $JENKINS_DIRECTORY/config.xml
  sed -i "s/\[CONTROL_JENKINS_GIT_API_URL\]/${CONTROL_JENKINS_GIT_API_URL}/g" $JENKINS_DIRECTORY/config.xml
  sed -i "s/\[CONTROL_JENKINS_GIT_CLIENT_ID\]/${CONTROL_JENKINS_GIT_CLIENT_ID}/g" $JENKINS_DIRECTORY/config.xml
  sed -i "s/\[CONTROL_JENKINS_GIT_CLIENT_SECRET\]/${CONTROL_JENKINS_GIT_CLIENT_SECRET}/g" $JENKINS_DIRECTORY/config.xml
  sed -i "s/\[CONTROL_JENKINS_GIT_SCOPES\]/${CONTROL_JENKINS_GIT_SCOPES}/g" $JENKINS_DIRECTORY/config.xml

  echo "Control Jenkins: Updated Git configuration"
elif [[ -n "$CONTROL_JENKINS_OKTA_METADATA" ]]; then
  CONTROL_JENKINS_ADMIN_GROUP=$(etcd-get /jenkins/config/okta/admin-group)
  CONTROL_JENKINS_RO_GROUP=$(etcd-get /jenkins/config/okta/read-group)

  # use the secure Jenkins config
  mv -f $JENKINS_DIRECTORY/config-secure.xml $JENKINS_DIRECTORY/config.xml

  # replace the admin group
  if [[ -n $CONTROL_JENKINS_ADMIN_GROUP ]]; then
    sed -i "s/\[CONTROL_JENKINS_ADMIN_GROUP\]/${CONTROL_JENKINS_ADMIN_GROUP}/g" $JENKINS_DIRECTORY/config.xml
  else
    sed -i "/\[CONTROL_JENKINS_ADMIN_GROUP\]/d" $JENKINS_DIRECTORY/config.xml
  fi

  # replace the read only group
  if [[ -n $CONTROL_JENKINS_ADMIN_GROUP ]]; then
    sed -i "s/\[CONTROL_JENKINS_RO_GROUP\]/${CONTROL_JENKINS_RO_GROUP}/g" $JENKINS_DIRECTORY/config.xml
  else
    sed -i "/\[CONTROL_JENKINS_RO_GROUP\]/d" $JENKINS_DIRECTORY/config.xml
  fi

  # decode from base64, encode the xml entities and escape awk special characters
  ESCAPED_DATA="$(echo "${CONTROL_JENKINS_OKTA_METADATA}" | base64 --decode | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g;' | sed -e 's/[\&]/\\\\&/g')"

  # replace the label with the sanitized text and save in tmp file
  awk -v r="${ESCAPED_DATA}" '{gsub(/\[CONTROL_JENKINS_OKTA_METADATA\]/,r); print $0}' $JENKINS_DIRECTORY/config.xml > /var/tmp/config.xml

  # replace the config file
  cp -f /var/tmp/config.xml $JENKINS_DIRECTORY/config.xml

  # remove temporary file
  rm -f /var/tmp/config.xml

  echo "Control Jenkins: Updated Okta configuration"
else
  echo "Control Jenkins: Using insecure configuration"
fi
