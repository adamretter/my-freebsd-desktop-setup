# Simple wrapper around Puppet's `package` resource type.
#
# @param package_names [String, Array[String]]
#   The names of the packages, if undefined the 'title' is used.
# @param ensure [Enum['installed', 'absent']]
#   Whether the package should be installed or absent. Defaults to 'installed'.
# @param provider [String]
#   The packaging system provider. Defaults to `$my::default_package_provider`.
#
define my::package (
    Variant[String, Array[String, 1]] $package_names = $title,
    Enum['installed', 'absent'] $ensure = 'installed',
    Enum['portsng', 'ports', 'pkg', 'apt', 'deb', 'yum', 'rpm'] $provider = $my::default_package_provider
) {
  package { "${title}@package":
    ensure   => $ensure,
    name     => $package_names,
    provider => $provider,
  }
}
