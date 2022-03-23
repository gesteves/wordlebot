class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :team_id
      t.string :access_token

      t.timestamps
    end
  end
end
