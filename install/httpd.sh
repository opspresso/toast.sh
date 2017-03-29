#!/bin/bash

echo_() {
    echo "$1"
    echo "$1" >> /tmp/toast.log
}

success() {
    echo -e "$(/usr/bin/tput setaf 2)$1$(/usr/bin/tput sgr0)"
    echo "$1" >> /tmp/toast.log
}

inform() {
    echo -e "$(/usr/bin/tput setaf 6)$1$(/usr/bin/tput sgr0)"
    echo "$1" >> /tmp/toast.log
}

warning() {
    echo -e "$(/usr/bin/tput setaf 1)$1$(/usr/bin/tput sgr0)"
    echo "$1" >> /tmp/toast.log
}

download() {
    _FILE="$1"
    _PATH="$2"

    if [ "${REPO}" != "" ]; then
        URL="${REPO}/${_PATH}/${_FILE}"

        echo_ "download... [${URL}]"

        /usr/bin/aws s3 cp ${URL} ./
    fi

    if [ ! -f ${_FILE} ]; then
        warning "Can not download : ${URL}"

        URL="http://repo.toast.sh/${_PATH}/${_FILE}"

        echo_ "download... [${URL}]"

        /usr/bin/wget -q -N ${URL}
    fi
}

################################################################################

OS_NAME=`uname`
if [ ${OS_NAME} != "Linux" ]; then
    warning "Not supported OS : ${OS_NAME}"
    exit 1
fi

SUDO=""
if [ "${HOME}" != "/root" ]; then
    SUDO="sudo"
fi

################################################################################

NAME="httpd"

VERSION="2.4.25"

FILE="${NAME}-${VERSION}"

EXT="tar.bz2"

# s3://repo.toast.sh/httpd/httpd-2.4.25.tar.bz2

################################################################################

REPO="$1"

download "${FILE}.${EXT}" "${NAME}"

if [ ! -f ${FILE}.${EXT} ]; then
    warning "Can not download : ${FILE}.${EXT}"
    exit 1
fi

################################################################################

tar xfp ${FILE}.${EXT}

pushd ${FILE}

./configure --prefix=/usr/local/php \
            --with-libdir=lib64 \
            --with-apxs2=/usr/local/apache/bin/apxs \
            --with-mysql=/usr/local/mariadb \
            --with-config-file-path=/usr/local/php/lib \
            --disable-debug \
            --enable-safe-mode \
            --enable-sockets \
            --enable-mod-charset \
            --enable-sysvsem=yes \
            --enable-sysvshm=yes \
            --enable-ftp \
            --enable-magic-quotes \
            --enable-gd-native-ttf \
            --enable-inline-optimization \
            --enable-bcmath \
            --enable-sigchild \
            --enable-mbstring \
            --enable-pcntl \
            --enable-shmop \
            --with-png-dir \
            --with-zlib \
            --with-jpeg-dir \
            --with-png-dir=/usr/lib \
            --with-freetype-dir=/usr \
            --with-libxml-dir=/usr \
            --enable-exif \
            --with-gd \
            --with-ttf \
            --with-gettext \
            --with-curl \
            --with-mcrypt \
            --with-mhash \
            --with-openssl \
            --with-xmlrpc \
            --with-xsl \
            --enable-maintainer-zts

make -s
${SUDO} make install

popd

rm -rf ${FILE}.${EXT}
rm -rf ${FILE}
