require 'fileutils'

include Chef::Mixin::ShellOut
include Chef::Mixin::Checksum
include GpgUtil

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

  file = Tempfile.new('batch')
  begin
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
      FileUtils.chown(new_resource.user, nil, file.path)
      cmd = shell_out!("sudo -u #{new_resource.user} -i gpg --genkey #{file.path}")
      output = cmd.stdout + cmd.stderr
      public_key = output.split("\n").detect do |line|
        line.start_with?('pub')
      end.to_s.split(' ')[1].to_s.split('/').last
      private_key = output.split("\n").detect do |line|
        line.start_with('sub')
      end.to_s.split(' ')[1].to_s.split('/').last
      save_key_reference(:public, new_resource.name, public_key) unless public_key.empty?
      save_key_reference(:private, new_resource.name, private_key) unless private_key.empty?
      node.set[:gpg][:generated][new_resource.name] = cksum
      new_resource.updated_by_last_action(true)
    end
  ensure
    file.unlink
  end
end
