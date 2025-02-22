#!/bin/bash
set -e -x

arch=$(uname | tr '[:upper:]' '[:lower:]')
arch_set="arm64"

ver="6.5.0"
quiet="yes"

if [[ "${quiet}" == "yes" ]]; then
    CURL_QUIET="-q"
    lOG_TO_DEV_NULL="> /dev/null 2>&1"
fi

retry_curl="--retry 4 --retry-max-time 10 --retry-connrefused"
bazelroot="/usr/local/lib/bazel-${ver}"

set_bazel() {
    sudo ln -sf "${bazelroot}/bin/bazel" "/usr/local/bin/bazel"
    exit 0
}

if [[ -e "${bazelroot}/bin/bazel" ]]; then
    set_bazel
fi

filename="bazel-${ver}-installer-${arch}-${arch_set}.sh"
cmd="curl $CURL_QUIET -sLO $retry_curl https://storage.googleapis.com/bazel/${ver}/release/${filename}"

eval "$cmd"
sudo mkdir -p "${bazelroot}"
chmod 755 "${filename}"
command="sudo \"./${filename}\" \"--prefix=${bazelroot}\" $LOG_TO_DEV_NULL"
eval "$command"
rm -rf "${filename}"
set_bazel