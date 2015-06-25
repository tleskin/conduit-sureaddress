require 'delegate'
require 'forwardable'

module Conduit::Sureaddress::Decorators
  class Base < SimpleDelegator
    extend Forwardable
  end
end
