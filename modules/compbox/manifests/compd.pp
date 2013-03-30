
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

}
