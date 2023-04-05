# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  def self.filter_csv(filters)
    # filtering by created_at
    if filters['created_after'].present?
      where('created_at > ?', Time.zone.parse(filters['created_after']))
    end
    return if filters['created_before'].blank?

    where('created_at < ?', Time.zone.parse(filters['created_before']))
  end
end
