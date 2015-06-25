require 'conduit/sure_address'
require 'conduit/sure_address/driver'
require 'rspec/its'
include Conduit::Driver::SureAddress

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |f|
  require f
end
