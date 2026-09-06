class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :duration, null: false

      t.timestamps
    end

    add_index :courses, :name, unique: true
  end
end
