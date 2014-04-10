actions :import
default_action :import

attribute :public_key, :kind_of => String
attribute :private_key, :kind_of => String
attribute :user, :kind_of => String, :default => 'root'
