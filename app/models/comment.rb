class Comment < ApplicationRecord
  belongs_to :article, inverse_of: :comments
  belongs_to :author, class_name: 'User', inverse_of: :comments

  validates :text, presence: true, limit: { minimum: 1, maximum: 1000 }
end
