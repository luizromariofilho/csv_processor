# frozen_string_literal: true

require 'aws-sdk-s3'
class AwsS3Client
  attr_reader :bucket, :key

  def initialize(bucket:, key:)
    @bucket = bucket
    @key = key
  end

  def put_file(source_file:, content_type:)
    #  Placeholder function
  end
end
