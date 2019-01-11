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
ECHO_PREFIX="[merge-ext-columns-using-git] :"
GREP_OPTIONS=""

EXT_COLUMN_URL_CSV=$1

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

ORG_DIC_NAME=mecab-ipadic-2.7.0-20070801
NEOLOGD_DIC_NAME=${ORG_DIC_NAME}-neologd-${YMD}
NEOLOGD_BUILD_DIR=${BASEDIR}/../build/${NEOLOGD_DIC_NAME}

echo "$ECHO_PREFIX Move to the build directory => ${NEOLOGD_BUILD_DIR}"
cd ${NEOLOGD_BUILD_DIR}

CSV_FILE_PATH_ARR=(`find ${NEOLOGD_BUILD_DIR}/*.csv`)
for (( J = 0; J < ${#CSV_FILE_PATH_ARR[@]}; ++J ))
do
    CSV_FILE_PATH=${CSV_FILE_PATH_ARR[${J}]}
    CSV_FILE_NAME=${CSV_FILE_PATH##*/}
    echo ${CSV_FILE_NAME}
    if [ -f ${CSV_FILE_PATH}.before_merge_ext_column ]; then
        echo "$ECHO_PREFIX Restore the original CSV files"
        mv ${CSV_FILE_PATH}.before_merge_ext_column ${CSV_FILE_PATH}
        cp ${CSV_FILE_PATH} ${CSV_FILE_PATH}.before_merge_ext_column
    else
        echo "$ECHO_PREFIX Backup the original CSV files"
        cp ${CSV_FILE_PATH} ${CSV_FILE_PATH}.before_merge_ext_column
    fi
done



EXT_COLUMN_URL_ARR=(`echo ${EXT_COLUMN_URL_CSV} | tr -s ',' ' '`)
for (( I = 0; I < ${#EXT_COLUMN_URL_ARR[@]}; ++I ))
do
    EXT_COLUMN_URL=${EXT_COLUMN_URL_ARR[${I}]}
    EXT_COLUMN_REPO_NAME=${EXT_COLUMN_URL##*/}
    EXT_COLUMN_REPO_NAME=${EXT_COLUMN_REPO_NAME%%\.git}

    if [[ ! ${EXT_COLUMN_URL} =~ "^https?://" ]] && [[ ! ${EXT_COLUMN_URL} =~ "/"  ]]; then
        if [[ ! ${EXT_COLUMN_URL} =~ "^ext-column-" ]]; then
            EXT_COLUMN_URL="https://github.com/neologd/ext-column-"${EXT_COLUMN_URL_ARR[${I}]}
        else
            EXT_COLUMN_URL="https://github.com/neologd/"${EXT_COLUMN_URL_ARR[${I}]}
        fi
    fi

    if [ -d ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME} ]; then
        echo "$ECHO_PREFIX Update a column extension of ${EXT_COLUMN_REPO_NAME}"
        cd ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME}
        git fetch origin
        git reset --hard origin/master
        cd ${NEOLOGD_BUILD_DIR}
    else
        echo "$ECHO_PREFIX Get a column extension from ${EXT_COLUMN_URL}"
        git clone ${EXT_COLUMN_URL} ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME}
    fi

    for (( J = 0; J < ${#CSV_FILE_PATH_ARR[@]}; ++J ))
    do
        CSV_FILE_PATH=${CSV_FILE_PATH_ARR[${J}]}
        CSV_FILE_NAME=${CSV_FILE_PATH##*/}
        CSV_FILE_NAME_PREFIX=`echo ${CSV_FILE_NAME} | perl -ne '$l=$_; if ($l=~m|^(.+?)[._]{1}[0-9\-]{8,}\.csv$|) { print $1; } elsif ($l=~m|^(.+?)\.csv$|) { print $1; }'`
        if [ -f ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME}/extension/${CSV_FILE_NAME_PREFIX}.tsv.xz ]; then
            echo "$ECHO_PREFIX Decompress ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME}/extension/${CSV_FILE_NAME_PREFIX}.tsv.xz"
            unxz -k ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME}/extension/${CSV_FILE_NAME_PREFIX}.tsv.xz

            LC_ALL=C sort ${CSV_FILE_NAME} > ${CSV_FILE_NAME}.sort
            LC_ALL=C uniq ${CSV_FILE_NAME}.sort > ${CSV_FILE_NAME}
            rm ${CSV_FILE_NAME}.sort

            echo "$ECHO_PREFIX Join ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME}/extension/${CSV_FILE_NAME_PREFIX}.tsv"
            ${BASEDIR}/../libexec/merge-ext-column.pl ${CSV_FILE_PATH} ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME}/extension/${CSV_FILE_NAME_PREFIX}.tsv

            mv ${CSV_FILE_PATH}.ext ${CSV_FILE_PATH}
            rm ${NEOLOGD_BUILD_DIR}/${EXT_COLUMN_REPO_NAME}/extension/${CSV_FILE_NAME_PREFIX}.tsv
        else
            echo "$ECHO_PREFIX Add null columns to ${CSV_FILE_PATH}"
            sed -i -e "s/$/,/g" ${CSV_FILE_PATH}
        fi
    done
done
