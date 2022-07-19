class CreateUserImages < ActiveRecord::Migration[7.0]
  def change
    create_table :user_images do |t|
      t.string :individual_id
      t.datetime :timestamp
      t.string :source
      t.string :unit
      t.json :value
      t.string :confidence

      t.timestamps
    end
  end
end
