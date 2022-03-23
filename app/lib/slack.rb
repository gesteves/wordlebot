class Slack
  def initialize
    @client_id = ENV['SLACK_CLIENT_ID']
    @client_secret = ENV['SLACK_CLIENT_SECRET']
  end

  # Exchanges a temporary OAuth verifier code for an access token.
  # @param code [String] A temporary authorization code granted by OAuth
  # @param redirect_uri [String] The redirect URI specified in the initial auth request
  # @see https://api.slack.com/methods/oauth.v2.access
  # @return [String] A JSON response like this:
  # {
  #   "ok": true,
  #   "app_id": "XXXXX",
  #   "authed_user": {
  #       "id": "XXXXX"
  #   },
  #   "scope": "incoming-webhook,groups:history,channels:history,channels:join",
  #   "token_type": "bot",
  #   "access_token": "xoxb-XXXXX,
  #   "bot_user_id": "XXXXX",
  #   "team": {
  #       "id": "XXXXX",
  #       "name": "The Team Name"
  #   },
  #   "enterprise": null,
  #   "is_enterprise_install": false,
  #   "incoming_webhook": {
  #       "channel": "#channel-name",
  #       "channel_id": "XXXX",
  #       "configuration_url": "https://...",
  #       "url": "https://..."
  #   }
  # }
  def get_access_token(code:, redirect_uri: nil)
    query = {
      code: code,
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: redirect_uri
    }.compact
    response = HTTParty.get("https://slack.com/api/oauth.v2.access?#{query.to_query}")
    JSON.parse(response.body, symbolize_names: true)
  end

  # Sends a message to a channel through an incoming webhook URL,
  # received through the OAuth flow.
  # @param url [String] The URL of the webhook
  # @param url [Hash] The contents of the message to be posted
  def send_webhook(url:, payload:)
    HTTParty.post(url,  body: payload.to_json)
  end

  # Fetches a conversation's history of messages and events.
  # @param channel_id [String] The ID of the channel to fetch history for.
  # @param access_token [String] Authentication token bearing required scopes. 
  # @see https://api.slack.com/methods/conversations.history
  # @return [String] A JSON response
  def conversation_history(channel_id:, access_token:)
    response = HTTParty.get("https://slack.com/api/conversations.history",
                            query: { channel: channel_id },
                            headers: { 'Authorization': "Bearer #{access_token}" })
    JSON.parse(response.body, symbolize_names: true)
  end

  # Joins an existing channel.
  # @param channel_id [String] The ID of the channel to join.
  # @param access_token [String] Authentication token bearing required scopes. 
  # @see https://api.slack.com/methods/conversations.join
  # @return [String] A JSON response
  def conversation_join(channel_id:, access_token:)
    response = HTTParty.get("https://slack.com/api/conversations.join",
                            query: { channel: channel_id },
                            headers: { 'Authorization': "Bearer #{access_token}" })
    JSON.parse(response.body, symbolize_names: true)
  end
end