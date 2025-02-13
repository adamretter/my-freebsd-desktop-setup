###
# Puppet Script for a Base System on FreeBSD 14.2-STABLE
###

include my

$default_user = 'freebsd'
$default_user_home = "${my::home}/${default_user}"

# configure the 'freebsd' user and their home folder
my::package { 'zsh':
}

$base_zshrc = @("BASE_ZSHRC_EOF"/L)
  # Lines configured by zsh-newuser-install
  HISTFILE=~/.histfile
  HISTSIZE=1000
  SAVEHIST=1000
  unsetopt autocd
  bindkey -v
  # End of lines configured by zsh-newuser-install
  # The following lines were added by compinstall
  zstyle :compinstall filename '${default_user_home}/.zshrc'

  autoload -Uz compinit
  compinit
  # End of lines added by compinstall
  | BASE_ZSHRC_EOF

file { 'base_zshrc':
  ensure  => file,
  path    => "${default_user_home}/.zshrc",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  content => $base_zshrc,
  require => [
    File['default_user_home'],
    My::Package['zsh'],
  ],
}

group { 'default_user':
  ensure => present,
  name   => $default_user,
}

$zsh_bin = $os['name'] ? {
  /(FreeBSD|OpenBSD|NetBSD)/ => '/usr/local/bin/zsh',
  'MacOS'                    => '/bin/zsh',
  default                    => '/usr/bin/zsh',
}

user { 'default_user':
  ensure     => present,
  name       => $default_user,
  gid        => $default_user,
  groups     => [
    'wheel',
  ],
  comment    => "${default_user} default user",
  managehome => true,
  shell      => $zsh_bin,
  password   => pw_hash($default_user_password, 'SHA-512', 'mysalt'),
  require    => [
    Group['default_user'],
    My::Package['zsh'],
  ],
}

file { 'default_user_home':
  ensure  => directory,
  path    => $default_user_home,
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0750',
  require => User['default_user'],
}

file { 'default_user_code_folder':
  ensure  => directory,
  path    => "${default_user_home}/code",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  require => File['default_user_home'],
}

my::ssh_authorized_key { 'aretter@hollowcore.local':
  ensure  => present,
  user    => $default_user,
  type    => 'ssh-rsa',
  key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDHvJ21M2Jfw75K82bEdZIhL9t7N8kUuXOPxKWFs7o6Z+42UGH47lmQrk95OJdhLxlp2paGFng++mMLV1Xf7uLjTUE8lJHJv/TSzC81Q5NSfFXQTn4kpr5BRKgTnXPNYTHcsueeUr6auZDThVG3mU62AvieFeI5MJOE7FlAS4++u2pVG7+H4l48snlKiUDH5oXRLdJtZbED2v6byluSkj6uNThEYoHzHRxvF8Lo12NgQEMBVrHyvBWtHPpZIhCzzzsTEf9+249VqsO3NqTl7vswMhf8z2NYgGjf0w+5A3bJDIpvDRWQ+40uB1bdwqUDuiY8nGSSKwpVOby0cYZjfhjZ',
  require => File['default_user_home'],
}

my::editor { 'vim':
  user                => $default_user,
  editor_package_name => 'vim',
}

my::package { 'ohmyzsh':
  require  => [
    My::Package['zsh'],
    File['base_zshrc'],
    File['default_user_home'],
  ],
}

# # setup default firewall rules
# file_line { 'pf_enable':
#   ensure => present,
#   path   => '/etc/rc.conf',
#   line   => 'pf_enable="YES"',
#   match  => '^pf_enable\=',
# }

# service { 'pf':
#   ensure  => running,
#   require => File_line['pf_enable'],
# }

# ufw::allow { 'ssh':
#   port    => '22',
#   require => Class['ssh'],
# }

# install miscellaneous system packages
my::package { 'chrony': }

service { 'chronyd':
  ensure  => running,
  enable  => true,
  require => My::Package['chrony'],
}

my::package { [
    'curl',
    'wget',
    'git',
    'file',
    'zip',
    'unzip',
    'gzip',
    'bzip2',
    'zstd',
    'screen',
]: }
