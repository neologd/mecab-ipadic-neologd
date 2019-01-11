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

FILE_PATH=$1
ECHO_PREFIX='[git_rm_from_history_too] '

echo "${ECHO_PREFIX} Start."

if [ ! -e ${FILE_PATH} ]; then
    echo "${ECHO_PREFIX} ${FILE_PATH} is not found"
    exit 1
fi

git pull

if [ -e ${FILE_PATH} ]; then
    echo "${ECHO_PREFIX} git rm ${FILE_PATH}"
    git rm ${FILE_PATH}
    echo "${ECHO_PREFIX} git commit"
    git commit -m "Remove obsolete file: ${FILE_PATH}"
    echo "${ECHO_PREFIX} git push"
    git push
    echo "${ECHO_PREFIX} delete file from log"
    git filter-branch -f --tree-filter "rm -f ${FILE_PATH}"
    echo "${ECHO_PREFIX} git push --force"
    git push --force
fi

echo "${ECHO_PREFIX} Finish."
