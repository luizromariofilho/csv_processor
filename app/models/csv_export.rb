# frozen_string_literal: true

class CsvExport < ApplicationRecord
  include AASM

  EXPIRATION_PERIOD = 1.week
  S3_BUCKET = ENV.fetch('CSV_EXPORTS_BUCKET', nil)

  belongs_to :user

  enum state: { pending: 0, started: 1, finished: 2, failed: 3 }

  aasm column: :state, enum: true, timestamps: true do
    after_all_transitions :log_status_change

    state :pending, initial: true
    state :started
    state :finished
    state :failed

    event :start do
      transitions from: :pending, to: :started
    end
    event :finish do
      transitions from: :started, to: :finished
    end
    event :fail do
      transitions from: %i[pending started], to: :failed
    end
  end

  def log_status_change
    message = "Changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
    logger.info message
  end

  def expires_at
    created_at + EXPIRATION_PERIOD
  end

  def expired?
    Time.zone.now > expires_at
  end
end
