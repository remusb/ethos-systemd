#!/usr/bin/bash -x

source /etc/environment

# Source the etcd
if [ -f /etc/profile.d/etcdctl.sh ]; then
  source /etc/profile.d/etcdctl.sh;
fi

# Handle retrying of all etcd sets and gets
function etcd-set() {
    if [[ "$#" -gt 1 ]]; then
      /home/core/ethos-systemd/v1/lib/etcdauth.sh set "$@"
      while [ $? != 0 ]; do sleep 1; /home/core/ethos-systemd/v1/lib/etcdauth.sh set $@; done
    fi
}

function etcd-get() {
    /home/core/ethos-systemd/v1/lib/etcdauth.sh get "$@"
    # "0" and "4" responses were successful, "4" means the key intentionally doesn't exist
    while [[ $? != 0 && $? != 4 ]]; do sleep 1; /home/core/ethos-systemd/v1/lib/etcdauth.sh get $@; done
}

# Handle retrying of all fleet submits and starts
function submit-fleet-unit() {
    sudo fleetctl submit "$@"
    while [ $? != 0 ]; do sleep 1; sudo fleetctl submit $@; done
}

function start-fleet-unit() {
    sudo fleetctl start "$@"
    while [ $? != 0 ]; do sleep 1; sudo fleetctl start $@; done
}


#
# URI parsing function
#
# The function creates global variables with the parsed results.
# It returns 0 if parsing was successful or non-zero otherwise.
#
# [schema://][user[:password]@]host[:port][/path][?[arg1=val1]...][#fragment]
#
function uri_parser() {
    # uri capture
    uri="$@"

    # safe escaping
    uri="${uri//\`/%60}"
    uri="${uri//\"/%22}"

    # top level parsing
    pattern='^(([a-z]{3,5})://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]+)(:([0-9]+))?)(\/[^?]*)?(\?[^#]*)?(#.*)?$'
    [[ "$uri" =~ $pattern ]] || return 0;

    # component extraction
    uri=${BASH_REMATCH[0]}
    uri_schema=${BASH_REMATCH[2]}
    uri_address=${BASH_REMATCH[3]}
    uri_user=${BASH_REMATCH[5]}
    uri_password=${BASH_REMATCH[7]}
    uri_host=${BASH_REMATCH[8]}
    uri_port=${BASH_REMATCH[10]}
    uri_path=${BASH_REMATCH[11]}
    uri_query=${BASH_REMATCH[12]}
    uri_fragment=${BASH_REMATCH[13]}

    # path parsing
    count=0
    path="$uri_path"
    pattern='^/+([^/]+)'
    while [[ $path =~ $pattern ]]; do
        eval "uri_parts[$count]=\"${BASH_REMATCH[1]}\""
        path="${path:${#BASH_REMATCH[0]}}"
        let count++
    done

    # query parsing
    count=0
    query="$uri_query"
    pattern='^[?&]+([^= ]+)(=([^&]*))?'
    while [[ $query =~ $pattern ]]; do
        eval "uri_args[$count]=\"${BASH_REMATCH[1]}\""
        eval "uri_arg_${BASH_REMATCH[1]}=\"${BASH_REMATCH[3]}\""
        query="${query:${#BASH_REMATCH[0]}}"
        let count++
    done

    # return success
    return 0
}
