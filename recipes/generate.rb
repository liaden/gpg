include_recipe 'gpg'

gpg_generate 'Default' do
  key_type node[:gpg][:key_type]
  key_length node[:gpg][:key_length]
  name_real node[:gpg][:name][:real]
  name_comment node[:gpg][:name][:comment]
  name_email node[:gpg][:name][:email]
  expire_date node[:gpg][:exipre][:date]
end
