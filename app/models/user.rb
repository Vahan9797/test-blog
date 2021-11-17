class User < ApplicationRecord
  has_secure_password
  VALID_EMAIL_PATTERN = /^(.+)@(.+)$/

  validates :email, format: { with: VALID_EMAIL_PATTERN, multiline: true }, on: :create, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, on: :create

  has_many :articles, inverse_of: :creator, dependent: :destroy
  has_many :comments, inverse_of: :author, dependent: :destroy
end
