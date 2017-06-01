#!/bin/bash

# root
#if [ "${HOME}" == "/root" ]; then
#    echo -e "Not supported ROOT."
#    exit 1
#fi

# linux
OS_NAME=$(uname)
if [ "${OS_NAME}" == "Linux" ]; then
    OS_FULL=$(uname -a)
    if [ $(echo "${OS_FULL}" | grep -c "amzn1") -gt 0 ]; then
        OS_TYPE="amzn1"
    elif [ $(echo "${OS_FULL}" | grep -c "el6") -gt 0 ]; then
        OS_TYPE="el6"
    elif [ $(echo "${OS_FULL}" | grep -c "el7") -gt 0 ]; then
        OS_TYPE="el7"
    elif [ $(echo "${OS_FULL}" | grep -c "generic") -gt 0 ]; then
        OS_TYPE="generic"
    fi
else
    if [ "${OS_NAME}" == "Darwin" ]; then
        OS_TYPE="${OS_NAME}"
    fi
fi

if [ "${OS_TYPE}" == "" ]; then
    uname -a
    echo -e "Not supported OS. [${OS_NAME}][${OS_TYPE}]"
    exit 1
fi

REPO="http://toast.sh"

################################################################################

pushd "${HOME}"

# version
wget -q -N -P /tmp ${REPO}/toaster.txt

if [ ! -f /tmp/toaster.txt ]; then
    echo -e "Can not download. [version]"
    exit 1
fi

if [ -f toaster/.version.txt ]; then
    NEW="$(cat /tmp/toaster.txt)"
    OLD="$(cat toaster/.version.txt)"

    if [ "${NEW}" == "${OLD}" ]; then
        echo -e "Already have latest version. [${OLD}]"
        exit 0
    fi

    MSG="Latest version updated. [${OLD} -> ${NEW}]"
else
    MSG="Toast.sh installed."
fi

# download
wget -q -N -P /tmp "${REPO}/toaster.zip"

if [ ! -f /tmp/toaster.zip ]; then
    echo -e "Can not download. [toast.sh]"
    exit 1
fi

# unzip
unzip -q -o /tmp/toaster.zip -d toaster

# cp version
cp -rf /tmp/toaster.txt toaster/.version.txt

popd

# done
echo -e "${MSG}"
