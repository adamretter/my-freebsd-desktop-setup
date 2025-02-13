# Set an SSH authorized key
#
# @param ensure Enum['present', 'absent']
#   Whether the ssh key should be present or absent. Defaults to 'present'.
# @param user [String]
#   The name of the user to authorized the SSH key for. Defaults to the current user.
# @param type [String]
#   The type of the SSH key. Defaults to 'ssh-rsa'.
# @param key [String]
#   The SSH key
#
define my::ssh_authorized_key (
    Enum['present', 'absent'] $ensure = 'present',
    String $user = $identity['user'],
    String $type = 'ssh-rsa',
    String $key
) {

  include my  # include defaults

  $user_home = $user ? {
    'root'  => '/root',
    default => "${my::home}/${user}",
  }

  file { "${title}@${user_home}/.ssh":
    ensure => directory,
    path   => "${user_home}/.ssh",
    owner  => $user,
    group  => $user,
    mode   => '0700',
  }

  file { "${title}@${user_home}/.ssh/authorized_keys":
    ensure  => file,
    path    => "${user_home}/.ssh/authorized_keys",
    owner   => $user,
    group   => $user,
    mode    => '0600',
    require => File["${title}@${user_home}/.ssh"],
  }

  file_line { "${title}@${user_home}/.ssh/authorized_keys":
    ensure  => present,
    path    => "${user_home}/.ssh/authorized_keys",
    line    => "${type} ${key} ${name}",
    match   => "^${type}\s${key}",
    require => File["${title}@${user_home}/.ssh/authorized_keys"],
  }
}
