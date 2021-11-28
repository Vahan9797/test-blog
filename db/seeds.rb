# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# generate 10 random users with password 'secret'
10.times do
  User.create!(
    email: Faker::Internet.email,
    password: 'secret',
    password_confirmation: 'secret'
  )
end

first_user_id = User.first.try(:id) || 0
last_user_id = User.last.try(:id) || 0

# generate 10 random articles tied with random users
10.times do
  User.find(Random.new.rand(first_user_id..last_user_id)).articles.create(
    title: Faker::Lorem.characters(number: 10),
    body: Faker::Lorem.paragraphs(number: 3, supplemental: true),
    category: Faker::Lorem.characters(number: 7)
  )
end

first_article_id = Article.first.try(:id) || 0
last_article_id = Article.last.try(:id) || 0
# generate 30 random comments on different articles with created users
30.times do
  Article.find(Random.new.rand(first_article_id..last_article_id)).comments.create(
    text: Faker::Lorem.sentences(number: 2),
    user_id: Random.new.rand(first_user_id..last_user_id)
  )
end