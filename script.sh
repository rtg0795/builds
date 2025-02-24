#!/bin/bash
set -e -x

arch=$(uname | tr '[:upper:]' '[:lower:]')
arch_set="arm64"

ver="6.5.0"

retry_curl="--retry 4 --retry-max-time 10 --retry-connrefused"
bazelroot="/usr/local/lib/bazel-${ver}"

set_bazel() {
    sudo ln -sf "${bazelroot}/bin/bazel" "/usr/local/bin/bazel"
    # exit 0
}

if [[ -e "${bazelroot}/bin/bazel" ]]; then
    set_bazel
fi

filename="bazel-${ver}-installer-${arch}-${arch_set}.sh"
cmd="curl -q -sLO $retry_curl https://storage.googleapis.com/bazel/${ver}/release/${filename}"

eval "$cmd"
sudo mkdir -p "${bazelroot}"
chmod 755 "${filename}"
command="sudo \"./${filename}\" \"--prefix=${bazelroot}\" $LOG_TO_DEV_NULL"
eval "$command"
rm -rf "${filename}"
set_bazel


export BUILD_ENV=/tmpfs/BUILD_ENV
mkdir -p ${BUILD_ENV}

JAVA_HOME=$(/usr/libexec/java_home -v21)
export JAVA_HOME
java -version

# pyenv
PYENV_ROOT="/Users/kbuilder/.pyenv"
cd "${PYENV_ROOT}" && git pull && cd -
eval "${pyenv init -}"

pyenv install -s 3.11.1
pyenv shell 3.11.1
PYTHON_BIN_PATH="/Users/kbuilder/.pyenv/versions/3.11.1/bin/python"
PIP_COMMAND="$(pyenv which pip)"
"${PYTHON_BIN_PATH} --version"
"${PIP_COMMAND} --version"

"${PYTHON_BIN_PATH}" -m venv "${BUILD_ENV}"
source "${BUILD_ENV}/bin/activate"

PYTHON_BIN_PATH=$(which python)
PIP_COMMAND=$(which pip)

"${PIP_COMMAND} install pip --upgrade --quiet"
export SETUPTOOLS_USE_DISUTILS=stdlib

install_targets+=("wheel==0.42.0")
install_targets+=("setuptools" "pipdeptree")
"${PIP_COMMAND}" install "${install_targets[@]}" --upgrade --quiet
"${PIP_COMMAND}" list