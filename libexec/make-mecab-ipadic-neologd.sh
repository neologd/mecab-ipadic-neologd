#!/usr/bin/env bash

# Copyright (C) 2015-2019 Toshinori Sato (@overlast)
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
ECHO_PREFIX="[make-mecab-ipadic-NEologd] :"
GREP_OPTIONS=""

echo "$ECHO_PREFIX Start.."

echo "$ECHO_PREFIX Check local seed directory"
if [ ! -e ${BASEDIR}/../seed ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/copy-dict-seed.sh first."
    exit 1;
fi

echo "$ECHO_PREFIX Check local seed file"

YMD=`ls -ltr \`find ${BASEDIR}/../seed/mecab-user-dict-seed.*.csv.xz\` | egrep -o '[0-9]{8}' | tail -1`
if [ ! -e ${BASEDIR}/../seed/mecab-user-dict-seed.${YMD}.csv.xz ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/mecab-user-dict-seed.${YMD}.csv.xz isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/copy-dict-seed.sh first."
    exit 1;
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
    STATUS_CODE=`curl --insecure -IL https://drive.google.com -s -w '%{http_code}\n' -o /dev/null`
    if [ ${STATUS_CODE} = 200 ]; then
        IS_NETWORK_ONLINE=1
    else
        echo "$ECHO_PREFIX Unable to access https://drive.google.com/"
        echo "$ECHO_PREFIX     Status code : ${STATUS_CODE}"
        echo "$ECHO_PREFIX Install error, please retry after re-connecting to network"
        exit 1
    fi

    ORG_DIC_URL_LIST=()
    # download from google drive
    ORG_DIC_URL_LIST[0]="https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM"
    # download from ja.osdn.net
    ORG_DIC_URL_LIST[1]="https://ja.osdn.net/frs/g_redir.php?m=kent&f=mecab%2Fmecab-ipadic%2F2.7.0-20070801%2F${ORG_DIC_NAME}.tar.gz"
    for (( I = 0; I < ${#ORG_DIC_URL_LIST[@]}; ++I ))
    do
        echo "$ECHO_PREFIX Try to download from ${ORG_DIC_URL_LIST[${I}]}"
        curl --insecure -L "${ORG_DIC_URL_LIST[${I}]}" -o "${ORG_DIC_NAME}.tar.gz"
        if [ $? != 0 ]; then
            echo ""
            echo "$ECHO_PREFIX Failed to download $ORG_DIC_NAME"
            echo "$ECHO_PREFIX Please check your network to download '${ORG_DIC_URL_LIST[${I}]}'"
            exit 1;
        elif [ `openssl sha1 ${BASEDIR}/../build/${ORG_DIC_NAME}.tar.gz | cut -d $' ' -f 2,2` == "0d9d021853ba4bb4adfa782ea450e55bfe1a229b" ]; then
            echo ""
            echo "Hash value of ${BASEDIR}/../build/${ORG_DIC_NAME}.tar.gz don't match"
            continue 1
        fi
    done
else
    echo "$ECHO_PREFIX Original mecab-ipadic file is already there."
fi

if [ `openssl sha1 ${BASEDIR}/../build/${ORG_DIC_NAME}.tar.gz | cut -d $' ' -f 2,2` != "0d9d021853ba4bb4adfa782ea450e55bfe1a229b" ]; then
    echo "$ECHO_PREFIX Fail to download ${BASEDIR}/../build/${ORG_DIC_NAME}.tar.gz"
    echo "$ECHO_PREFIX You should remove ${BASEDIR}/../build/${ORG_DIC_NAME}.tar.gz before retrying to install mecab-ipadic-NEologd"
    echo "$ECHO_PREFIX        rm -rf ${BASEDIR}/../build/${ORG_DIC_NAME}"
    echo "$ECHO_PREFIX        rm ${BASEDIR}/../build/${ORG_DIC_NAME}.tar.gz"
    exit 1
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
WANNA_IGNORE_ADVERB=0
WANNA_IGNORE_INTERJECT=0
WANNA_IGNORE_NOUN_ORTHO=0
WANNA_IGNORE_NOUN_SAHEN_CONN_ORTHO=0
WANNA_IGNORE_ADJECTIVE_STD=0
WANNA_INSTALL_ADJECTIVE_EXP=0
WANNA_IGNORE_ADJECTIVE_VERB=0
WANNA_ELIMINATE_REDUNDANT_ENTRY=0
COLUMN_EXTENSIONS_URLS=""
WANNA_INSTALL_INFREQ_DATETIME=0
WANNA_INSTALL_INFREQ_QUANTITY=0
WANNA_IGNORE_ILL_FORMED_WORDS=0
WANNA_INSTALL_ONLY_PATCHED_IPADIC=0
WANNA_INSRALL_ALL_SEED_FILES=0

while getopts :p:s:l:S:L:u:B:J:O:H:t:T:j:E:D:Q:I:c:a:G: OPT
do
  case $OPT in
    "p" ) INSTALL_DIR_PATH=$OPTARG ;;
    "s" ) MIN_SURFACE_LEN=$OPTARG ;;
    "l" ) MAX_SURFACE_LEN=$OPTARG ;;
    "S" ) MIN_BASEFORM_LEN=$OPTARG ;;
    "L" ) MAX_BASEFORM_LEN=$OPTARG ;;
    "u" ) WANNA_CREATE_USER_DIC=$OPTARG ;;
    "B" ) WANNA_IGNORE_ADVERB=$OPTARG ;;
    "J" ) WANNA_IGNORE_INTERJECT=$OPTARG ;;
    "O" ) WANNA_IGNORE_NOUN_ORTHO=$OPTARG ;;
    "H" ) WANNA_IGNORE_NOUN_SAHEN_CONN_ORTHO=$OPTARG ;;
    "t" ) WANNA_IGNORE_ADJECTIVE_STD=$OPTARG ;;
    "T" ) WANNA_INSTALL_ADJECTIVE_EXP=$OPTARG ;;
    "j" ) WANNA_IGNORE_ADJECTIVE_VERB=$OPTARG ;;
    "E" ) WANNA_ELIMINATE_REDUNDANT_ENTRY=$OPTARG ;;
    "D" ) WANNA_INSTALL_INFREQ_DATETIME=$OPTARG ;;
    "Q" ) WANNA_INSTALL_INFREQ_QUANTITY=$OPTARG ;;
    "I" ) WANNA_IGNORE_ILL_FORMED_WORDS=$OPTARG ;;
    "c" ) WANNA_INSTALL_ONLY_PATCHED_IPADIC=$OPTARG ;;
    "a" ) WANNA_INSRALL_ALL_SEED_FILES=$OPTARG ;;
    "G" ) COLUMN_EXTENSIONS_URLS=$OPTARG ;;
  esac
done

LIBS=-liconv ./configure --prefix=${INSTALL_DIR_PATH} --with-charset=utf8

echo "${ECHO_PREFIX} Encode the character encoding of system dictionary resources from EUC_JP to UTF-8"
sed -i -e "s|${MECAB_DIC_DIR}/ipadic\n|${INSTALL_DIR_PATH}\n|g" ${NEOLOGD_DIC_DIR}/Makefile

find . -type f | xargs file | grep ".csv" | cut -d: -f1 | xargs -t -I{} ./../../libexec/iconv_euc_to_utf8.sh {}
find . -type f | xargs file | grep ".csv" | grep -v ".utf8" | cut -d: -f1 | xargs -t -I{} rm {}
find . -type f | xargs file | grep ".def" | cut -d: -f1 | xargs -t -I{} ./../../libexec/iconv_euc_to_utf8.sh {}
find . -type f | xargs file | grep ".def" | grep -v ".utf8" | cut -d: -f1 | xargs -t -I{} rm {}
find . -type f | xargs file | grep  ".utf8" | cut -d: -f1 |  sed -e "s|.utf8||" |  xargs -t -I{} mv {}.utf8 {}

echo "${ECHO_PREFIX} Fix yomigana field of IPA dictionary"
patch < ${BASEDIR}/../misc/patch/Noun.csv.20160404.diff
patch < ${BASEDIR}/../misc/patch/Noun.place.csv.20150609.diff
patch < ${BASEDIR}/../misc/patch/Verb.csv.20150609.diff
patch < ${BASEDIR}/../misc/patch/Noun.verbal.csv.20150813.diff
patch < ${BASEDIR}/../misc/patch/Noun.name.csv.20150905.diff
patch < ${BASEDIR}/../misc/patch/Noun.adverbal.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Noun.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Noun.name.csv.20160421.diff
#patch < ${BASEDIR}/../misc/patch/Noun.number.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Noun.org.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Noun.others.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Noun.place.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Noun.proper.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Noun.verbal.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Prefix.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Suffix.csv.20160421.diff
#patch < ${BASEDIR}/../misc/patch/Symbol.csv.20160421.diff
patch < ${BASEDIR}/../misc/patch/Noun.proper.csv.20160519.diff
patch < ${BASEDIR}/../misc/patch/Noun.csv.20160923.diff
patch < ${BASEDIR}/../misc/patch/Noun.name.csv.20160923.diff
patch < ${BASEDIR}/../misc/patch/Noun.org.csv.20160923.diff
patch < ${BASEDIR}/../misc/patch/Noun.place.csv.20160923.diff
patch < ${BASEDIR}/../misc/patch/Noun.proper.csv.20160923.diff
patch < ${BASEDIR}/../misc/patch/Noun.verbal.csv.20160923.diff
patch < ${BASEDIR}/../misc/patch/Noun.name.csv.20161005.diff
patch < ${BASEDIR}/../misc/patch/Noun.org.csv.20161005.diff
patch < ${BASEDIR}/../misc/patch/Noun.place.csv.20161005.diff
patch < ${BASEDIR}/../misc/patch/Noun.proper.csv.20161005.diff
patch < ${BASEDIR}/../misc/patch/Suffix.csv.20161027.diff
patch < ${BASEDIR}/../misc/patch/Noun.demonst.csv.20170228.diff
patch < ${BASEDIR}/../misc/patch/Noun.csv.20170317.diff
patch < ${BASEDIR}/../misc/patch/Noun.name.csv.20170317.diff

echo "${ECHO_PREFIX} Copy user dictionary resource"
SEED_FILE_NAME=mecab-user-dict-seed.${YMD}.csv

if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
    cp ${BASEDIR}/../seed/${SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
    unxz ${NEOLOGD_DIC_DIR}/${SEED_FILE_NAME}.xz
fi

ADVERB_SEED_FILE_NAME=neologd-adverb-dict-seed.20150623.csv
if [ -f ${BASEDIR}/../seed/${ADVERB_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_IGNORE_ADVERB=0
    fi
    if [ ${WANNA_IGNORE_ADVERB} -gt 0 ]; then
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${ADVERB_SEED_FILE_NAME}.xz"
    else
        if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
            echo "${ECHO_PREFIX} Install adverb entries using ${BASEDIR}/../seed/${ADVERB_SEED_FILE_NAME}.xz"
            cp ${BASEDIR}/../seed/${ADVERB_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
            unxz ${NEOLOGD_DIC_DIR}/${ADVERB_SEED_FILE_NAME}.xz
        fi
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${ADVERB_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${ADVERB_SEED_FILE_NAME}"
fi

INTERJECT_SEED_FILE_NAME=neologd-interjection-dict-seed.20170216.csv
if [ -f ${BASEDIR}/../seed/${INTERJECT_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_IGNORE_INTERJECT=0
    fi
    if [ ${WANNA_IGNORE_INTERJECT} -gt 0 ]; then
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${INTERJECT_SEED_FILE_NAME}.xz"
    else
        if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
            echo "${ECHO_PREFIX} Install interjection entries using ${BASEDIR}/../seed/${INTERJECT_SEED_FILE_NAME}.xz"
            cp ${BASEDIR}/../seed/${INTERJECT_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
            unxz ${NEOLOGD_DIC_DIR}/${INTERJECT_SEED_FILE_NAME}.xz
        fi
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${INTERJECT_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${INTERJECT_SEED_FILE_NAME}"
fi

NOUN_ORTHO_SEED_FILE_NAME_LIST=()
NOUN_ORTHO_SEED_FILE_NAME_LIST[0]=neologd-common-noun-ortho-variant-dict-seed.20170228.csv
NOUN_ORTHO_SEED_FILE_NAME_LIST[1]=neologd-proper-noun-ortho-variant-dict-seed.20161110.csv
for (( I = 0; I < ${#NOUN_ORTHO_SEED_FILE_NAME_LIST[@]}; ++I ))
do
    NOUN_ORTHO_SEED_FILE_NAME=${NOUN_ORTHO_SEED_FILE_NAME_LIST[${I}]}
    if [ -f ${BASEDIR}/../seed/${NOUN_ORTHO_SEED_FILE_NAME}.xz ]; then
        if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
            WANNA_IGNORE_NOUN_ORTHO=0
        fi
        if [ ${WANNA_IGNORE_NOUN_ORTHO} -gt 0 ]; then
            echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${NOUN_ORTHO_SEED_FILE_NAME}.xz"
        else
            if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
                echo "${ECHO_PREFIX} Install noun orthographic variant entries using ${BASEDIR}/../seed/${NOUN_ORTHO_SEED_FILE_NAME}.xz"
                cp ${BASEDIR}/../seed/${NOUN_ORTHO_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
                unxz ${NEOLOGD_DIC_DIR}/${NOUN_ORTHO_SEED_FILE_NAME}.xz
            fi
        fi
    else
        echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${NOUN_ORTHO_SEED_FILE_NAME} isn't there"
        echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${NOUN_ORTHO_SEED_FILE_NAME}"
    fi
done

NOUN_SAHEN_CONN_ORTHO_SEED_FILE_NAME=neologd-noun-sahen-conn-ortho-variant-dict-seed.20160323.csv
if [ -f ${BASEDIR}/../seed/${NOUN_SAHEN_CONN_ORTHO_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_IGNORE_NOUN_SAHEN_CONN_ORTHO=0
    fi
    if [ ${WANNA_IGNORE_NOUN_SAHEN_CONN_ORTHO} -gt 0 ]; then
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${NOUN_SAHEN_CONN_ORTHO_SEED_FILE_NAME}.xz"
    else
        if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
            echo "${ECHO_PREFIX} Install entries of orthographic variant of a noun used as verb form using ${BASEDIR}/../seed/${NOUN_SAHEN_CONN_ORTHO_SEED_FILE_NAME}.xz"
            cp ${BASEDIR}/../seed/${NOUN_SAHEN_CONN_ORTHO_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
            unxz ${NEOLOGD_DIC_DIR}/${NOUN_SAHEN_CONN_ORTHO_SEED_FILE_NAME}.xz
        fi
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${NOUN_SAHEN_CONN_ORTHO_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${NOUN_SAHEN_CONN_ORTHO_SEED_FILE_NAME}"
fi

ADJECTIVE_STD_SEED_FILE_NAME=neologd-adjective-std-dict-seed.20151126.csv
if [ -f ${BASEDIR}/../seed/${ADJECTIVE_STD_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_IGNORE_ADJECTIVE_STD=0
    fi
    if [ ${WANNA_IGNORE_ADJECTIVE_STD} -gt 0 ]; then
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${ADJECTIVE_STD_SEED_FILE_NAME}.xz"
    else
        if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
            echo "${ECHO_PREFIX} Install frequent adjective orthographic variant entries using ${BASEDIR}/../seed/${ADJECTIVE_STD_SEED_FILE_NAME}.xz"
            cp ${BASEDIR}/../seed/${ADJECTIVE_STD_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
            unxz ${NEOLOGD_DIC_DIR}/${ADJECTIVE_STD_SEED_FILE_NAME}.xz
        fi
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${ADJECTIVE_STD_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${ADJECTIVE_STD_SEED_FILE_NAME}"
fi

ADJECTIVE_EXP_SEED_FILE_NAME=neologd-adjective-exp-dict-seed.20151126.csv
if [ -f ${BASEDIR}/../seed/${ADJECTIVE_EXP_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_INSTALL_ADJECTIVE_EXP=1
    fi
    if [ ${WANNA_INSTALL_ADJECTIVE_EXP} -gt 0 ]; then
        if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
            echo "${ECHO_PREFIX} Install infrequent adjective orthographic variant entries using ${BASEDIR}/../seed/${ADJECTIVE_EXP_SEED_FILE_NAME}.xz"
            cp ${BASEDIR}/../seed/${ADJECTIVE_EXP_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
            unxz ${NEOLOGD_DIC_DIR}/${ADJECTIVE_EXP_SEED_FILE_NAME}.xz
        fi
    else
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${ADJECTIVE_EXP_SEED_FILE_NAME}.xz"
        echo "${ECHO_PREFIX}     When you install ${ADJECTIVE_EXP_SEED_FILE_NAME}.xz, please set --install_adjective_exp option"
        echo
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${ADJECTIVE_EXP_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${ADJECTIVE_EXP_SEED_FILE_NAME}"
fi

ADJECTIVE_VERB_SEED_FILE_NAME=neologd-adjective-verb-dict-seed.20160324.csv
if [ -f ${BASEDIR}/../seed/${ADJECTIVE_VERB_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_IGNORE_ADJECTIVE_VERB=0
    fi
    if [ ${WANNA_IGNORE_ADJECTIVE_VERB} -gt 0 ]; then
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${ADJECTIVE_VERB_SEED_FILE_NAME}.xz"
    else
        if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
            echo "${ECHO_PREFIX} Install adjective verb orthographic variant entries using ${BASEDIR}/../seed/${ADJECTIVE_VERB_SEED_FILE_NAME}.xz"
            cp ${BASEDIR}/../seed/${ADJECTIVE_VERB_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
            unxz ${NEOLOGD_DIC_DIR}/${ADJECTIVE_VERB_SEED_FILE_NAME}.xz
        fi
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${ADJECTIVE_VERB_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${ADJECTIVE_VERB_SEED_FILE_NAME}"
fi

INFREQ_DATETIME_SEED_FILE_NAME=neologd-date-time-infreq-dict-seed.20181004.csv
if [ -f ${BASEDIR}/../seed/${INFREQ_DATETIME_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_INSTALL_INFREQ_DATETIME=1
    fi
    if [ ${WANNA_INSTALL_INFREQ_DATETIME} -gt 0 ]; then
        if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
            echo "${ECHO_PREFIX} Install infrequent datetime representation entries using ${BASEDIR}/../seed/${INFREQ_DATETIME_SEED_FILE_NAME}.xz"
            cp ${BASEDIR}/../seed/${INFREQ_DATETIME_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
            unxz ${NEOLOGD_DIC_DIR}/${INFREQ_DATETIME_SEED_FILE_NAME}.xz
        fi
    else
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${INFREQ_DATETIME_SEED_FILE_NAME}.xz"
        echo "${ECHO_PREFIX}     When you install ${INFREQ_DATETIME_SEED_FILE_NAME}.xz, please set --install_infreq_datetime option"
        echo
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${INFREQ_DATETIME_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${INFREQ_DATETIME_SEED_FILE_NAME}"
fi

INFREQ_QUANTITY_SEED_FILE_NAME=neologd-quantity-infreq-dict-seed.20181004.csv
if [ -f ${BASEDIR}/../seed/${INFREQ_QUANTITY_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_INSTALL_INFREQ_QUANTITY=1
    fi
    if [ ${WANNA_INSTALL_INFREQ_QUANTITY} -gt 0 ]; then
        if [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
            echo "${ECHO_PREFIX} Install infrequent quantity representation entries using ${BASEDIR}/../seed/${INFREQ_QUANTITY_SEED_FILE_NAME}.xz"
            cp ${BASEDIR}/../seed/${INFREQ_QUANTITY_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
            unxz ${NEOLOGD_DIC_DIR}/${INFREQ_QUANTITY_SEED_FILE_NAME}.xz
        fi
    else
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${INFREQ_QUANTITY_SEED_FILE_NAME}.xz"
        echo "${ECHO_PREFIX}     When you install ${INFREQ_QUANTITY_SEED_FILE_NAME}.xz, please set --install_infreq_quantity option"
        echo
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${INFREQ_QUANTITY_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${INFREQ_QUANTITY_SEED_FILE_NAME}"
fi

ILL_FORMED_WORDS_SEED_FILE_NAME=neologd-ill-formed-words-dict-seed.20170127.csv
if [ -f ${BASEDIR}/../seed/${ILL_FORMED_WORDS_SEED_FILE_NAME}.xz ]; then
    if [ ${WANNA_INSRALL_ALL_SEED_FILES} -gt 0 ]; then
        WANNA_IGNORE_ILL_FORMED_WORDS=0
    fi
    if [ ${WANNA_IGNORE_ILL_FORMED_WORDS} -gt 0 ]; then
        echo "${ECHO_PREFIX} Not install ${BASEDIR}/../seed/${ILL_FORMED_WORDS_SEED_FILE_NAME}.xz"
        echo "${ECHO_PREFIX}     When you install ${ILL_FORMED_WORDS_SEED_FILE_NAME}.xz, please set --install_ill_formed_words option"
        echo
    elif [ ${WANNA_INSTALL_ONLY_PATCHED_IPADIC} -eq 0 ]; then
        echo "${ECHO_PREFIX} Install entries of ill formed words using ${BASEDIR}/../seed/${ILL_FORMED_WORDS_SEED_FILE_NAME}.xz"
        cp ${BASEDIR}/../seed/${ILL_FORMED_WORDS_SEED_FILE_NAME}.xz ${NEOLOGD_DIC_DIR}
        unxz ${NEOLOGD_DIC_DIR}/${ILL_FORMED_WORDS_SEED_FILE_NAME}.xz
    fi
else
    echo "${ECHO_PREFIX} ${BASEDIR}/../seed/${ILL_FORMED_WORDS_SEED_FILE_NAME} isn't there"
    echo "${ECHO_PREFIX} We can't intall ${BASEDIR}/../seed/${ILL_FORMED_WORDS_SEED_FILE_NAME}"
fi



SEED_FILE_NAMES=($(find ${NEOLOGD_DIC_DIR}/* -name "*.csv"))

if [ ${MIN_SURFACE_LEN} -gt 0 -o ${MAX_SURFACE_LEN} -gt 0 ]; then
    for (( I = 0; I < ${#SEED_FILE_NAMES[@]}; ++I ))
    do
        TMP_SEED_FILE_NAME=${SEED_FILE_NAMES[$I]}
        TMP_SEED_FILE_NAME=${TMP_SEED_FILE_NAME##*/}

        if [ -f ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME} ]; then
            echo "${ECHO_PREFIX} Cut string of surface of entries in ${TMP_SEED_FILE_NAME}"
            if [ ${MIN_SURFACE_LEN} -gt 0 ]; then
                echo "${ECHO_PREFIX} Delete the entries whose length of surface is shorter than ${MIN_SURFACE_LEN} from seed file"
                cat ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME} | perl -ne "use Encode;my \$l=\$_;my @a=split /,/,\$l;\$len=length Encode::decode_utf8(\$a[0]);print \$l if(\$len >= ${MIN_SURFACE_LEN});" > ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.tmp
                mv ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.tmp ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}
            fi
            if [ ${MAX_SURFACE_LEN} -gt 0 ]; then
                echo "${ECHO_PREFIX} Delete the entries whose length of surface is longer than ${MAX_SURFACE_LEN} from seed file"
                cat ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME} | perl -ne "use Encode;my \$l=\$_;my @a=split /,/,\$l;\$len=length Encode::decode_utf8(\$a[0]);print \$l if(\$len <= ${MAX_SURFACE_LEN});" > ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.tmp
                mv ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.tmp ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}
            fi
        fi
    done
fi

if [ ${MIN_BASEFORM_LEN} -gt 0 -o ${MAX_BASEFORM_LEN} -gt 0 ]; then
    for (( I = 0; I < ${#SEED_FILE_NAMES[@]}; ++I ))
    do
        TMP_SEED_FILE_NAME=${SEED_FILE_NAMES[$I]}
        TMP_SEED_FILE_NAME=${TMP_SEED_FILE_NAME##*/}
        if [ -f ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME} ]; then
            echo "${ECHO_PREFIX} Cut string of base form of entries in ${TMP_SEED_FILE_NAME}"
            if [ ${MIN_BASEFORM_LEN} -gt 0 ]; then
                echo "${ECHO_PREFIX} Delete the entries whose length of base form is shorter than ${MIN_BASEFORM_LEN} from seed file"
                cat ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME} | perl -ne "use Encode;my \$l=\$_;my @a=split /,/,\$l;\$len=length Encode::decode_utf8(\$a[10]);print \$l if(\$len >= ${MIN_BASEFORM_LEN});" > ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.tmp
                mv ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.tmp ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}
            fi
            if [ ${MAX_BASEFORM_LEN} -gt 0 ]; then
                echo "${ECHO_PREFIX} Delete the entries whose length of base form is longer than ${MAX_BASEFORM_LEN} from seed file"
                cat ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME} | perl -ne "use Encode;my \$l=\$_;my @a=split /,/,\$l;\$len=length Encode::decode_utf8(\$a[10]);print \$l if(\$len <= ${MAX_BASEFORM_LEN});" > ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.tmp
                mv ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.tmp ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}
            fi
        fi
    done
fi

if [ ${WANNA_ELIMINATE_REDUNDANT_ENTRY} -gt 0 ]; then
    for (( I = 0; I < ${#SEED_FILE_NAMES[@]}; ++I ))
    do
        TMP_SEED_FILE_NAME=${SEED_FILE_NAMES[$I]}
        TMP_SEED_FILE_NAME=${TMP_SEED_FILE_NAME##*/}
        if [ -f ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME} ]; then
            perl ${BASEDIR}/../libexec/eliminate_redundant_entry.pl ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME} > ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.same
            mv ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}.same ${NEOLOGD_DIC_DIR}/${TMP_SEED_FILE_NAME}
        fi
    done
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
        echo "${ECHO_PREFIX} Failed to create the user dictionary"
        exit 1
    fi
fi

cp ${BASEDIR}/../misc/dic/unk.def .

if [ ! "${COLUMN_EXTENSIONS_URLS}" = "" ]; then
    echo "${ECHO_PREFIX} Expand column of all seed data"
    echo "    ${COLUMN_EXTENSIONS_URLS}"
    ${BASEDIR}/../libexec/merge-ext-columns-using-git.sh "${COLUMN_EXTENSIONS_URLS}"
fi

cd ${NEOLOGD_DIC_DIR}

echo "${ECHO_PREFIX} Re-Index system dictionary"
${MECAB_LIBEXEC_DIR}/mecab-dict-index -f UTF8 -t UTF8

echo "${ECHO_PREFIX} Make custom system dictionary on ${BASEDIR}/../build/${NEOLOGD_DIC_NAME}"
make
# for Ubuntu Linux on Windows 10
sed -i -e "s|${MECAB_DIC_DIR}/ipadic|${INSTALL_DIR_PATH}|g" ${NEOLOGD_DIC_DIR}/Makefile

echo "$ECHO_PREFIX Finish.."
