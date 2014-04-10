VALID_KEY_TYPES = ['RSA and RSA', 'DSA and Elgamal', 'DSA', 'RSA']

actions :create
default_action :create

attribute :key_type, :value_of => VALID_KEY_TYPES, :default => 'RSA'
attribute :key_length, :kind_of => Numeric, :default => 2048
attribute :key_usage, :kind_of => String
attribute :subkey_type, :kind_of => VALID_KEY_TYPES, :default => 'RSA'
attribute :subkey_length, :kind_of => Numeric, :default => 2048
attribute :subkey_usage, :kind_of => String
attribute :passphrase, :kind_of => String
attribute :name_real, :kind_of => String
attribute :name_comment, :kind_of => String
attribute :name_email, :kind_of => String
attribute :expire_date, :kind_of => [String, Numeric], :default => 0
attribute :creation_date, :kind_of => [DateTime, String, Numeric]
attribute :preferences, :kind_of => String
attribute :revoker, :kind_of => String
attribute :handle, :kind_of => String
attribute :keyserver, :kind_of => String

attribute :pubring, :kind_of => String
attribute :secring, :kind_of => String
attribute :user, :kind_of => String, :default => 'root'
