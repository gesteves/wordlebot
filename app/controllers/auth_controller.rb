class AuthController < ApplicationController
  def index
    if params[:code].present?
      slack = Slack.new
      token = slack.get_access_token(code: params[:code], redirect_uri: auth_url)
      if token[:ok]
        access_token = token[:access_token]
        team_id = token.dig(:team, :id)
        team = Team.find_or_create_by(team_id: team_id)
        team.access_token = access_token
        if team.save
          logger.info "Team #{team_id} authenticated with the following scopes: #{token[:scope]}"
          notice = 'Wordlebot was added to your Slack, don’t forget to invite it into your Wordle channels. Yay!'
        else
          notice = 'Oh no, something went wrong. Please try again!'
        end
      else
        logger.error "Authentication failed for the following reason: #{token[:error]}"
        notice = "Oh no, something went wrong. Please try again!"
      end
    end
    redirect_to root_url, notice: notice
  end
end
