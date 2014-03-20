# Root this-is-compbox config file.
# Fans out to different kinds of services the competition vm hosts.

# git_root: The root URL to access the SR git repositories
class compbox( ) {

  # Default PATH
  Exec {
    path => [ "/usr/bin" ],
  }

  # Directory for 'installed flags' for various flavours of data. When some
  # piece of data is loaded from backup/wherever into a database, files here
  # act as a guard against data being reloaded.
  file { '/usr/local/var':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '755',
  }

  file { '/usr/local/var/sr':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '700',
    require => File['/usr/local/var'],
  }

  # Web stuff (basically everything this box does)
  class { "www":
    git_root => $git_root,
  }

}
