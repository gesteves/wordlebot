class AuthController < ApplicationController
  def index
    if params[:code].present?
      slack = Slack.new
      token = slack.get_access_token(code: params[:code], redirect_uri: auth_url)
      if token[:ok]
        access_token = token[:access_token]
        notice = 'Wordlebot was added to your Slack. Yay!'
        # TODO: Store token, webhook, etc.
      else
        notice = "Authentication failed for the following reason: “#{token[:error]}”. Boo!"
      end
    else
      notice = 'Authentication failed. Try again!'
    end
    redirect_to root_url, notice: notice
  end
end
