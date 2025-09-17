class UfValue < ApplicationRecord
  validates :uf_date, presence: true, uniqueness: true
  validates :uf_value, presence: true, numericality: { greater_than: 0 }


end
