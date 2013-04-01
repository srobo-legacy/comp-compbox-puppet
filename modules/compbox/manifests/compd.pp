
class compbox::compd ( $git_root ) {

  $compd_root = "/srv/compd"

  package { ['redis', 'python-redis', 'python-virtualenv']:
    ensure => present,
    before => Vcsrepo["${compd_root}"],
  }

  # A user to run as
  user { 'compd':
    ensure => present,
    comment => 'Competition Daemon',
    shell => '/sbin/nologin',
    gid => 'users',
  }

  file { '/home/compd':
    ensure => directory,
    owner => 'compd',
    group => 'users',
    mode => '700',
    require => User['compd'],
  }

  # Checkout of compd
  vcsrepo { "${compd_root}":
    ensure => present,
    provider => git,
#    source => "${git_root}/compd/compd.git",
    source => "git://github.com/prophile/compd.git",
    revision => "origin/master",
    force => true,
    owner => 'compd',
    group => 'users',
    require => User['compd'],
  }

  exec { 'install-compd':
    cwd => "${compd_root}",
    command => "./install",
    provider => 'shell',
    creates => "${compd_root}/dep",
    user => 'compd',
    require => [User['compd'],VcsRepo["${compd_root}"]],
  }

  # Also, some systemd goo to install the service.
  file { '/etc/systemd/system/compd.service':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '644',
    source => 'puppet:///modules/compbox/compd.service',
  }

  # Link in the systemd service to run in multi user mode.
  file { '/etc/systemd/system/multi-user.target.wants/compd.service':
    ensure => link,
    target => '/etc/systemd/system/compd.service',
    require => File['/etc/systemd/system/compd.service'],
  }

  # systemd has to be reloaded before picking this up,
  exec { 'compd-systemd-load':
    provider => 'shell',
    command => 'systemctl daemon-reload',
    onlyif => 'systemctl --all | grep compd; if test $? = 0; then exit 1; fi; exit 0',
    require => File['/etc/systemd/system/multi-user.target.wants/compd.service'],
  }

  # And finally maintain compd being running.
  service { 'compd':
    ensure => running,
    require => Exec['compd-systemd-load'],
  }
}
