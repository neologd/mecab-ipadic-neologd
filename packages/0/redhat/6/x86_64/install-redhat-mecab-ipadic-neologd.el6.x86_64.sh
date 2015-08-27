#!/bin/bash

ECHO_PREFIX="[install-redhat-mecab-ipadic-neologd]: "

echo "${ECHO_PREFIX} Start."

echo "${ECHO_PREFIX} This script requires superuser access to install mecab-ipadic-neologd RPM packages."

# Clear any previous sudo permission
sudo -k

echo "${ECHO_PREFIX} Please prompt your password of superuser."

# Run inside sudo
sudo sh <<SCRIPT


  # add GPG key
  echo "${ECHO_PREFIX} Import GPG public key."
  rpm --import https://neologd.github.io/mecab-ipadic-neologd/RPM-GPG-KEY-NEolgod

  # add treasure data repository to yum
  echo "${ECHO_PREFIX} Put the repo file to /etc/yum.repos.d/* ."
  cat >/etc/yum.repos.d/mecab-ipadic-neologd.repo <<'EOF';
[mecab-ipadic-neologd]
name=mecab-ipadic-NEologd
baseurl=https://neologd.github.io/mecab-ipadic-neologd/packages/0/redhat/6/x86_64/
gpgcheck=1
gpgkey=https://neologd.github.io/mecab-ipadic-neologd/RPM-GPG-KEY-NEolgod
EOF

  #https://neologd.github.io/mecab-ipadic-neologd/packages/0/\$releasever/\$basearch

  # update your sources
  echo "${ECHO_PREFIX} Chack update information of yum ."
  yum check-update

  # install the recent mecab-ipadic-neologd package
  echo "${ECHO_PREFIX} Install mecab-ipadic-neologd ."
  yes | yum install -y mecab-ipadic-neologd

SCRIPT

echo "${ECHO_PREFIX} Finish."
