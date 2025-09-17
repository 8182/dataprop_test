class UfValue < ApplicationRecord
  validates :date, presence: true, uniqueness: true
  validates :value, presence: true, numericality: { greater_than: 0 }





end
  