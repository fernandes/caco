module Caco::Postgres::ConfHelper
  def setup
    File.open("#{TMP_PATH}/postgresql.conf", File::RDWR|File::CREAT, 0644) do |f|
      f.write(postgresql_content)
    end
  end

  def teardown
    File.unlink("#{TMP_PATH}/postgresql.conf") if File.exist?("#{TMP_PATH}/postgresql.conf")
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
