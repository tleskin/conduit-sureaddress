require 'conduit/sureaddress'
require 'conduit/sureaddress/driver'
require 'rspec/its'
include Conduit::Driver::Sureaddress

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |f|
  require f
end
