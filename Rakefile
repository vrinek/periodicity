require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/periodicity'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'periodicity' do
  self.developer              'Kostas Karachalios', 'kostas.karachalios@me.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.extra_deps           = [['activesupport','>= 2.3.2']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
remove_task :default
task :default => :spec
