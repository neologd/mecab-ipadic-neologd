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
ECHO_PREFIX="[test-mecab-ipadic-NEologd] :"
GREP_OPTIONS=""

echo "$ECHO_PREFIX Start.."

echo "$ECHO_PREFIX Replace timestamp from 'git clone' date to 'git commit' date"
${BASEDIR}/../misc/git-set-file-times

YMD=`ls -ltr \`find ${BASEDIR}/../seed/mecab-user-dict-seed.*.csv.xz\` | egrep -o '[0-9]{8}' | tail -1`
if [ ! -e ${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD} ]; then
    echo "${ECHO_PREFIX} ${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD} isn't there."
    echo "${ECHO_PREFIX} You should execute libexec/make-mecab-ipadic-neologd.sh first."
    exit 1
fi

MECAB_PATH=`which mecab`
MECAB_DIC_DIR=${BASEDIR}/../build/mecab-ipadic-2.7.0-20070801-neologd-${YMD}

echo "$ECHO_PREFIX Get buzz phrases"

CURRENT_UNIXTIME=`date +%s`
curl 'https://search.yahoo.co.jp/?ajax=1&prop=realtime&_=${CURRENT_UNIXTIME}' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.33 Safari/537.36' -H 'accept: application/json, text/javascript, */*; q=0.01' -H 'referer: https://search.yahoo.co.jp/' -H 'authority: search.yahoo.co.jp' -H 'x-requested-with: XMLHttpRequest' --compressed -o "/tmp/realtime_buzz.json"

if [ $? != 0 ]; then
    echo ""
    echo "$ECHO_PREFIX Failed to get the buzz phrases"
    echo "$ECHO_PREFIX Please check your network to download 'https://search.yahoo.co.jp/#!/realtime'"
    exit 1;
fi

cat /tmp/realtime_buzz.json | perl -Xpne 's/\\u([0-9a-fA-F]{4})/chr(hex($1))/eg' | perl -ne '$l = $_; while ($l =~ m|<a [^>]+realtime[^>]+>([^<]+)<\\/a>|g) {print $1."\n"}' > /tmp/buzz_phrase
rm /tmp/realtime_buzz.json

PHRASE_FILE=/tmp/buzz_phrase
if [ ! -s ${PHRASE_FILE} ]; then
   PHRASE_FILE=""
fi

echo "$ECHO_PREFIX Get difference between default system dictionary and mecab-ipadic-NEologd"

cat /tmp/buzz_phrase| mecab -Owakati > /tmp/buzz_phrase_defdic
cat /tmp/buzz_phrase| mecab -Owakati -d ${MECAB_DIC_DIR} > /tmp/buzz_phrase_neologismdic

set +e # Can't use diff command and 'set -e' option at the same time
/usr/bin/diff -y -W70 --side-by-side --suppress-common-lines /tmp/buzz_phrase_defdic /tmp/buzz_phrase_neologismdic >/tmp/buzz_phrase_diff
set -e

if [ -s /tmp/buzz_phrase_diff ]; then
    echo "$ECHO_PREFIX Tokenize phrase using default system dictionary"
    echo "default system dictionary" > /tmp/buzz_phrase_defdic
    cat /tmp/buzz_phrase| mecab -Owakati >> /tmp/buzz_phrase_defdic

    echo "$ECHO_PREFIX Tokenize phrase using mecab-ipadic-NEologd"
    echo "mecab-ipadic-NEologd" > /tmp/buzz_phrase_neologismdic
    cat /tmp/buzz_phrase| mecab -Owakati -d ${MECAB_DIC_DIR} >> /tmp/buzz_phrase_neologismdic

    echo "$ECHO_PREFIX Get result of diff"
    set +e # Can't use diff command and 'set -e' option at the same time
    /usr/bin/diff -y -W70 --side-by-side --suppress-common-lines /tmp/buzz_phrase_defdic /tmp/buzz_phrase_neologismdic > /tmp/buzz_phrase_diff
    set -e

    echo "$ECHO_PREFIX Please check difference between default system dictionary and mecab-ipadic-NEologd"
    echo ""
    cat /tmp/buzz_phrase_diff
    echo ""
else
    echo "$ECHO_PREFIX Something wrong. You shouldn't install mecab-ipadic-NEologd yet."
fi

rm /tmp/buzz_phrase
rm /tmp/buzz_phrase_defdic
rm /tmp/buzz_phrase_neologismdic
rm /tmp/buzz_phrase_diff

echo "$ECHO_PREFIX Finish.."
