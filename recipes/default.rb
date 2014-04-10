#
# Cookbook Name:: gpg
# Recipe:: default
#
# Copyright 2011, AJ Christensen, Heavy Water Operations, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package node[:gpg][:package][:name] do
  version node[:gpg][:package][:version] if node[:gpg][:package][:version]
  action node[:gpg][:package][:action].to_sym
end

if(node[:gpg][:auto_generate])
  include_recipe 'gpg::generate'
end
