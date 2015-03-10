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
ECHO_PREFIX="[install-mecab-ipadic-neologd] :"

echo "$ECHO_PREFIX Start.."

YMD=`ls -c \`find ${BASEDIR}/../seed/mecab-user-dict-seed.*.csv.xz\` | head -1 | egrep -o '[0-9]{8}' | tail -1`
if [ ! -e ${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD} ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD} isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/make-mecab-ipadic-neologd.sh first."
    exit
fi

BUILT_DIC_DIR=${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD}

MECAB_PATH=`which mecab`
MECAB_DIC_DIR=`${MECAB_PATH}-config --dicdir`
INSTALL_DIR_PATH=${MECAB_DIC_DIR}/mecab-ipadic-neologd

echo "$ECHO_PREFIX Sudo make install to ${INSTALL_DIR_PATH}"
cd ${BUILT_DIC_DIR}
sudo make install

if [ -e ${MECAB_DIC_DIR} ]; then
    echo ""
    echo "${ECHO_PREFIX} Install completed."
    echo "${ECHO_PREFIX} When you use MeCab, you can set '${INSTALL_DIR_PATH}' as a value of '-d' option of MeCab."
    echo "${ECHO_PREFIX} Usage of mecab-ipadic-neologd is here."
    echo "Usage:"
    echo "    $ mecab -d ${INSTALL_DIR_PATH} ..."
    echo ""
else
    echo "${ECHO_PREFIX} ${MECAB_DIC_DIR} can't be found. Install Failed."
fi

echo "$ECHO_PREFIX Finish.."
