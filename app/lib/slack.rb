class Slack
  def initialize
    @client_id = ENV['SLACK_CLIENT_ID']
    @client_secret = ENV['SLACK_CLIENT_SECRET']
  end

  # Exchanges a temporary OAuth verifier code for an access token.
  # @param code [String] A temporary authorization code granted by OAuth
  # @param redirect_uri [String] The redirect URI specified in the initial auth request
  # @see https://api.slack.com/methods/oauth.v2.access
  # @return [String] A JSON response.
  def get_access_token(code:, redirect_uri: nil)
    query = {
      code: code,
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: redirect_uri
    }.compact
    response = HTTParty.get("https://slack.com/api/oauth.v2.access", query: query)
    JSON.parse(response.body, symbolize_names: true)
  end

  # Checks authentication & identity.
  # @param access_token [String] Authentication token bearing required scopes.
  # @see https://api.slack.com/methods/auth.test
  # @return [String] A JSON response.
  def auth_test(access_token:)
    response = HTTParty.post("https://slack.com/api/auth.test", headers: { 'Authorization': "Bearer #{access_token}" })
    JSON.parse(response.body, symbolize_names: true)
  end

  # Fetches a conversation's history of messages and events.
  # @param channel_id [String] The ID of the channel to fetch history for.
  # @param access_token [String] Authentication token bearing required scopes.
  # @param cursor [String] Used to paginate through collections of data.
  # @param inclusive [Boolean] Include messages with latest or oldest timestamp in results when either timestamp is specified.
  # @param limit [Integer] The maximum number of items to return.
  # @param latest [String] End of time range of messages to include in results. Default is the current time.
  # @param oldest [String] Start of time range of messages to include in results.
  # @see https://api.slack.com/methods/conversations.history
  # @return [String] A JSON response.
  def conversation_history(channel_id:, access_token:, cursor: nil, inclusive: false, limit: 1000, latest: nil, oldest: nil )
    query = {
      channel: channel_id,
      cursor: cursor,
      inclusive: inclusive,
      limit: limit,
      latest: latest,
      oldest: oldest
    }.compact
    response = HTTParty.get("https://slack.com/api/conversations.history",
                            query: query,
                            headers: { 'Authorization': "Bearer #{access_token}" })
    JSON.parse(response.body, symbolize_names: true)
  end

  # Lists all channels in a Slack team.
  # @param access_token [String] Authentication token bearing required scopes.
  # @param team_id [String] Encoded team id to list channels in, required if token belongs to org-wide app.
  # @param types [String] Mix and match channel types by providing a comma-separated list of any combination of public_channel, private_channel, mpim, im.
  # @param exclude_archived [Boolean] Set to true to exclude archived channels from the list.
  # @param limit [Integer] The maximum number of items to return, no larger than 1000.
  # @param cursor [String] Used to paginate through collections of data.
  # @see https://api.slack.com/methods/conversations.list
  # @return [String] A JSON response.
  def conversations_list(access_token:, team_id:, types: 'public_channel,private_channel', exclude_archived: true, limit: 1000, cursor: nil)
    query = {
      team_id: team_id,
      types: types,
      exclude_archived: exclude_archived,
      limit: limit,
      cursor: cursor
    }.compact
    response = HTTParty.get("https://slack.com/api/conversations.list",
                            query: query,
                            headers: { 'Authorization': "Bearer #{access_token}" })
    JSON.parse(response.body, symbolize_names: true)
  end

  # Sends a message to a channel.
  # @param access_token [String] Authentication token bearing required scopes.
  # @param channel_id [String] Channel, private group, or IM channel to send message to.
  # @param attachments [Hash] The content of the message.
  # @param blocks [Hash] The content of the message.
  # @param text [String] The content of the message. If `attachments`` or `blocks`` are included, `text`` will be used as fallback text for notifications only.
  # @param link_names [Boolean] Find and link channel names and usernames.
  # @param markdown [Boolean] Disable Slack markup parsing by setting to false.
  # @param parse [String] Change how messages are treated, can be `none` or `full`.
  # @param reply_broadcast [Boolean] Used in conjunction with `thread_ts`` and indicates whether reply should be made visible to everyone in the channel or conversation.
  # @param thread_ts [String] Provide another message's ts value to make this message a reply.
  # @param unfurl_links [Boolean] Pass true to enable unfurling of primarily text-based content
  # @param unfurl_media [Boolean] Pass false to disable unfurling of media content.
  # @see https://api.slack.com/methods/chat.postMessage
  # @return [String] A JSON response.
  def post_message(
    access_token:,
    channel_id:,
    attachments: nil,
    blocks: nil,
    text: nil,
    link_names: true,
    markdown: true,
    parse: 'none',
    reply_broadcast: false,
    thread_ts: nil,
    unfurl_links: true,
    unfurl_media: true
  )
    return if attachments.blank? && blocks.blank? && text.blank?
    params = {
      channel: channel_id,
      attachments: attachments,
      blocks: blocks,
      text: text,
      link_names: link_names,
      mrkdwn: markdown,
      parse: 'none',
      reply_broadcast: false,
      thread_ts: nil,
      unfurl_links: true,
      unfurl_media: true
    }.compact
    response = HTTParty.post("https://slack.com/api/chat.postMessage",
                            body: params.to_json,
                            headers: { 'Authorization': "Bearer #{access_token}", 'Content-Type': 'application/json' })
    JSON.parse(response.body, symbolize_names: true)
  end
end
