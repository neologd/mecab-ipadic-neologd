#!/usr/bin/env bash

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

echo "$ECHO_PREFIX Sodo make install to ${INSTALL_DIR_PATH}"
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
