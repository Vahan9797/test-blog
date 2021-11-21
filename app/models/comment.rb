class Comment < ApplicationRecord
  belongs_to :article, inverse_of: :comments
  belongs_to :author, class_name: 'User', inverse_of: :comments, foreign_key: :user_id

  validates :text, length: { minimum: 1, maximum: 1000 }, on: :create, allow_nil: false

  after_create { publish_to_dashboard }

  private

  def publish_to_dashboard
    Publisher.publish('comments', attributes)
  end
end
