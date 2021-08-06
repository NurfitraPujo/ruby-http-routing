require 'mysql2'
require 'yaml'
require 'singleton'
require 'config'

class DatabaseConnection
  include Singleton
  @@environtment = 'development'

  def initialize
    env_config = YAML.load_file('./config/config.yml')[@@environtment]
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

  def self.test_environtment
    @@environtment = 'test'
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
