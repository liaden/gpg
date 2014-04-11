include_recipe 'gpg'

data_bag(node[:gpg][:databag]).each do |key_name|
  val = Mash.new(Chef::EncryptedDataBagItem.load(node[:gpg][:databag], key_name).to_hash)

  gpg_import key_name do
    val.each do |key, value|
      next if key.to_s == 'id'
      self.send(key, value)
    end
  end

end
