require "rvm/capistrano"
require "bundler/capistrano"

set :application, "cajuncodefest"
set :repository,  "git@myrepo.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, "user"
set :group, "www-data"

role :web, "codefest"                          # Your HTTP server, Apache/etc
role :app, "codefest"                          # This may be the same as your `Web` server
role :db,  "codefest", :primary => true # This is where Rails migrations will run

set :deploy_via, :copy

set :rvm_type, :system

default_run_options[:pty] = true

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:setup", :setup_group
task :setup_group do
  try_sudo "gem install bundler thin"
  try_sudo "thin install"
  try_sudo "chown -R :#{group} #{deploy_to}"
  try_sudo "chmod -R g+s #{deploy_to}"
end
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do
    run "#{try_sudo} service thin start"
  end
  task :stop do
    run "#{try_sudo} service thin stop"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} service thin restart"
  end

  after 'deploy:update_code' do
    run "ln -nfs #{deploy_to}/shared/system/database.yml #{release_path}/config/database.yml"
  end
end

namespace :bootstrap do
  task :default do
    # Set the default_shell to "bash" so that we don't use the RVM shell which isn't installed yet...
    set :default_shell, "bash"
    # We tar up the puppet directory from the current directory -- the puppet directory within the source code repository
    system("tar czf 'puppet.tgz' puppet/")
    upload("puppet.tgz","/home/#{user}",:via => :scp)

    # Untar the puppet directory, and place at /etc/puppet -- the default location for manifests/modules
    run("tar xzf puppet.tgz ; rm puppet.tgz")
    try_sudo("rm -rf /etc/puppet")
    try_sudo("mv /home/#{user}/puppet/ /etc/puppet")

    # Bootstrap RVM/Puppet!
    try_sudo("bash /etc/puppet/bootstrap.sh")
    try_sudo("useradd -u 52 puppet")
    try_sudo("adduser rjelvah www-data")
  end
end

namespace :puppet do
  task :default do
    # Specific RVM string for managing Puppet; may or may not match the RVM string for the application
    set :rvm_ruby_string, '1.9.3-p125'

    # We tar up the puppet directory from the current directory -- the puppet directory within the source code repository
    system("tar czf 'puppet.tgz' puppet/")
    upload("puppet.tgz","/home/#{user}",:via => :scp)

    # Untar the puppet directory, and place at /etc/puppet -- the default location for manifests/modules
    run("tar xzf puppet.tgz ; rm puppet.tgz")
    try_sudo("rm -rf /etc/puppet")
    try_sudo("mv puppet/ /etc/puppet")

    # Run RVM/Puppet!
    try_sudo("puppet apply /etc/puppet/manifest.pp")
  end
end
