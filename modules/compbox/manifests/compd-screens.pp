
class compbox::compd-screens ( $git_root ) {

  require compbox::compd
  require coffeescript

  $compd_screens_root = "/srv/compd-screens"

# Compd itself declares this, puppet doesn't like it appearing twice!
#  package { ['python-virtualenv']:
#    ensure => present,
#    before => Vcsrepo["${compd_screens_root}"],
#  }

  # Checkout of compd-screens
  vcsrepo { "${compd_screens_root}":
    ensure => present,
    provider => git,
#    source => "${git_root}/compd/compd-screens.git",
    source => "git://github.com/prophile/compd-screens.git",
    revision => "origin/master",
    force => true,
    owner => 'compd',
    group => 'users',
  }

  exec { 'install-compd-screens':
    cwd => "${compd_screens_root}",
    command => "./install",
    provider => 'shell',
#    creates => "${compd_screens_root}/dep",
    user => 'compd',
    require => VcsRepo["${compd_screens_root}"],
  }

  # Also, some systemd goo to install the service.
  file { '/etc/systemd/system/compd-screens.service':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '644',
    source => 'puppet:///modules/compbox/compd-screens.service',
  }

  # Link in the systemd service to run in multi user mode.
  file { '/etc/systemd/system/multi-user.target.wants/compd-screens.service':
    ensure => link,
    target => '/etc/systemd/system/compd-screens.service',
    require => File['/etc/systemd/system/compd-screens.service'],
  }

  # systemd has to be reloaded before picking this up,
  exec { 'compd-screens-systemd-load':
    provider => 'shell',
    command => 'systemctl daemon-reload',
    onlyif => 'systemctl --all | grep compd-screens; if test $? = 0; then exit 1; fi; exit 0',
    require => [File['/etc/systemd/system/multi-user.target.wants/compd-screens.service'],
                Exec['install-compd-screens']],
  }

  # And finally maintain compd-screens being running.
  service { 'compd-screens':
    ensure => running,
    require => Exec['compd-screens-systemd-load'],
  }
}
