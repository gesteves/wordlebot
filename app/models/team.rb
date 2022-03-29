class Team < ApplicationRecord
include ActionView::Helpers::TextHelper

  validates :team_id, presence: true, uniqueness: true
  validates :access_token, presence: true

  INVALID_AUTH_ERRORS = %w{
    invalid_auth
    account_inactive
    token_revoked
    token_expired
  }

  def channels_bot_is_member_of
    bot_channels = all_channels&.select { |c| c[:is_member] }
    logger.info "Wordlebot is a member of #{pluralize(bot_channels&.size, 'channel')}"
    bot_channels
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
    logger.info "Found #{pluralize(channels&.size, 'channel')} in team #{team_id}"
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

    scores = messages.select { |m| m[:text] =~ regex }.uniq { |m| m[:user] }.map { |m| clean_up_message(message: m, regex: regex) }.compact
    logger.info "Found #{pluralize(scores&.size, 'score')} for Wordle #{game_number} in channel #{channel_id}"
    scores
  end

  def post_in_channel(channel_id:, text:, attachments: nil, blocks: nil)
    return if has_invalid_token?
    slack = Slack.new
    response = slack.post_message(access_token: access_token, channel_id: channel_id, text: text, attachments: attachments, blocks: blocks)
    raise response[:error] unless response[:ok]
    logger.info "Message sent to channel #{channel_id}"
    response
  end

  def has_invalid_token?
    slack = Slack.new
    response = slack.auth_test(access_token: access_token)
    invalid_token = !response[:ok] && INVALID_AUTH_ERRORS.include?(response[:error])
    logger.error "Team #{team_id} has an invalidated token" if invalid_token
    invalid_token
  end

  private

  def clean_up_message(message:, regex:)
    slack = Slack.new
    user_id = message[:user]
    text = regex.match(message[:text])&.values_at(0)&.first
    return if text.blank?
    response = slack.user_info(access_token: access_token, user_id: user_id)
    raise response[:error] unless response[:ok]
    image = response.dig(:user, :profile, :image_192).presence || response.dig(:user, :profile, :image_72).presence || response.dig(:user, :profile, :image_48).presence  || response.dig(:user, :profile, :image_32).presence  || response.dig(:user, :profile, :image_24).presence  || response.dig(:user, :profile, :image_original).presence
    name = response.dig(:user, :real_name).presence || response.dig(:user, :name).presence

    {
      text: text,
      user: user_id,
      image: image,
      name: name
    }.compact
  end
end
