class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :person, null: false, foreign_key: true, type: :uuid
      t.string :comment

      t.timestamps
    end
  end
end
