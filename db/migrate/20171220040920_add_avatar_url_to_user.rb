class AddAvatarUrlToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :avatar_url, :string, default: "default_avatar.gif"
  end
end