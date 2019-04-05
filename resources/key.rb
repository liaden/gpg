property :batch_name, String,
         name_property: true,
         description: 'Name of  the key/batch to generate.'

property :override_default_keyring, [TrueClass, FalseClass],
         default: false,
         description: 'Set to true if you want to override the pubring_file and secring_file locations.'

property :pubring_file, String,
         description: 'Public keyring file location (override_default_keyring must be set to true or this option will be ignored)'

property :secring_file, String,
         description: 'Secret keyring file location (override_default_keyring must be set to true or this option will be ignored)'

property :user, String,
         default: 'root',
         description: 'User to generate the key for'

property :group, String,
         default: lazy { user },
         description: 'Group to run the generate command as'

property :key_type, String,
         default: '1', equal_to: %w(RSA 1 DSA 17 ),
         description: 'Corresponds to GPG option: Key-Type (RSA or DSA)'

property :key_length, String,
         default: '2048', equal_to: %w( 2048 4096 ),
         description: 'Corresponds to GPG option: Key-Length (2048 or 4096)'

property :name_real, String,
         default: lazy { "Chef Generated Default (#{batch_name})" },
         description: 'Corresponds to GPG option: Name-Real'

property :name_comment, String,
         default: 'generated by Chef',
         description: 'Corresponds to GPG option: Name-Comment'

property :name_email, String,
         default: lazy { "#{node.name}@example.com" },
         description: 'Corresponds to GPG option: Name-Email'

property :expire_date, String,
         default: '0',
         description: 'Corresponds to GPG option: Expire-Date. Defaults to 0 (no expiry)'

property :home_dir, String,
         default: lazy { ::File.expand_path("~#{user}/.gnupg") },
         description: 'Location to store the keyring. Defaults to ~/.gnupg'

property :batch_config_file, String,
         default: lazy { ::File.join(home_dir, "gpg_batch_config_#{batch_name}") },
         description: 'Batch config file name'

property :passphrase, String,
         sensitive: true,
         description: 'Passphrase for key'

property :key_file, String,
         description: 'Keyfile name'

property :key_fingerprint, String,
         description: 'Key finger print. Used to identify when deleting keys using the :delete action'

# Only Ubuntu supports the pinetree_mode. And requires it
property :pinentry_mode, [String, FalseClass],
default: lazy { node['platform_family'] == 'ubuntu' ? 'loopback' : false },
description: 'Pinentry mode. Set to loopback on Ubuntu and False (off) for all other platforms.'

property :batch, [TrueClass, FalseClass],
default: true,
description: 'Turn batch mode on or off when genrating keys'

action :generate do
  unless key_exists(new_resource)

    config_dir = ::File.dirname(new_resource.batch_config_file)

    directory config_dir do
      owner new_resource.user
      mode '0700'
      recursive true
      not_if { ::Dir.exist?(config_dir) }
    end

    file new_resource.batch_config_file do
      content <<~EOS
        Key-Type: #{new_resource.key_type}
        Key-Length: #{new_resource.key_length}
        Name-Real: #{new_resource.name_real}
        Name-Comment: #{new_resource.name_comment}
        Name-Email: #{new_resource.name_email}
        Expire-Date: #{new_resource.expire_date}
      EOS

      if new_resource.override_default_keyring
        content << "%pubring #{new_resource.pubring_file}\n"
        content << "%secring #{new_resource.secring_file}\n"
      end

      content << "Passphrase: #{new_resource.passphrase}" if new_resource.passphrase
      content << "%commit\n"
      mode '0600'
      owner new_resource.user
      sensitive true
    end

    cmd = gpg_cmd
    cmd << gpg_opts(new_resource) if new_resource.override_default_keyring
    cmd << " --passphrase #{new_resource.passphrase}"
    cmd << ' --yes'
    cmd << ' --batch' if new_resource.batch
    cmd << ' --pinentry-mode loopback' if new_resource.pinentry_mode
    cmd << " --gen-key #{new_resource.batch_config_file}"

    execute 'gpg2: generate' do
      command cmd
      live_stream true
      user new_resource.user
      group new_resource.group
    end

  end
end

action :import do
  execute 'gpg2: import key' do
    command "#{gpg_cmd} --import #{new_resource.key_file}"
    not_if { key_exists(new_resource) }
  end
end

action :export do
  execute 'gpg2: export key' do
    command "#{gpg_cmd} --export -a \"#{new_resource.name_real}\" > #{new_resource.key_file}"
    not_if { ::File.exist?(new_resource.key_file) }
  end
end

action :delete_public_key do
  execute 'gpg2: delete key' do
    command "#{gpg_cmd} --batch --yes --delete-key \"#{new_resource.key_fingerprint}\""
    only_if { key_exists(new_resource) }
  end
end

action :delete_secret_keys do
  execute 'gpg2: delete key' do
    command "#{gpg_cmd} --batch --yes --delete-secret-keys \"#{new_resource.key_fingerprint}\""
    only_if { key_exists(new_resource) }
  end
end

action_class do
  include Gpg::Helpers
end
