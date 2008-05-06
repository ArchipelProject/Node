#!/usr/bin/ruby
# 
# Copyright (C) 2008 Red Hat, Inc.
# Written by Scott Seago <sseago@redhat.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.  A copy of the GNU General Public License is
# also available at http://www.gnu.org/copyleft/gpl.html.

$: << File.join(File.dirname(__FILE__), "../app")
$: << File.join(File.dirname(__FILE__), "../vendor/plugins/betternestedset/lib")

require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_pack'
require 'action_controller'
require 'action_view'
require 'erb'
require '/usr/share/ovirt-wui/vendor/plugins/betternestedset/init.rb'

def database_connect
  $dbconfig = YAML::load(ERB.new(IO.read('/usr/share/ovirt-wui/config/database.yml')).result)
  $develdb = $dbconfig['development']
  ActiveRecord::Base.establish_connection(
                                          :adapter  => $develdb['adapter'],
                                          :host     => $develdb['host'],
                                          :username => $develdb['username'],
                                          :password => $develdb['password'],
                                          :database => $develdb['database']
                                          )
end

database_connect

require 'models/pool.rb'
require 'models/permission.rb'
require 'models/quota.rb'

require 'models/hardware_pool.rb'
require 'models/host.rb'
require 'models/nic.rb'

require 'models/vm_resource_pool.rb'
require 'models/vm.rb'

require 'models/task'
require 'models/host_task.rb'
require 'models/storage_task.rb'
require 'models/vm_task.rb'

require 'models/storage_pool.rb'
require 'models/iscsi_storage_pool.rb'
require 'models/nfs_storage_pool.rb'

require 'models/storage_volume.rb'
require 'models/iscsi_storage_volume.rb'
require 'models/nfs_storage_volume.rb'