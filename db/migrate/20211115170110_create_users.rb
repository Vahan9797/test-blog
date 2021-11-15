class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, uniqueness: { case_sensitive: false }
      t.string :password_digest, null: false
      t.string :token, null: true, default: ''
      t.datetime :token_expires_at, null: true, default: 24.hours.from_now

      t.timestamps
    end
  end
end
