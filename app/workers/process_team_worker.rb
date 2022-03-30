class ProcessTeamWorker < ApplicationWorker
  def perform(team_id, game_number)
    team = Team.find(team_id)
    team.channels_bot_is_member_of&.each { |channel| ProcessChannelWorker.perform_async(team_id, channel[:id], game_number) }
  end
end
