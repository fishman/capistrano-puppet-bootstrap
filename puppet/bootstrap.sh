#!/bin/bash

# Update our package manager...
sudo apt-get update
# Install dependencies for RVM and Ruby...
sudo apt-get install -y build-essential libxslt1-dev libxml2-dev libreadline-dev zlib1g-dev libssl-dev curl git-core libreadline-dev autoconf

# Get and install RVM
curl -L https://get.rvm.io | sudo bash -s stable

# Source rvm.sh so we have access to RVM in this shell
source /etc/profile.d/rvm.sh

# Install Ruby 1.9.3-125
rvmsudo rvm install 1.9.3-p327
rvmsudo rvm alias create default 1.9.3-p327

source /etc/profile.d/rvm.sh

# Update rubygems, and pull down facter and then puppet...
rvmsudo rvm 1.9.3-p125 do gem update --system
rvmsudo rvm 1.9.3-p125 do gem install facter --no-ri --no-rdoc
rvmsudo rvm 1.9.3-p125 do gem install puppet --no-ri --no-rdoc
rvmsudo rvm 1.9.3-p125 do gem install libshadow --no-ri --no-rdoc

# Create necessary Puppet directories...
sudo mkdir -p /etc/puppet /var/lib /var/log /var/run
