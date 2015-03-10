#!/usr/bin/env bash

# Copyright (C) 2015 Toshinori Sato (@overlast)
#
#       https://github.com/neologd/mecab-ipadic-neologd
#
# Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BASEDIR=$(cd $(dirname $0);pwd)
ECHO_PREFIX="[make-mecab-ipadic-neologd] :"

echo "$ECHO_PREFIX Start.."

echo "$ECHO_PREFIX Check local seed directory"
if [ ! -e ${BASEDIR}/../seed ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/copy-dict-seed.sh first."
    exit;
fi

echo "$ECHO_PREFIX Check local seed file"

YMD=`find ${BASEDIR}/../seed/mecab-user-dict-seed.*.csv.xz | egrep -o '[0-9]{8}' | tail -1`
if [ ! -e ${BASEDIR}/../seed/mecab-user-dict-seed.${YMD}.csv.xz ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/mecab-user-dict-seed.${YMD}.csv.xz isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/copy-dict-seed.sh first."
    exit;
fi

echo "$ECHO_PREFIX Check local build directory"
if [ ! -e ${BASEDIR}/../build ]; then
    echo "$ECHO_PREFIX create ${BASEDIR}/../build"
    mkdir -p ${BASEDIR}/../build
fi

echo "$ECHO_PREFIX Download original mecab-ipadic file"
cd ${BASEDIR}/../build

ORG_DIC_NAME=mecab-ipadic-2.7.0-20070801
NEOLOGD_DIC_NAME=mecab-ipadic-2.7.0-20070801-neologd-${YMD}
if [ ! -e ${BASEDIR}/../build/${ORG_DIC_NAME}.tar.gz ]; then
    curl -O "https://mecab.googlecode.com/files/${ORG_DIC_NAME}.tar.gz"
else
    echo "$ECHO_PREFIX Original mecab-ipadic file is already there."
fi

echo "$ECHO_PREFIX Decompress original mecab-ipadic file"

NEOLOGD_DIC_DIR=${BASEDIR}/../build/${NEOLOGD_DIC_NAME}
if [ -e ${NEOLOGD_DIC_DIR} ]; then
    echo "$ECHO_PREFIX Delete old ${NEOLOGD_DIC_NAME} directory"
    rm -rf ${NEOLOGD_DIC_DIR}
fi

tar xfvz ${BASEDIR}/../build/${ORG_DIC_NAME}.tar.gz -C ${BASEDIR}/../build/
mv ${BASEDIR}/../build/${ORG_DIC_NAME} ${NEOLOGD_DIC_NAME}

echo "${ECHO_PREFIX} Configure custom system dictionary on ${NEOLOGD_DIC_DIR}"

cd ${NEOLOGD_DIC_DIR}

MECAB_PATH=`which mecab`
MECAB_DIC_DIR=`${MECAB_PATH}-config --dicdir`
MECAB_LIBEXEC_DIR=`${MECAB_PATH}-config --libexecdir`
INSTALL_DIR_PATH=${MECAB_DIC_DIR}/mecab-ipadic-neologd

LIBS=-liconv ./configure --prefix=${INSTALL_DIR_PATH} --with-charset=utf8

echo "${ECHO_PREFIX} Encode the character encoding of system dictionary resources from EUC_JP to UTF-8"
sed -i -e "s|${MECAB_DIC_DIR}/ipadic|${INSTALL_DIR_PATH}|p" ${NEOLOGD_DIC_DIR}/Makefile

find ${NEOLOGD_DIC_DIR} -type f | xargs file | grep ".csv" | cut -d: -f1 | xargs -t -I{} ${BASEDIR}/../libexec/iconv_euc_to_utf8.sh {}
find ${NEOLOGD_DIC_DIR} -type f | xargs file | grep ".csv" | grep -v ".utf8" | cut -d: -f1 | xargs -t -I{} rm {}
find ${NEOLOGD_DIC_DIR} -type f | xargs file | grep ".def" | cut -d: -f1 | xargs -t -I{} ${BASEDIR}/../libexec/iconv_euc_to_utf8.sh {}
find ${NEOLOGD_DIC_DIR} -type f | xargs file | grep ".def" | grep -v ".utf8" | cut -d: -f1 | xargs -t -I{} rm {}
find ${NEOLOGD_DIC_DIR} -type f | xargs file | grep  ".utf8" | cut -d: -f1 |  sed -e "s|.utf8||" |  xargs -t -I{} mv {}.utf8 {}

echo "${ECHO_PREFIX} Copy user dictionary resource"
SEED_FILE_NAME=mecab-user-dict-seed.${YMD}.csv
cp ${BASEDIR}/../seed/${SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
unxz ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.xz

echo "${ECHO_PREFIX} Re-Index system dictionary"
${MECAB_LIBEXEC_DIR}/mecab-dict-index -f UTF8 -t UTF8

echo "${ECHO_PREFIX} Make custom system dictionary on ${BASEDIR}/../build/${NEOLOGD_DIC_NAME}"
make

echo "$ECHO_PREFIX Finish.."
