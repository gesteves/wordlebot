class Team < ApplicationRecord
  validates :team_id, presence: true, uniqueness: true
  validates :access_token, presence: true

  def channels_bot_is_member_of
    all_channels.select { |c| c[:is_member] }
  end

  def all_channels
    slack = Slack.new
    channels = []
    more_results = true
    cursor = nil

    while more_results do
      response = slack.conversations_list(access_token: access_token, team_id: team_id, cursor: cursor)
      break unless response[:ok]
      channels += response[:channels]
      cursor = response.dig(:response_metadata, :next_cursor)
      more_results = cursor.present?
    end

    channels
  end
end
