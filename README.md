# My FreeBSD Desktop Setup
Puppet code to setup my desktop environment in FreeBSD.
Continuing from a new FreeBSD (14.2-STABLE at the time of writing), these scripts install and configure a desktop environment and all of the default sofware that I need.

* Requires: Git

## Getting started
First we clone the repo and install Puppet Agent:
```sh
cd ~/code
git clone https://github.com/adamretter/my-freebsd-desktop-setup.git
cd my-freebsd-desktop-setup
sudo ./install-puppet-agent.sh
```
