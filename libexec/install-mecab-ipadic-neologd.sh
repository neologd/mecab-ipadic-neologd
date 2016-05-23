#!/usr/bin/env bash

# Copyright (C) 2015-2016 Toshinori Sato (@overlast)
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

set -e
set -u


BASEDIR=$(cd $(dirname $0);pwd)
ECHO_PREFIX="[install-mecab-ipadic-NEologd] :"

echo "$ECHO_PREFIX Start.."

YMD=`ls -ltr \`find ${BASEDIR}/../seed/mecab-user-dict-seed.*.csv.xz\` | egrep -o '[0-9]{8}' | tail -1`
if [ ! -e ${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD} ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD} isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/make-mecab-ipadic-neologd.sh first."
    exit 1
fi

BUILT_DIC_DIR=${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD}

: "set mecab path" && {
    set +u > /dev/null
    if [ -z "${MECAB_PATH}" ] ; then
        MECAB_PATH=`which mecab`
    fi
    if [ -z "${MECAB_DIC_DIR}" ] ; then
        MECAB_CONFIG_PATH=`which mecab-config`
        MECAB_DIC_DIR=`${MECAB_CONFIG_PATH} --dicdir`
    fi
    set -u > /dev/null
}
INSTALL_DIR_PATH=${MECAB_DIC_DIR}/mecab-ipadic-neologd
INSTALL_AS_USER=0

while getopts p:u: OPT
do
  case $OPT in
    "p" ) INSTALL_DIR_PATH=$OPTARG ;;
    "u" ) INSTALL_AS_USER=$OPTARG ;;
  esac
done

cd ${BUILT_DIC_DIR}

if [ ${INSTALL_AS_USER} = 1 ]; then
    echo "$ECHO_PREFIX Make install to ${INSTALL_DIR_PATH}"
    make install
else
    echo "$ECHO_PREFIX Sudo make install to ${INSTALL_DIR_PATH}"
    sudo make install
fi

if [ -e ${INSTALL_DIR_PATH} ]; then
    echo ""
    echo "${ECHO_PREFIX} Install completed."
    echo "${ECHO_PREFIX} When you use MeCab, you can set '${INSTALL_DIR_PATH}' as a value of '-d' option of MeCab."
    echo "${ECHO_PREFIX} Usage of mecab-ipadic-NEologd is here."
    echo "Usage:"
    echo "    $ mecab -d ${INSTALL_DIR_PATH} ..."
    echo ""
else
    echo "${ECHO_PREFIX} ${INSTALL_DIR_PATH} can't be found. Install Failed."
fi

echo "$ECHO_PREFIX Finish.."
