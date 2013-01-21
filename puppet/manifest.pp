#vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:
# include motd
include stdlib
include augeas
include sudo
include apt
include nodejs
include postgresql
include nginx
include stuff
include wget

firewall { '000 accept all icmp requests':
  proto  => 'icmp',
  action => 'accept',
}
firewall { '002 allow all to lo interface':
  iniface => 'lo',
  action  => 'accept',
}
firewall { '100 allow http':
  proto  => 'tcp',
  dport  => '80',
  action => 'accept',
}
firewall { '100 allow ssh':
  proto  => 'tcp',
  dport  => '22',
  action => 'accept',
}
firewall { '999 drop everything else':
  action => 'drop',
}

package { ['libpq-dev', 'libxslt-dev', 'pkg-config']:
  ensure => 'installed'
}
package { 'ruby-augeas':
  ensure   => 'installed',
  provider => 'gem',
}

augeas { 'sshd_config':
  context => '/files/etc/ssh/sshd_config',
  changes => [
    # track which key was used to logged in
    'set PermitRootLogin no',
    'set PasswordAuthentication no',
  ],
  notify  => Service['sshd'],
}

service { 'sshd':
  ensure  => running,
  name    => $operatingsystem ? {
    ubuntu  => 'ssh',
    default => 'sshd',
  },
  require => Augeas['sshd_config'],
  enable  => true,
}
sudo::conf { 'sudoers':
  priority => 10,
  content  => "%sudo   ALL=(ALL:ALL) ALL\n",
}
sudo::conf { 'admins':
  priority => 10,
  content  => "%admin  ALL=(ALL) ALL\n",
  # Allow members of group sudo to execute any command
}

postgresql::user {'dbuser':
  ensure    => present,
  password  => 'yourpass'
}
postgresql::database {'db_production':
  ensure => present,
  owner  => dbuser,
}

# node default {
# class { 'nginx': }
nginx::resource::upstream { 'cajunstuff':
  ensure  => present,
  members => [
    'unix:/u/apps/cajunstuff/shared/pids/stuff.0.sock',
    'unix:/u/apps/cajunstuff/shared/pids/stuff.1.sock',
    'unix:/u/apps/cajunstuff/shared/pids/stuff.2.sock',
  ],
}

#include tomcat

Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin' }

