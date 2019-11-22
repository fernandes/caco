module Caco
  module Haproxy
  end
end

require 'caco/haproxy/conf_get'
require 'caco/haproxy/conf_set'

# Templates
require 'caco/haproxy/cell/conf_postgres'
require 'caco/haproxy/cell/conf_stats'
