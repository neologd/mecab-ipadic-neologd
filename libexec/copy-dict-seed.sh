#!/usr/bin/env bash

BASEDIR=$(cd $(dirname $0);pwd)
ECHO_PREFIX="[copy-dict-seed] :"

echo "$ECHO_PREFIX Start.."

echo "$ECHO_PREFIX Check local seed directory"
SEED_DIR=$1
if [ ! -e ${SEED_DIR}/package/rpm/RPMS/noarch/ ]; then
    echo "${ECHO_PREFIX} Set your local seed directry after generating the user dictionary."
    echo "usage: ./libexec/copy-dict-seed.sh <path to seed directry>"
    exit;
fi

YMD=`find ${SEED_DIR}/package/rpm/RPMS/noarch/mecab-ipadic-*-2.7.0-0.*.el6.noarch.rpm| egrep -o '[0-9]{8}' | tail -1`

echo "$ECHO_PREFIX Copy seed file"

if [ ! -e ${BASEDIR}/../seed ]; then
    echo "$ECHO_PREFIX create ${BASEDIR}/../seed"
    mkdir -p ${BASEDIR}/../seed
fi

SEED_FILE_NAME=mecab-user-dict-seed.${YMD}.csv
cp ${SEED_DIR}/seed/${SEED_FILE_NAME} ${BASEDIR}/../seed/

echo "$ECHO_PREFIX Delete the debug columns"
cat ${BASEDIR}/../seed/${SEED_FILE_NAME} | cut -d $',' -f -13 > ${BASEDIR}/../seed/${SEED_FILE_NAME}.lite

echo "$ECHO_PREFIX Compress the seed file"
mv ${BASEDIR}/../seed/${SEED_FILE_NAME} ${BASEDIR}/../seed/${SEED_FILE_NAME}.rich
mv ${BASEDIR}/../seed/${SEED_FILE_NAME}.lite ${BASEDIR}/../seed/${SEED_FILE_NAME}
xz -9 -k ${BASEDIR}/../seed/${SEED_FILE_NAME}

echo "$ECHO_PREFIX Finish.."
