# frozen_string_literal: true

module CsvExports
  class UsersController < ApplicationController
    def index
      csv_export = create_csv_exports
      UserCsvExporterJob.perform_later(csv_export.id)
      render json: { csv_export: }, status: :accepted
    end

    private

    def create_csv_exports
      csv_export = CsvExport.new
      csv_export.user = current_user
      csv_export.filters = create_filters(params)
      csv_export.email = current_user.email
      csv_export.save!
      csv_export
    end

    def create_filters(params)
      filters = {}
      filters = params[:filters] if params[:filters].present?

      # Require at least one of the created filters; if both are cleared, default to 1 month ago.
      filters['created_after'] ||= 1.month.ago.to_s if filters['created_before'].blank?

      filters
    end
  end
end
