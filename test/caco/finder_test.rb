require "test_helper"

class Caco::FinderTest < Minitest::Test
  def test_finding_regexp_on_output
    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, output_data], ['dpkg -l']

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      result = described_class.(params: { command: "dpkg -l", regexp: /^ii\s+postgresql-11/ })
      assert result.success?
    end

    @commander.verify
  end

  def test_not_finding_regexp_on_output
    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, output_data], ['dpkg -l']

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      result = described_class.(params: { command: "dpkg -l", regexp: /^ii\s+postgresql-12/ })
      assert result.failure?
    end

    @commander.verify
  end

  def output_data
    <<~EOF
    ii  pinentry-curses                    1.0.0-2                amd64                  curses-based PIN or pass-phrase entry dialog for GnuPG
    ii  postgresql-11                      11.6-1.pgdg90+1        amd64                  object-relational SQL database, version 11 server
    rc  postgresql-12                      12.1-1.pgdg90+1        amd64                  object-relational SQL database, version 12 server
    EOF
  end
end
