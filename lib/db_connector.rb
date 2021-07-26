require 'mysql2'
require 'yaml'
require 'singleton'

class DatabaseConnection
  include Singleton

  def initialize
    env_config = YAML.load_file('./config/database.yml')
    @db_con = Mysql2::Client.new(
      host: env_config['db_host'],
      username: env_config['db_username'],
      password: env_config['db_password'],
      database: env_config['db_schema']
    )
    puts print_conn_success(env_config['db_host'])
    @db_con.query_options.merge!(symbolize_keys: true)
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

  def query(sql, options = {})
    @db_con.query(sql, **options)
  end

  def transaction
    raise ArgumentError, 'No block was given' unless block_given?

    begin
      @db_con.query('BEGIN')
      yield
      @db_con.query('COMMIT')
    rescue StandardError => e
      puts e
      @db_con.query('ROLLBACK')
    end
  end
end
