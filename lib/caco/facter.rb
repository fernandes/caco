module Caco::Facter
  class KeyNotFoundError < StandardError; end

  module ClassMethods
    @@fake_data = nil

    def set_fake_data=(data)
      @@fake_data = data
    end

    def use_fake(data, &block)
      old_fake_data = @@fake_data
      @@fake_data = data

      yield

      @@fake_data = old_fake_data
    end

    def call(*items)
      value = json_data.dig(*items)
      raise KeyNotFoundError.new("#{items.join(":")} not found") unless value
      value
    end

    private
      def json_data
        return @@fake_data unless @@fake_data.nil?

        @@parsed_data ||= JSON.parse(external_facter_data)
      end

      def external_facter_data
        success, exit_code, output = Caco::Executer.(command: "facter -j")
        output
      end
  end

  extend ClassMethods
end
