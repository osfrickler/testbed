#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# NOTE: Because DNS queries don't always work directly at the beginning a
#       retry for APT.
echo "APT::Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries

echo '* libraries/restart-without-asking boolean true' | debconf-set-selections

apt-get update
apt-get install --yes \
  git-lfs \
  python3-argcomplete \
  python3-crypto \
  python3-dnspython \
  python3-jmespath \
  python3-kerberos \
  python3-libcloud \
  python3-lockfile \
  python3-netaddr \
  python3-netifaces \
  python3-ntlm-auth \
  python3-pip \
  python3-requests-kerberos \
  python3-requests-ntlm \
  python3-selinux \
  python3-winrm \
  python3-xmltodict

# NOTE: There are cloud images on which Ansible is pre-installed.
apt-get remove --yes ansible

pip3 install --no-cache-dir 'ansible>=5.0.0,<6.0.0'

chown -R ubuntu:ubuntu /home/ubuntu/.ssh

mkdir -p /usr/share/ansible

ansible-galaxy collection install --collections-path /usr/share/ansible/collections ansible.netcommon
ansible-galaxy collection install --collections-path /usr/share/ansible/collections git+https://github.com/osism/ansible-collection-commons.git
ansible-galaxy collection install --collections-path /usr/share/ansible/collections git+https://github.com/osism/ansible-collection-services.git

chmod -R +r /usr/share/ansible

ansible-playbook -i localhost, /opt/manager-part-0.yml

cp /home/ubuntu/.ssh/id_rsa /home/dragon/.ssh/id_rsa
cp /home/ubuntu/.ssh/id_rsa.pub /home/dragon/.ssh/id_rsa.pub
chown -R dragon:dragon /home/dragon/.ssh

sudo -iu dragon ansible-playbook -i testbed-manager.testbed.osism.xyz, /opt/manager-part-1.yml -e configuration_git_version=$CONFIGURATION_VERSION

sudo -iu dragon sh -c "cd /opt/configuration; ./scripts/set-manager-version.sh $MANAGER_VERSION"

if [[ "$MANAGER_VERSION" == "latest" ]]; then
    sudo -iu dragon sh -c "cd /opt/configuration; ./scripts/set-ceph-version.sh $CEPH_VERSION"
    sudo -iu dragon sh -c "cd /opt/configuration; ./scripts/set-openstack-version.sh $OPENSTACK_VERSION"
else
    sudo -iu dragon sh -c "cd /opt/configuration; ./scripts/set-ceph-version.sh $MANAGER_VERSION"
    sudo -iu dragon sh -c "cd /opt/configuration; ./scripts/set-openstack-version.sh $MANAGER_VERSION"
fi

sudo -iu dragon sh -c "cd /opt/configuration; ./scripts/enable-secondary-nodes.sh $NUMBER_OF_NODES"

cp /opt/configuration/environments/kolla/certificates/ca/testbed.crt /usr/local/share/ca-certificates/
update-ca-certificates

sudo -iu dragon ansible-playbook -i testbed-manager.testbed.osism.xyz, /opt/manager-part-2.yml
sudo -iu dragon ansible-playbook -i testbed-manager.testbed.osism.xyz, /opt/manager-part-3.yml --vault-password-file /opt/configuration/environments/.vault_pass

sudo -iu dragon cp /home/dragon/.ssh/id_rsa.pub /opt/ansible/secrets/id_rsa.operator.pub

# NOTE(berendt): wait for ara-server service
until [[ "$(/usr/bin/docker inspect -f '{{.State.Health.Status}}' manager-ara-server-1)" == "healthy" ]]; do
    sleep 1;
done;

# NOTE(berendt): wait for netbox service
until [[ "$(/usr/bin/docker inspect -f '{{.State.Health.Status}}' netbox-netbox-1)" == "healthy" ]]; do
    sleep 1;
done;

# NOTE(berendt): sudo -E does not work here because sudo -i is needed

sudo -iu dragon sh -c 'INTERACTIVE=false osism netbox import --vendors Arista'
sudo -iu dragon sh -c 'INTERACTIVE=false osism netbox import --vendors Other --no-library'
sudo -iu dragon sh -c 'INTERACTIVE=false osism netbox init'
sudo -iu dragon sh -c 'INTERACTIVE=false osism netbox manage 1000'
sudo -iu dragon sh -c 'INTERACTIVE=false osism netbox connect 1000 --state a'

sudo -iu dragon sh -c 'INTERACTIVE=false osism apply operator -l "all:!manager" -u ubuntu'
sudo -iu dragon sh -c 'INTERACTIVE=false osism apply --environment custom facts'
sudo -iu dragon sh -c 'INTERACTIVE=false osism apply bootstrap'

# copy network configuration
sudo -iu dragon sh -c 'INTERACTIVE=false osism apply network'

# apply workarounds
sudo -iu dragon sh -c 'INTERACTIVE=false osism apply --environment custom workarounds'

# deploy wireguard
sudo -iu dragon sh -c 'INTERACTIVE=false osism apply wireguard'
sed -i -e s/WIREGUARD_PUBLIC_IP_ADDRESS/$(curl my.ip.fi)/ /home/dragon/wireguard-client.conf

# reboot nodes
sudo -iu dragon sh -c 'INTERACTIVE=false osism apply reboot -l testbed-nodes -e ireallymeanit=yes'
sudo -iu dragon sh -c 'INTERACTIVE=false osism apply wait-for-connection -l testbed-nodes -e ireallymeanit=yes'

# NOTE: Restart the manager services to update the /etc/hosts file
sudo -iu dragon sh -c 'docker compose -f /opt/manager/docker-compose.yml restart'

# NOTE(berendt): wait for ara-server service
until [[ "$(/usr/bin/docker inspect -f '{{.State.Health.Status}}' manager-ara-server-1)" == "healthy" ]];
do
    sleep 1;
done;

sudo -iu dragon sh -c 'INTERACTIVE=false osism netbox disable testbed-switch-0'
sudo -iu dragon sh -c 'INTERACTIVE=false osism netbox disable testbed-switch-1'
sudo -iu dragon sh -c 'INTERACTIVE=false osism netbox disable testbed-switch-2'

# deploy helper services
sudo -iu dragon sh -c '/opt/configuration/scripts/001-helper-services.sh'

# deploy identity services
# NOTE: All necessary infrastructure services are also deployed.
if [[ "$DEPLOY_IDENTITY" == "true" ]]; then
    sudo -iu dragon sh -c '/opt/configuration/scripts/999-identity-services.sh'
fi

# deploy infrastructure services
if [[ "$DEPLOY_INFRASTRUCTURE" == "true" ]]; then
    sudo -iu dragon sh -c '/opt/configuration/scripts/002-infrastructure-services-basic.sh'
    sudo -iu dragon sh -c '/opt/configuration/scripts/006-infrastructure-services-extended.sh'
fi

# deploy ceph services
if [[ "$DEPLOY_CEPH" == "true" ]]; then
    sudo -iu dragon sh -c '/opt/configuration/scripts/003-ceph-services.sh'
fi

# deploy openstack services
if [[ "$DEPLOY_OPENSTACK" == "true" ]]; then
    if [[ "$DEPLOY_INFRASTRUCTURE" != "true" ]]; then
        echo "infrastructure services are necessary for the deployment of OpenStack"
    else
        sudo -iu dragon sh -c '/opt/configuration/scripts/004-openstack-services-basic.sh'
        sudo -iu dragon sh -c '/opt/configuration/scripts/009-openstack-services-baremetal.sh'
    fi
fi

# deploy monitoring services
if [[ "$DEPLOY_MONITORING" == "true" ]]; then
    sudo -iu dragon sh -c '/opt/configuration/scripts/005-monitoring-services.sh'
fi
