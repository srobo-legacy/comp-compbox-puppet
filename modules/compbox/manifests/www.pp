# Primary file for the www module - all this does is include other puppet files
# to configure portions of the website.

class www( $git_root ) {
  $web_root_dir = '/var/www/html'
  $git_root = 'git://srobo.org'

  class { 'httpd':
    web_root_dir => $web_root_dir,
  }

  # We shouldn't let apache own any web content, lest it be able to edit
  # content rather than just serve it. So, all web content that doesn't have
  # a more appropriate user gets owned by wwwcontent (with group=apache).
  user { 'wwwcontent':
    ensure      => present,
    comment     => 'Owner of all/most web content',
    shell       => '/bin/sh',
    gid         => 'apache',
    managehome  => true,
    require     => Package['httpd'],
  }

  # Web facing user competition state interface, srobo.org/comp-api
  class { 'comp-api':
    git_root => $git_root,
    root_dir => '/srv/sr-comp-http',
    require => User['wwwcontent'],
  }

  # Machine index web page. Really simple, just lists the things it serves
  file { "${web_root_dir}/index.html":
    ensure  => present,
    owner   => 'wwwcontent',
    group   => 'apache',
    mode    => '0644',
    source  => 'puppet:///modules/compbox/comp-api.wsgi',
  }

  # Screens, mainly for the arenas
  vcsrepo { "${web_root_dir}/screens":
    ensure    => present,
    provider  => git,
    source    => "${git_root}/comp/srcomp-screens.git",
    revision  => 'origin/master',
    force     => true,
    owner     => 'wwwcontent',
    group     => 'apache',
  }

  # Views for the shepherds
  vcsrepo { "${web_root_dir}/shepherding":
    ensure    => present,
    provider  => git,
    source    => "${git_root}/srcomp-shepherding.git",
    revision  => 'origin/master',
    force     => true,
    owner     => 'wwwcontent',
    group     => 'apache',
  }

}
