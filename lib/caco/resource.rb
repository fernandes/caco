module Caco::Resource
  class Invalid < StandardError; end
end

require "caco/resource/base"
require "caco/resource/execute"
require "caco/resource/file"
require "caco/resource/package"
