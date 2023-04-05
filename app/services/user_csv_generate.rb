# frozen_string_literal: true

require 'csv'
class UserCsvGenerate
  attr_reader :users, :logger

  def self.call(users)
    new(users).call
  end

  def initialize(users)
    @users = users
    @logger = Logger.new($stdout)
  end

  def call
    log(:info, "Finished generate rows! num_rows: #{csv_rows.size}")
    rows_count = 0
    CSV.open(file.path, 'wb') do |csv_file|
      csv_rows.each do |row|
        rows_count += 1
        csv_file << row
      end
    end
    log(:info, "Finished writing file! local_path: #{file.path}")
    [file, rows_count]
  end

  private

  def file
    Tempfile.new("tmp_csv_#{Time.now.to_i}.csv")
  end

  def csv_rows
    rows = []
    rows << headers
    users.each do |user|
      rows << [user.name, user.username, user.email]
    end
    rows
  end

  def headers
    %i[name username email]
  end

  def log(level, message)
    logger.send(level, "CsvGenerate: #{message}")
  end
end
