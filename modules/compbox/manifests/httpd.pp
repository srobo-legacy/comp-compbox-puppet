# Primary webserver configuration. The server part that is, not what gets served

class httpd( $web_root_dir ) {
  # Use apache + mod_ssl to serve, wsgi for python services
  package { [ "httpd", "mod_wsgi",]:
    ensure => latest,
  }

  # Ensure /var/www belongs to wwwcontent, allowing vcsrepos to be cloned
  # into it.
  file { '/var/www':
    ensure => directory,
    owner => 'wwwcontent',
    group => 'apache',
    mode => '755',
  }

  # CompBox specific http config
  file { "compbox.conf":
    path => "/etc/httpd/conf.d/compbox.conf",
    owner => root,
    group => root,
    mode => "0600",
    content => template('www/compbox.conf.erb'),
    require => Package[ "httpd" ],
  }

  # The webserver process itself; restart on updates to some important files.
  service { "httpd":
    enable => true,
    ensure => running,
    subscribe => [Package[ "httpd" ]]
  }
}
