include Chef::Mixlib::ShellOut

def load_current_resource
  unless(node[:gpg][:imported])
    node.set[:gpg][:imported] = Mash.new(
      :public_key => Mash.new,
      :private_key => Mash.new
    )
  end
end

action :import do

  [:public_key, :private_key].each do |key_type|
    if(key_val = new_resource.send(key_type))
      Tempfile.new('import') do |file|
        path = nil
        unless(::File.exists?(key_val))
          file.puts key_val
          file.flush
          path = file.path
        else
          path = key_val
        end

        cksum = checksum(path) << "-#{new_resource.user}"

        if(node[:gpg][:imported][key_type][new_resource.name] != cksum)
          action = ['--import']
          action.push('--allow-secret-key-import') if key_type == :private_key
          shell_out!("sudo -u #{new_resource.user} -i gpg #{action.join(' ')} #{path}")
          node.set[:gpg][:imported][key_type][new_resource.name] = cksum
          new_resource.updated_by_last_action(true)
        end
      end
    end
  end

end
