class RecreateCommentAsPolymorphic < ActiveRecord::Migration[5.1]
    def change
      create_table :comments do |t|
        t.string :body
        t.string :commentable_type 
        t.integer :commentable_id
        t.integer :user_id

        t.timestamps
      end
    end
end
