#!/bin/bash

# curl -sL toast.sh/draft | bash

REPO="repo.toast.sh"

ANSWER=

OS_NAME="$(uname | awk '{print tolower($0)}')"

################################################################################

question() {
    read -p "$(tput setaf 6)$@$(tput sgr0)" ANSWER
}

title() {
    echo -e "$(tput setaf 3)$@$(tput sgr0)"
}

success() {
    echo -e "$(tput setaf 2)$@$(tput sgr0)"
    exit 0
}

error() {
    echo -e "$(tput setaf 1)$@$(tput sgr0)"
    exit 1
}

usage() {
    VER=$(curl -sL toast.sh/toaster.txt)

    #figlet draft init
    echo "================================================================================"
    echo "     _            __ _     _       _ _ "
    echo "  __| |_ __ __ _ / _| |_  (_)_ __ (_) |_ "
    echo " / _' | '__/ _' | |_| __| | | '_ \| | __| "
    echo "| (_| | | | (_| |  _| |_  | | | | | | |_ "
    echo " \__,_|_|  \__,_|_|  \__| |_|_| |_|_|\__|  (${VER}) "
    echo "================================================================================"

    exit 1
}

################################################################################

if [ ! -f Dockerfile ]; then
    error "File not found. [Dockerfile]"
fi

if [ -f draft.toml ]; then
    question "Are you sure? (YES/[no]) : "

    if [ "${ANSWER}" == "YES" ]; then
        exit 0
    fi
fi

mkdir -p charts/acme/templates

DIST=/tmp/draft.tar.gz

# download
curl -sL -o ${DIST} ${REPO}/draft.tar.gz

if [ ! -f ${DIST} ]; then
    error "Can not download. [${REPO}]"
fi

# untar
tar -zxf ${DIST} ${TMP}

mv -f dockerignore .dockerignore
mv -f draftignore .draftignore
