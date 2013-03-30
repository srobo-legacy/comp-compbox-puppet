
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
    creates => "${compd_screens_root}/dep",
    user => 'compd',
    require => VcsRepo["${compd_screens_root}"],
  }

}
