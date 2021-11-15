class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments, force: :cascade do |t|
      t.string :text

      t.timestamps
    end

    add_reference :comments, :article, foreign_key: true
    add_reference :comments, :user, foreign_key: true
  end
end
