#!/bin/sh

HOSTNAME=$1

if [ -z "$HOSTNAME" ]; then
    echo "The hostname isn't specified."
    exit 1
fi

OPENEDX_RELEASE="open-release/eucalyptus.2"
CONFIG_VERSION="ikto/eucalyptus.2"
CONFIG_REPO="https://github.com/ikto/edx-configuration.git"

sudo apt-get update -y
sudo apt-get install -y build-essential software-properties-common python-software-properties curl git-core libxml2-dev libxslt1-dev libfreetype6-dev python-pip python-apt python-dev libxmlsec1-dev swig libmysqlclient-dev
sudo pip install --upgrade pip
sudo pip install --upgrade virtualenv

cd /var/tmp
git clone -b "$CONFIG_VERSION" "$CONFIG_REPO" edx-configuration

cd /var/tmp/edx-configuration
sudo pip install -r requirements.txt
sudo pip install setuptools --upgrade

cd /var/tmp/configuration/playbooks
sudo ansible-playbook -c local --limit "localhost:127.0.0.1" edx_sandbox.yml \
-i "localhost," \
-e "EDXAPP_PREVIEW_LMS_BASE=preview.${HOSTNAME}" \
-e "EDXAPP_LMS_BASE=${HOSTNAME}" \
-e "EDXAPP_LMS_PREVIEW_NGINX_PORT=80" \
-e "EDXAPP_CMS_NGINX_PORT=80" \
-e "EDXAPP_LMS_NGINX_PORT=80" \
-e "edx_platform_version=${OPENEDX_VERSION} " \
-e "certs_version=${OPENEDX_VERSION}" \
-e "forum_version=${OPENEDX_VERSION}" \
-e "xqueue_version=${OPENEDX_VERSION}" \
-e "demo_version=${OPENEDX_VERSION}" \
-e "NOTIFIER_VERSION=${OPENEDX_VERSION}" \
-e "INSIGHTS_VERSION=${OPENEDX_VERSION}" \
-e "ANALYTICS_API_VERSION=${OPENEDX_VERSION}"
