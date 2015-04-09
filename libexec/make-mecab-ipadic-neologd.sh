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
    exit 1;
fi

echo "$ECHO_PREFIX Check local seed file"

YMD=`find ${BASEDIR}/../seed/mecab-user-dict-seed.*.csv.xz | egrep -o '[0-9]{8}' | tail -1`
if [ ! -e ${BASEDIR}/../seed/mecab-user-dict-seed.${YMD}.csv.xz ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/mecab-user-dict-seed.${YMD}.csv.xz isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/copy-dict-seed.sh first."
    exit 2;
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
    if [ "$?" != "0" ]; then
	echo "Failed to download $ORG_DIC_NAME, check your network/proxy."
	exit 3;
    fi
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

MIN_SURFACE_LEN=0
MAX_SURFACE_LEN=0
MIN_BASEFORM_LEN=0
MAX_BASEFORM_LEN=0
WANNA_CREATE_USER_DIC=0
while getopts p:s:l:S:L:u: OPT
do
  case $OPT in
    "p" ) INSTALL_DIR_PATH=$OPTARG ;;
    "s" ) MIN_SURFACE_LEN=$OPTARG ;;
    "l" ) MAX_SURFACE_LEN=$OPTARG ;;
    "S" ) MIN_BASEFORM_LEN=$OPTARG ;;
    "L" ) MAX_BASEFORM_LEN=$OPTARG ;;
    "u" ) WANNA_CREATE_USER_DIC=$OPTARG ;;
  esac
done

LIBS=-liconv ./configure --prefix=${INSTALL_DIR_PATH} --with-charset=utf8

echo "${ECHO_PREFIX} Encode the character encoding of system dictionary resources from EUC_JP to UTF-8"
sed -i -e "s|${MECAB_DIC_DIR}/ipadic|${INSTALL_DIR_PATH}|p" ${NEOLOGD_DIC_DIR}/Makefile

find . -type f | xargs file | grep ".csv" | cut -d: -f1 | xargs -t -I{} ./../../libexec/iconv_euc_to_utf8.sh {}
find . -type f | xargs file | grep ".csv" | grep -v ".utf8" | cut -d: -f1 | xargs -t -I{} rm {}
find . -type f | xargs file | grep ".def" | cut -d: -f1 | xargs -t -I{} ./../../libexec/iconv_euc_to_utf8.sh {}
find . -type f | xargs file | grep ".def" | grep -v ".utf8" | cut -d: -f1 | xargs -t -I{} rm {}
find . -type f | xargs file | grep  ".utf8" | cut -d: -f1 |  sed -e "s|.utf8||" |  xargs -t -I{} mv {}.utf8 {}

echo "${ECHO_PREFIX} Copy user dictionary resource"
SEED_FILE_NAME=mecab-user-dict-seed.${YMD}.csv
cp ${BASEDIR}/../seed/${SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
unxz ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.xz

if [ ${MIN_SURFACE_LEN} -gt 0 -o ${MAX_SURFACE_LEN} -gt 0 ]; then
    if [ ${MIN_SURFACE_LEN} -gt 0 ]; then
        echo "${ECHO_PREFIX} Delete the entries whose length of surface is shorter than ${MIN_SURFACE_LEN} from seed file"
        cat ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME} | perl -ne "use Encode;my \$l=\$_;my @a=split /,/,\$l;\$len=length Encode::decode_utf8(\$a[0]);print \$l if(\$len >= ${MIN_SURFACE_LEN});" > ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.tmp
        mv ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.tmp ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}
    fi
    if [ ${MAX_SURFACE_LEN} -gt 0 ]; then
        echo "${ECHO_PREFIX} Delete the entries whose length of surface is longer than ${MAX_SURFACE_LEN} from seed file"
        cat ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME} | perl -ne "use Encode;my \$l=\$_;my @a=split /,/,\$l;\$len=length Encode::decode_utf8(\$a[0]);print \$l if(\$len <= ${MAX_SURFACE_LEN});" > ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.tmp
        mv ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.tmp ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}
    fi
fi
if [ ${MIN_BASEFORM_LEN} -gt 0 -o ${MAX_BASEFORM_LEN} -gt 0 ]; then
    if [ ${MIN_BASEFORM_LEN} -gt 0 ]; then
        echo "${ECHO_PREFIX} Delete the entries whose length of base form is shorter than ${MIN_BASEFORM_LEN} from seed file"
        cat ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME} | perl -ne "use Encode;my \$l=\$_;my @a=split /,/,\$l;\$len=length Encode::decode_utf8(\$a[10]);print \$l if(\$len >= ${MIN_BASEFORM_LEN});" > ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.tmp
        mv ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.tmp ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}
    fi
    if [ ${MAX_BASEFORM_LEN} -gt 0 ]; then
        echo "${ECHO_PREFIX} Delete the entries whose length of base form is longer than ${MAX_BASEFORM_LEN} from seed file"
        cat ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME} | perl -ne "use Encode;my \$l=\$_;my @a=split /,/,\$l;\$len=length Encode::decode_utf8(\$a[10]);print \$l if(\$len <= ${MAX_BASEFORM_LEN});" > ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.tmp
        mv ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.tmp ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}
    fi
fi

if [ ${WANNA_CREATE_USER_DIC} = 1 ]; then
    echo "${ECHO_PREFIX} Create the user dictionary using ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}"
    echo "${MECAB_LIBEXEC_DIR}/mecab-dict-index -f UTF8 -t UTF8 -d ${MECAB_DIC_DIR}/ipadic -u ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.dic ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}"
    ${MECAB_LIBEXEC_DIR}/mecab-dict-index -f UTF8 -t UTF8 -d ${MECAB_DIC_DIR}/ipadic -u ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.dic ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}
    if [ -f ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.dic ]; then
        echo "${ECHO_PREFIX} Success to create the user dictionary"
        echo
        echo "${ECHO_PREFIX} User dictionaty is here : ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.dic"
        echo
    else
        echo "${ECHO_PREFIX} Fail to create the user dictionary"
    fi
fi

echo "${ECHO_PREFIX} Re-Index system dictionary"
${MECAB_LIBEXEC_DIR}/mecab-dict-index -f UTF8 -t UTF8

echo "${ECHO_PREFIX} Make custom system dictionary on ${BASEDIR}/../build/${NEOLOGD_DIC_NAME}"
make

echo "$ECHO_PREFIX Finish.."
