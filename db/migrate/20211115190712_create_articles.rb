class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles, force: :cascade do |t|
      t.string :title
      t.string :body
      t.string :category
      t.datetime :published_date
      
      t.timestamps
    end

    add_reference :articles, :user, foreign_key: true
  end
end
