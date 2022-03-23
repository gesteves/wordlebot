class Team < ApplicationRecord
  validates :team_id, presence: true, uniqueness: true
  validates :access_token, presence: true
end
