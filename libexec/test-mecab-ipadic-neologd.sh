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
ECHO_PREFIX="[test-mecab-ipadic-neologd] :"

echo "$ECHO_PREFIX Start.."

echo "$ECHO_PREFIX Replace timestamp from 'git clone' date to 'git commit' date"
${BASEDIR}/../misc/git-set-file-times

YMD=`ls -c \`find ${BASEDIR}/../seed/mecab-user-dict-seed.*.csv.xz\` | head -1 | egrep -o '[0-9]{8}' | tail -1`
if [ ! -e ${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD} ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD} isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/make-mecab-ipadic-neologd.sh first."
    exit
fi

MECAB_PATH=`which mecab`
MECAB_DIC_DIR=${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD}

echo "$ECHO_PREFIX Get buzz phrases"

curl http://searchranking.yahoo.co.jp/realtime_buzz/ -o "/tmp/realtime_buzz.html"
sed -i -e "/\n/d" /tmp/realtime_buzz.html
cat /tmp/realtime_buzz.html | perl -ne '$l = $_;  if ($l =~ m|<h3><a href="http://rdsig\.yahoo\.co\.jp.+?">(.+)</a></h3>|g){ print $1."\n";}' > /tmp/buzz_phrase

PHRASE_FILE=/tmp/buzz_phrase
if [ ! -s ${PHRASE_FILE} ]; then
   PHRASE_FILE=""#${BASEDIR}/../misc/buzz_phrase_201402181610
fi

echo "$ECHO_PREFIX Get difference between default system dictionary and mecab-ipadic-neologd"

cat /tmp/buzz_phrase| mecab -Owakati > /tmp/buzz_phrase_tokenized_using_defdic
cat /tmp/buzz_phrase| mecab -Owakati -d ${MECAB_DIC_DIR} > /tmp/buzz_phrase_tokenized_using_neologismdic
/usr/bin/diff -y -W60 --side-by-side --suppress-common-lines /tmp/buzz_phrase_tokenized_using_defdic /tmp/buzz_phrase_tokenized_using_neologismdic > /tmp/buzz_phrase_tokenized_diff

if [ -s /tmp/buzz_phrase_tokenized_diff ]; then
    echo "$ECHO_PREFIX Tokenize phrase using default system dictionary"
    echo "default system dictonary" > /tmp/buzz_phrase_tokenized_using_defdic
    cat /tmp/buzz_phrase| mecab -Owakati >> /tmp/buzz_phrase_tokenized_using_defdic

    echo "$ECHO_PREFIX Tokenize phrase using mecab-ipadic-neologd"
    echo "mecab-ipadic-neologd" > /tmp/buzz_phrase_tokenized_using_neologismdic
    cat /tmp/buzz_phrase| mecab -Owakati -d ${MECAB_DIC_DIR} >> /tmp/buzz_phrase_tokenized_using_neologismdic

    echo "$ECHO_PREFIX Get result of diff"
    /usr/bin/diff -y -W60 --side-by-side --suppress-common-lines /tmp/buzz_phrase_tokenized_using_defdic /tmp/buzz_phrase_tokenized_using_neologismdic > /tmp/buzz_phrase_tokenized_diff

    echo "$ECHO_PREFIX Please check difference between default system dictionary and mecab-ipadic-neologd"
    echo ""
    cat /tmp/buzz_phrase_tokenized_diff
    echo ""
else
    echo "$ECHO_PREFIX Something wrong. You shouldn't install mecab-ipadic-neologd yet."
fi

echo "$ECHO_PREFIX Finish.."
