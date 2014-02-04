require 'active_support/all'
require 'erb'
require 'elasticsearch'

require 'elastec/version'
require 'elastec/connection'
require 'elastec/indices'
require 'elastec/indexer'

module Elastec
  mattr_accessor :connection
  @@connection = nil

  mattr_accessor :indices_path
  @@config_path = nil # "#{Rails.root}/config/indexes" if defined?(Rails)
end
