# frozen_string_literal: true

class UserCsvExporterJob < ApplicationJob
  attr_reader :csv_export

  queue_as :default

  def perform(csv_export_id)
    starting(csv_export_id)

    users = fetch_data
    csv, rows_count = UserCsvGenerate.call(users)

    upload_to_s3(csv, csv_export)

    finishing(rows_count)

    NotifyUserService.csv_exported(csv_export)
  rescue StandardError => e
    log(:error, 'Failed with unhandled exception')
    csv_export.fail!
    raise e
  end

  private

  def starting(csv_export_id)
    log(:info, 'Starting')
    @csv_export = CsvExport.find(csv_export_id)
    csv_export.start!
  end

  def fetch_data
    users = User.filter_csv(csv_export.filters)
    log(:info, "Finished query! num_rows: #{users.size}")
    users
  end

  def upload_to_s3(csv, csv_export)
    filename = "#{csv_export.user.id.to_s.rjust(10, '0')}_#{Time.now.to_i}.csv"

    csv_export.s3_path = "exports/#{filename}"
    s3 = AwsS3Client.new(bucket: CsvExport::S3_BUCKET, key: csv_export.s3_path)
    s3.put_file(source_file: csv, content_type: 'text/csv')
    log(:info, "Finished uploading file! export_path: #{csv_export.s3_path}")
  end

  def finishing(rows_count)
    csv_export.row_count = rows_count - 1
    csv_export.finish!
    log(:info, message: 'Finished!')
  end

  def log(level, message)
    logger.send(level, "CsvExporter: #{message}")
  end
end
