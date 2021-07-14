require 'mysql2'

class DatabaseConnection
  attr_reader :db_con

  def initialize
    env_config = YAML.load_file(File.join(__dir__, 'config.yml'))
    @db_con = Mysql2::Client.new(
      host: env_config[:db_host],
      username: env_config[:db_username],
      password: env_config[:db_password]
    )
    print_conn_success
  rescue Mysql2::Error => e
    print_conn_error(e)
  end

  def print_conn_success(host)
    "Server has been connected to Mysql server in #{host}"
  end

  def print_conn_error(error)
    puts 'Failed to connect with mysql server'
    puts error
  end
end
