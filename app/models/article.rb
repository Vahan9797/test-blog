class Article < ApplicationRecord
  belongs_to :creator, class_name: 'User', inverse_of: :articles
  has_many :comments, inverse_of: :article, dependent: :destroy

  validates :title, presence: true, limit: { minimum: 1, maximum: 100 }
end
