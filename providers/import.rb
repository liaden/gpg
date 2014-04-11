require 'fileutils'

include GpgUtil
include Chef::Mixin::ShellOut
include Chef::Mixin::Checksum

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
      Chef::Log.warn "IMPORTING KEY FOR: #{new_resource.name} - #{key_type}"
      file = Tempfile.new('import')
      begin
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
          FileUtils.chown(new_resource.user, nil, file.path)
          cmd = shell_out!("sudo -u #{new_resource.user} -i gpg #{action.join(' ')} #{path}")
          key = (cmd.stdout + cmd.stderr).split("\n").detect do |line|
            line.start_with?('gpg: key ')
          end.to_s.split(' ')[2].to_s.sub(':', '')
          save_key_reference(key_type.to_s.split('_').first, new_resource.name, key)
          node.set[:gpg][:imported][key_type][new_resource.name] = cksum
          new_resource.updated_by_last_action(true)
        end
      ensure
        file.unlink
      end
    end
  end

end
