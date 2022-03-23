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
  #   "is_enterprise_install": false
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

  # Lists all channels in a Slack team.
  # @param access_token [String] Authentication token bearing required scopes. 
  # @see https://api.slack.com/methods/conversations.list
  # @return [String] A JSON response
  def conversations_list(access_token:)
    response = HTTParty.get("https://slack.com/api/conversations.list",
                            headers: { 'Authorization': "Bearer #{access_token}" })
    JSON.parse(response.body, symbolize_names: true)
  end

  # Sends a message to a channel.
  # @param access_token [String] Authentication token bearing required scopes. 
  # @see https://api.slack.com/methods/chat.postMessage
  # @return [String] A JSON response
  def post_message(access_token:, text:)
    response = HTTParty.post("https://slack.com/api/chat.postMessage",
                            body: {
                              text: text
                            }.to_json, 
                            headers: { 'Authorization': "Bearer #{access_token}" })
    JSON.parse(response.body, symbolize_names: true)
  end
end