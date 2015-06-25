require 'conduit/sureaddress/version'
require 'conduit/sureaddress/configuration'
require 'conduit/sureaddress/request_mocker'
require 'conduit/sureaddress/decorators'
require 'conduit'

Conduit.configure do |config|
  config.driver_paths << File.join(File.dirname(__FILE__), 'sureaddress')
end
