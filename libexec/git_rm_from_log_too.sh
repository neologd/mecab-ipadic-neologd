 !#/bin/bash

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
