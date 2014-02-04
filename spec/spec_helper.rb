$LOAD_PATH << "." unless $LOAD_PATH.include?(".")

require 'rubygems'
require 'bundler/setup'
require 'simplecov'
#require 'active_record'
#require 'support/schema'

SimpleCov.start

require 'elastec'

RSpec.configure do |config|
  config.order = :random
end

$: << File.join(File.dirname(__FILE__), '..', 'lib')