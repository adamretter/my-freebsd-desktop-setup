# Defaults
class my {
  $default_package_provider = 'portsng'

  $home = $os['name'] ? {
    /(FreeBSD|OpenBSD|NetBSD)/ => '/usr/home',
    'MacOS'                    => '/Users',
    default                    => '/home',
  }
}
