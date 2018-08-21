#!/bin/bash

increment_version() {
    local v=$1
    if [ -z $2 ]; then
        local rgx='^((?:[0-9]+\.)*)([0-9]+)($)'
    else
        local rgx='^((?:[0-9]+\.){'$(($2-1))'})([0-9]+)(\.|$)'
        for (( p=`grep -o "\."<<<".$v"|wc -l`; p<$2; p++)); do
        v+=.0; done; fi
    val=$(echo -e "$v" | perl -pe 's/^.*'$rgx'.*$/$2/')
    echo "$v" | perl -pe s/$rgx.*$'/${1}'`printf %0${#val}s $(($val+1))`/
}

mkdir -p build
mkdir -p target

VERSION="$(cat VERSION | perl -pe 's/^((\d+\.)*)(\d+)(.*)$/$1.($3+1).$4/e')"

echo "VERSION=${VERSION}"

# toaster.txt
printf "${VERSION}" > VERSION
printf "${VERSION}" > target/toaster.txt

# 755
find ./** | grep [.]sh | xargs chmod 755

# draft
cp -rf draft.sh target/draft
pushd draft/
tar -czf ../target/draft.tar.gz *
popd

# helper
cp -rf helper build/
cp -rf helper target/

# web
cp -rf web/* target/

# install.sh
cp -rf install.sh target/install

# toast.sh
cp -rf toast.sh build/toast

# build
pushd build/
tar -czf ../target/toaster.tar.gz *
popd

ls -al build
ls -al target
