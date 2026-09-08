class Propriedade < ApplicationRecord
  belongs_to :produtor
  has_many :lotes, dependent: :restrict_with_error

  validates :nome, presence: true
  validates :status, presence: true
  validates :estado, length: { is: 2 }, allow_blank: true
end
