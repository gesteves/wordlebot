class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :no_cache

  def index
    url = root_url
    if params[:code].present?
      slack = Slack.new
      token = slack.get_access_token(code: params[:code], redirect_uri: auth_url)
      if token[:ok]
        access_token = token[:access_token]
        team_id = token.dig(:team, :id)
        team = Team.find_or_create_by(team_id: team_id)
        team.access_token = access_token
        if team.save
          logger.info "[LOG] [Team #{team_id}] Team authenticated with the following scopes: #{token[:scope]}"
          notice = nil
          url = success_url
        else
          notice = 'Oh no, something went wrong. Please try again!'
        end
      else
        logger.error "Authentication failed for the following reason: #{token[:error]}"
        notice = "Oh no, something went wrong. Please try again!"
      end
    elsif params[:error].present?
      logger.error "Authentication failed for the following reason: #{params[:error]}"
      notice = "Wordlebot was not added to your Slack. Please try again!"
    end
    redirect_to url, notice: notice
  end
end
