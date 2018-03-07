#!/bin/bash

success() {
    echo -e "$1"
    exit 0
}

error() {
    echo -e "$1"
    exit 1
}

################################################################################

CONFIG="${HOME}/.toast"
if [ -f "${CONFIG}" ]; then
    source "${CONFIG}"
fi

REPO="http://repo.toast.sh"

################################################################################

mkdir -p ~/toaster

# version
curl -s -o /tmp/toaster.new ${REPO}/toaster-v2.txt

if [ ! -f /tmp/toaster.new ]; then
    error "Can not download. [${REPO}]"
fi

NEW="$(cat /tmp/toaster.new)"

if [ -f /tmp/toaster.old ]; then
    OLD="$(cat /tmp/toaster.old)"

    if [ "${NEW}" == "${OLD}" ]; then
        success "Already have latest version. [${NEW}]"
    fi

    MSG="Latest version updated. [${OLD} -> ${NEW}]"
else
    MSG="Toast.sh installed. [${NEW}]"
fi

# download
curl -s -o /tmp/toaster.tar.gz ${REPO}/toaster-v2.tar.gz

if [ ! -f /tmp/toaster.tar.gz ]; then
    error "Can not download. [${REPO}]"
fi

# install
tar -zxf /tmp/toaster.tar.gz -C ~/toaster

# cp version
cp -rf /tmp/toaster.new /tmp/toaster.old

# chmod 755
find ~/toaster/** | grep [.]sh | xargs chmod 755

# done
success "${MSG}"
