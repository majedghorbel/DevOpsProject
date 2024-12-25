#!/bin/bash

# Display commands as they are executed
set -x

# Exit immediately if a command exits with a non-zero status.
set -e

source /etc/os-release

case $VERSION_ID in
    20.04)
        DEBIAN_NAME="ubuntu"
        DEBIAN_RELEASE="focal"
esac

TOMLRB_VERSION="0.3.8"

rm -f /root/.ssh/authorized_keys
cat <<EOF > /root/.ssh/authorized_keys
from="109.190.254.36" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0a3D7cOCSXSaNVmkO07V4gK6sitIOgDCXnGMptHb3vKJKSwpbr+m3rjYJ7xypHk7jYCo2zLYbnFEg2AuABZIjpmvJj3GrhpNfZBK+Pfw5lA+gMgPRJlZiar+7yFFJFjGfXquv+8qjYCagI9eglZDJgekM643sDjDkN1AkFGp58tWNIVEm9VlIoy1b0YNdNwwAIYFbTR7NSfAF4hOpCJfKl7UBswQUO1wYMYBi73366AwmJv373+OeYVUlXK9HNWVzzhaXSGKzOYbE7cOoJGSGrNN1GiyAMbBRKIh6Zg7JcaHoPpVwL4lwCfe8lVDsE83DpqiO8n0vUtat7+Jl0x0lGbWtBZy+vAfteEBVfSEH5F1XONm1/ry4mLW7Qvt53qNhNw5sotfCNFXMbh7dLhcBgge0WjIOJYSB305+1OzUVZynPOr+6w4dsXT5H3qttDOmiCiZwEvDcnFVOpuFoMiup20m/ba6Myx2at9aOJG5o1d81dJSD2wT+Ywzsth0YSC2LmiV7+DkfFJMeRTds3WB8pIKYgmvjJFSLYuSO6rpVHmlY+fjbHWfYEqFTCrJOg9JcySiZrvnVHji7E1KwZsyKBREceQLKyEtw/ABuJZLAYb4e+Eby8BzDDQxW/EWzeHzeuWK3akFWKFji83vNbn1/I5ilK25QfE/SIUyPmL+FQ== majed@LWI1468049
EOF

export DEBIAN_FRONTEND='noninteractive'

FILE_PATH="/home/ubuntu/openRC.sh"

# lsb-release for libjson-perl, libfile-flock-perl for psc, curl for puppet-masterless
apt-get install -y --force-yes libjson-perl libjson-xs-perl libfile-flock-perl

wget https://apt.puppet.com/puppet8-release-focal.deb
dpkg -i puppet8-release-focal.deb

apt-get update -y
apt-get upgrade -y
apt install facter -y
apt-get install apache2 -y
systemctl start apache2
systemctl enable apache2
vmip=$(facter ipaddress --no-ruby)
echo '<center><h1>This OVHcloud instance has ip: VMIP </h1></center>' > /var/www/html/index.txt
sed "s/VMIP/$vmip/" /var/www/html/index.txt > /var/www/html/index.html

apt install python3-pip -y
apt install python3-swiftclient -y
pip install python-openstackclient
pip install awscli awscli-plugin-endpoint

cat <<EOF > "$FILE_PATH"
#!/usr/bin/env bash
# To use an OpenStack cloud you need to authenticate against the Identity
# service named keystone, which returns a **Token** and **Service Catalog**.
# The catalog contains the endpoints for all services the user/tenant has
# access to - such as Compute, Image Service, Identity, Object Storage, Block
# Storage, and Networking (code-named nova, glance, keystone, swift,
# cinder, and neutron).
#
# *NOTE*: Using the 3 *Identity API* does not necessarily mean any other
# OpenStack API is version 3. For example, your cloud provider may implement
# Image API v1.1, Block Storage API v2, and Compute API v2.0. OS_AUTH_URL is
# only for the Identity API served through keystone.
export OS_AUTH_URL=https://auth.cloud.ovh.net/v3
# With the addition of Keystone we have standardized on the term **project**
# as the entity that owns the resources.
export OS_PROJECT_ID=some_PROJECT_ID
export OS_PROJECT_NAME="8417779378048483"
export OS_USER_DOMAIN_NAME="Default"
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
export OS_PROJECT_DOMAIN_ID="default"
if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi
# unset v2.0 items in case set
export OS_TENANT_ID=some_TENANT_ID
unset OS_TENANT_NAME
# In addition to the owning entity (tenant), OpenStack stores the entity
# performing the action as the **user**.
export OS_USERNAME="some_user"
# With Keystone you pass the keystone password.
#echo "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: "
#read -sr OS_PASSWORD_INPUT
#export OS_PASSWORD=$OS_PASSWORD_INPUT
export OS_PASSWORD="some_password"
# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="DE"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
EOF

apt-get install puppet-agent

# toml-rb gem must be installed before first puppet run
# --no-ri --no-rdoc are deprecated used --no-document for Ubuntu 20.04
/opt/puppetlabs/puppet/bin/gem install toml-rb -v $TOMLRB_VERSION --no-document --clear-sources || /opt/puppetlabs/puppet/bin/gem install toml-rb -v $TOMLRB_VERSION --no-ri --no-rdoc --clear-sources

PUPPET_PATH="/etc/puppetlabs/code/environments/production"
rm -rf $PUPPET_PATH &&  /usr/bin/git clone github_url/majedghorbel/puppet.git $PUPPET_PATH

/opt/puppetlabs/puppet/bin/puppet apply $PUPPET_PATH/manifests/site.pp

echo "  __        ___    ____  _   _ ___ _   _  ____     "
echo "  \ \      / / \  |  _ \| \ | |_ _| \ | |/ ___|    "
echo "   \ \ /\ / / _ \ | |_) |  \| || ||  \| | |  _     "
echo "    \ V  V / ___ \|  _ <| |\  || || |\  | |_| |    "
echo "     \_/\_/_/   \_\_| \_\_| \_|___|_| \_|\____|    "
echo "                                                   "
echo " *** KEEP THOSE LINES AT THE END OF THE SCRIPT *** "
echo "                                                   "
echo "                                                   "

source $FILE_PATH
echo "__PCS_POSTINSTALL_DONE__"