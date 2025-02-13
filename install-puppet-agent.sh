#!/usr/bin/env bash

set -e

PUPPET_VER=8
PUPPET_BIN=/opt/puppetlabs/bin/puppet

PUPPET_INSTALLED=false

# FreeBSD Ports
if [[ "$(uname)" == 'FreeBSD' ]]; then
	pkg info puppet$PUPPET_VER > /dev/null && pkg_exit_code=$? || pkg_exit_code=$? ; true
	if [[ ${pkg_exit_code} -ne 0 ]]; then
		# Puppet is not installed
		if [ -d "/usr/ports/sysutils/puppet$PUPPET_VER" ]; then
			# If ports are present, install from ports
			pushd /usr/ports/sysutils/puppet$PUPPET_VER
			BATCH=yes make install clean
			popd
		else
			# Else, install from pkg
			pkg install -y puppet$PUPPET_VER
		fi
		PUPPET_BIN=/usr/local/bin/puppet
		PUPPET_INSTALLED=true
	fi

# RHEL 7 compatible
elif [ -n "$(command -v rpm)" ]; then
	rpm -Uvh https://yum.puppet.com/puppet$PUPPET_VER-release-el-7.noarch.rpm
	yum -y install puppet-agent
	PUPPET_INSTALLED=true

# Debian compatible
elif [ -n "$(command -v dpkg)" ]; then
	DISTRO_CODENAME="$(lsb_release -sc)"
	pushd /tmp
	wget https://apt.puppetlabs.com/puppet$PUPPET_VER-release-$DISTRO_CODENAME.deb
	dpkg -i puppet$PUPPET_VER-release-$DISTRO_CODENAME.deb
	rm puppet$PUPPET_VER-release-$DISTRO_CODENAME.deb
	popd
	apt-get update
	apt-get install -y puppet-agent
	PUPPET_INSTALLED=true
fi

if [[ $PUPPET_INSTALLED != "true" ]]; then
	echo "Could not locate ports, pkg, rpm, or dpkg to install puppet"
	exit 1
fi

$PUPPET_BIN module install puppetlabs-stdlib
$PUPPET_BIN module install saz-ssh
$PUPPET_BIN module install puppetlabs-sshkeys_core
$PUPPET_BIN module install puppetlabs-vcsrepo
$PUPPET_BIN module install puppetlabs-augeas_core
$PUPPET_BIN module install puppetlabs-inifile

if [ -n "$(command -v yum)" ]; then
	$PUPPET_BIN module install puppet-yum

elif [ -n "$(command -v apt)" ]; then
	$PUPPET_BIN module install puppetlabs-apt
	$PUPPET_BIN module install domkrm-ufw
fi
