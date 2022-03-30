class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    return render plain: "Unauthorized", status: 401 if params[:token] != ENV['SLACK_VERIFICATION_TOKEN']
    event_type = params[:type]
    case event_type
    when 'url_verification'
      verify_url
    end
  end

  private

  def verify_url
    render plain: params[:challenge], status: 200
  end
end
