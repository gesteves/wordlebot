class ProcessTeamWorker < ApplicationWorker
  def perform(team_id)
    team = Team.find(team_id)

    channels = team.channels_bot_is_member_of
    channels.each do |channel|
      ProcessChannelWorker.perform_async(team_id, channel[:id])
    end
  end
end
