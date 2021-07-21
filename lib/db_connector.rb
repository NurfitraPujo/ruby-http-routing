require 'mysql2'
require 'yaml'

class DatabaseConnection
  def initialize
    env_config = YAML.load_file('config.yml')
    @db_con = Mysql2::Client.new(
      host: env_config['db_host'],
      username: env_config['db_username'],
      password: env_config['db_password'],
      database: env_config['db_schema']
    )
    puts print_conn_success(env_config['db_host'])
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

  def db_client
    @db_con
  end
end
