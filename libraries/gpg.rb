module GpgUtil

  def save_key_reference(type, key, id)
    unless(%w(public private).include?(type.to_s))
      raise ArgumentError.new "Type argument must be 'public' or 'private'"
    end
    path = node[:gpg][:key_id_file]
    unless(node[:gpg][:key_reference])
      node.set[:gpg][:key_reference] = Mash.new
    end
    unless(node[:gpg][:key_reference][key])
      node.set[:gpg][:key_reference][key] = Mash.new
    end
    node.set[:gpg][:key_reference][key][type] = id
    File.open(path, 'w') do |file|
      file.write JSONCompat.to_json(
        node[:gpg][:key_reference]
      )
    end
  end

end
