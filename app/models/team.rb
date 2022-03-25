class Team < ApplicationRecord
  validates :team_id, presence: true, uniqueness: true
  validates :access_token, presence: true

  INVALID_AUTH_ERRORS = %w{
    invalid_auth
    account_inactive
    token_revoked
    token_expired
  }

  def channels_bot_is_member_of
    all_channels&.select { |c| c[:is_member] }
  end

  def all_channels
    return if has_invalid_token?
    slack = Slack.new
    channels = []
    has_more = true
    cursor = nil

    while has_more do
      response = slack.conversations_list(access_token: access_token, team_id: team_id, cursor: cursor)
      raise response[:error] unless response[:ok]
      return unless response[:ok]
      channels += response[:channels]
      cursor = response.dig(:response_metadata, :next_cursor)
      has_more = cursor.present?
    end

    channels
  end

  def wordle_scores_in_channel(channel_id:, game_number:)
    return if has_invalid_token?
    regex = Wordle.regex(game_number: game_number)
    slack = Slack.new
    messages = []
    has_more = true
    latest = Time.now.to_i
    oldest = 2.days.ago.to_i

    while has_more do
      response = slack.conversation_history(channel_id: channel_id, access_token: access_token, latest: latest, oldest: oldest)
      raise response[:error] unless response[:ok]
      return unless response[:ok]
      messages += response[:messages]
      latest = response[:messages]&.last&.dig(:ts)
      has_more = response[:has_more]
    end

    messages.map { |m| regex.match(m[:text])&.values_at(0) }.compact.flatten
  end

  def post_in_channel(channel_id:, text:, attachments: nil, blocks: nil)
    return if has_invalid_token?
    slack = Slack.new
    response = slack.post_message(access_token: access_token, channel_id: channel_id, text: text, attachments: attachments, blocks: blocks)
    raise response[:error] unless response[:ok]
  end

  def has_invalid_token?
    slack = Slack.new
    response = slack.auth_test(access_token: access_token)
    !response[:ok] && INVALID_AUTH_ERRORS.include?(response[:error])
  end
end
