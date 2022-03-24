class ProcessChannelWorker < ApplicationWorker
  def perform(team_id, channel_id)
    team = Team.find(team_id)
    scores = team.wordle_scores_in_channel(channel_id: channel_id, game_number: Wordle.yesterdays_game)
    stats = Wordle.stats(scores)
  end
end
