class AuthController < ApplicationController
  def index
    if params[:code].present?
      slack = Slack.new
      token = slack.get_access_token(code: params[:code], redirect_uri: auth_url)
      if token[:ok]
        access_token = token[:access_token]
        team_id = token.dig(:team, :id)
        notice = 'Wordlebot was added to your Slack. Yay!'
        team = Team.find_or_create_by(team_id: team_id)
        team.access_token = access_token
        notice = team.save ? 'Wordlebot was added to your Slack. Yay!' : 'Authentication failed. Try again!'
      else
        notice = "Authentication failed for the following reason: “#{token[:error]}”. Boo!"
      end
    end
    redirect_to root_url, notice: notice
  end
end
