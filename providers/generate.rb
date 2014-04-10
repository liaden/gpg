include Chef::Mixlib::ShellOut
include Chef::Mixlib::Checksum

VALID_BATCH_ATTRIBUTES = %w(
  key_type key_length key_usage subkey_type subkey_length subkey_usage
  passphrase name_real name_comment name_email expire_date creation_date
  preferences revoker handle keyserver
)

def load_current_resource
  unless(node[:gpg][:generated])
    node.set[:gpg][:generated] = Mash.new
  end
end

action :create do

  require 'tempfile'

  package 'haveged'

  Tempfile.new('batch') do |file|
    VALID_BATCH_ATTRIBUTES.each do |name|
      if(val = new_resource.send(name))
        file.puts [name.split('_').map(&:capitalize).join('-'), val].join(': ')
      end
    end
    %w(pubring secring).each do |name|
      if(val = new_resource.send(name))
        file.puts "%#{name} #{val}"
      end
    end
    file.puts "%commit"
    file.flush

    cksum = checksum(file.path) << "-#{new_resource.user}"

    if(node[:gpg][:generated][new_resource.name] != cksum)
      shell_out!("sudo -u #{new_resource.user} -i gpg --genkey #{file.path}")
      node.set[:gpg][:generated][new_resource.name] = cksum
      new_resource.updated_by_last_action(true)
    end

  end
end
