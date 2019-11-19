module Caco::Postgres::ConfHelper
  def setup
    @tmp_path = File.join(ROOT_PATH, "tmp")
    File.open("#{@tmp_path}/postgresql.conf", File::RDWR|File::CREAT, 0644) do |f|
      f.write(postgresql_content)
    end
  end

  def teardown
    File.unlink("#{@tmp_path}/postgresql.conf") if File.exist?("#{@tmp_path}/postgresql.conf")
  end

  def postgresql_content
    <<~EOF
    aug = on
    #param1 = on
    #param2 = 'on'
    #param3 on
    param4 = on
    param5 = 'on'
    param6 on
    EOF
  end
end
