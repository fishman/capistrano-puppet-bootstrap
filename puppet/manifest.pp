#vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:
# include motd
package { ["libpq-dev", "libxslt-dev"]:
  ensure => "installed"
}
include stdlib
include augeas
include sudo
sudo::conf { 'sudoers':
  priority => 10,
  content  => "%sudo   ALL=(ALL:ALL) ALL\n",
}
sudo::conf { 'admins':
  priority => 10,
  content  => "%admin  ALL=(ALL) ALL\n",

  # Allow members of group sudo to execute any command
  

}
  
include apt
include nodejs
include postgresql
postgresql::user {'dbuser':
  ensure    => present,
  password  => 'hi'
}
postgresql::database {"db_production":
  ensure => present,
  owner  => dbuser,
}

include nginx
# node default {
# class { 'nginx': }
nginx::resource::upstream { 'cajuncodefest':
  ensure  => present,
  members => [
    'unix:/u/apps/cajuncodefest/shared/pids/myproj.0.sock',
    'unix:/u/apps/cajuncodefest/shared/pids/myproj.1.sock',
    'unix:/u/apps/cajuncodefest/shared/pids/myproj.2.sock',
  ],
}

include myproj
include wget
#include tomcat

Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

