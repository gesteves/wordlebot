class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    return render plain: "Unauthorized", status: 401 if params[:token] != ENV['SLACK_VERIFICATION_TOKEN']
    event_type = params.dig(:event, :type) || params[:type]
    case event_type
    when 'url_verification'
      verify_url
    when 'app_mention'
      app_mention
    end
  end

  private

  def verify_url
    render plain: params[:challenge], status: 200
  end

  def app_mention
    team = Team.find_by(team_id: params[:team_id])
    channel = params.dig(:event, :channel)
    text = params.dig(:event, :text)
    regex = /wordle (\d+)/i
    game_number = regex.match(text)&.values_at(1)&.first
    ProcessChannelWorker.perform_async(team&.id, channel, game_number, true)
    render plain: "OK", status: 200
  end
end
