# My FreeBSD Desktop Setup

Puppet code to setup my desktop environment in FreeBSD.
Continuing from a new FreeBSD (14.2-STABLE at the time of writing), these scripts install and configure a desktop environment and all of the default sofware that I need.

* Requires: Git


## Getting started

First we clone the repo and install Puppet Agent:
```sh
mkdir ~/code
cd ~/code
git clone https://github.com/adamretter/my-freebsd-desktop-setup.git
cd my-freebsd-desktop-setup
sudo ./install-puppet-agent.sh
```


## Running the setup

```sh
cd ~/code/my-freebsd-desktop-setup
sudo FACTER_default_user_password=some-password-here \
     puppet apply --modulepath=/usr/local/etc/puppet/modules:$(pwd)/modules:/usr/local/etc/puppet/vendor_modules .
```

