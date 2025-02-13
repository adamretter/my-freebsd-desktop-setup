# Set the default Editor.
#
# @param user [String]
#   The name of the user to set the editor for. Defaults to the current user.
# @param editor_package_name [String]
#   The name of the package to install that contains the Editor. If undefined the 'title' is used
# @param package_provider [String]
#   The packaging system provider. Defaults to `$my::default_package_provider`.
#
define my::editor (
    String $user = $identity['user'],
    String $editor_package_name = $title,
    Enum['portsng', 'ports', 'pkg', 'apt', 'deb', 'yum', 'rpm'] $package_provider = $my::default_package_provider
) {

  $user_home = $user ? {
    'root'  => '/root',
    default => "${my::home}/${user}",
  }

  my::package { "${title}@my::package":
    ensure        => installed,
    package_names => $editor_package_name,
    provider      => $package_provider,
  }

  $cshrc = "${user_home}/.cshrc"
  if find_file($cshrc) {
    file_line { "${title}@${cshrc}":
      ensure  => present,
      path    => $cshrc,
      line    => 'setenv  EDITOR  vim',
      match   => '^EDITOR\=',
      require => [
        My::Package["${title}@my::package"],
      ],
    }
  }

  $profile = "${user_home}/.profile"
  if find_file($profile) {
    file_line { "${title}@${profile}":
      ensure  => present,
      path    => $profile,
      line    => 'EDITOR=vim;      export EDITOR',
      match   => '^EDITOR\=',
      require => [
        My::Package["${title}@my::package"],
      ],
    }
  }

  $zshrc = "${user_home}/.zshrc"
  if find_file($zshrc) {
    file_line { "${title}@${zshrc}":
      ensure  => present,
      path    => $zshrc,
      line    => 'export EDITOR=vim',
      match   => '^export EDITOR\=',
      require => [
        My::Package["${title}@my::package"],
      ],
    }
  }
}
