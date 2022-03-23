class AuthController < ApplicationController
  def index
    if params[:code].present?
      slack = Slack.new
      token = slack.get_access_token(code: params[:code], redirect_uri: auth_url)
      if token[:ok]
        access_token = token[:access_token]
        channel_id = token.dig(:incoming_webhook, :channel_id)
        join = slack.conversation_join(channel_id: channel_id, access_token: access_token)
        if join[:ok]
          notice = 'Wordlebot was added to your Slack. Yay!'
          # TODO: Store token, webhook, etc.
        else
          notice = "Wordlebot was not added to your Slack for the following reason: “#{join[:error]}”. Boo!"
        end
      else
        notice = "Authentication failed for the following reason: “#{token[:error]}”. Boo!"
      end
    else
      notice = 'Authentication failed. Try again!'
    end
    redirect_to root_url, notice: notice
  end
end
