class AuthController < ApplicationController
  def index
    if params[:code].present?
      slack = Slack.new
      token = slack.get_access_token(code: params[:code], redirect_uri: auth_url)
      if token[:ok].present?
        access_token = token[:access_token]
        channel_id = token.dig(:incoming_webhook, :channel_id)
        slack.conversation_join(channel_id: channel_id, access_token: access_token)
        notice ='Wordlebot has been added to your Slack. Yay!'
      else
        notice = 'Authentication failed. Try again!'
      end
    else
      notice = 'Authentication failed. Try again!'
    end
    redirect_to root_url, notice: notice
  end
end
