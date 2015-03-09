#!/bin/bash

FILE_NAME=$1
iconv -f EUC-JP -t UTF-8 ${FILE_NAME} > ${FILE_NAME}.utf8
