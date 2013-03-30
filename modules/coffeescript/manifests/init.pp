
# Get CoffeeScript
class coffeescript( ) {

  require nodejs

  exec { 'install-coffee-script':
    command => "npm install -g coffee-script",
    provider => 'shell',
    creates => '/usr/bin/coffee',
  }

}
