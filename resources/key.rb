property :id, String, name_property: true
property :key_server, String
property :content, String
property :source, String
property :user, String, default: 'root'
property :type, Symbol, default: :public

# Examples:
# gpg_key 'Load important key' do
#   key 'C8068B11'
#   key_server 'keyserver.ubuntu.com'
# end
#
# gpg_key 'C8068B11' do
#   key_server 'keyserver.ubuntu.com'
#   user 'bob'
# end

def after_created
  raise ArgumentError, "You must set either key_server, key_content, or key_source properties!" unless key_server || key_content || key_source
end

load_current_value do

end

action :import do

end
