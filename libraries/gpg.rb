require 'fileutils'

module GpgUtil

  def save_key_reference(type, key, id)
    unless(%w(public private).include?(type.to_s))
      raise ArgumentError.new "Type argument must be 'public' or 'private'"
    end
    path = key_reference_file
    unless(node[:gpg][:key_reference])
      node.set[:gpg][:key_reference] = Mash.new
    end
    unless(node[:gpg][:key_reference][key])
      node.set[:gpg][:key_reference][key] = Mash.new
    end
    node.set[:gpg][:key_reference][key][type] = id
    File.open(path, 'w') do |file|
      file.write Chef::JSONCompat.to_json(
        node[:gpg][:key_reference]
      )
    end
  end

  def key_reference_file
    path = node[:gpg][:key_id_file]
    FileUtils.mkdir_p(File.dirname(path))
    path
  end

end
