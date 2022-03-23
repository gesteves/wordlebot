module ApplicationHelper
  def add_to_slack_url
    url = "https://slack.com/oauth/v2/authorize"
    params = {
      client_id: ENV['SLACK_CLIENT_ID'],
      scope: %w{incoming-webhook groups:history channels:history channels:join}.join(','),
      redirect_uri: auth_url
    }
    [url, params.to_query].join('?')
  end
end
