module ApplicationHelper
  def add_to_slack_url
    url = "https://slack.com/oauth/v2/authorize"
    scopes = %w{
      groups:history
      channels:history
      channels:read
      groups:read
      chat:write
      users:read
      app_mentions:read
    }
    params = {
      client_id: ENV['SLACK_CLIENT_ID'],
      scope: scopes.join(','),
      redirect_uri: auth_url
    }
    [url, params.to_query].join('?')
  end
end
