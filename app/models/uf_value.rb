class UfValue < ApplicationRecord
  self.primary_key = :uf_date
  attribute :uf_date, :date

  validates :uf_date, presence: true, uniqueness: true
  validates :uf_value, presence: true, numericality: { greater_than: 0 }


end
