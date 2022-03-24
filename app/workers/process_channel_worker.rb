class ProcessChannelWorker < ApplicationWorker
  def perform(team_id, channel_id)
    team = Team.find(team_id)
    scores = team.wordle_scores_in_channel(channel_id: channel_id, game_number: Wordle.yesterdays_game)

    text = "Results for Wordle #{Wordle.yesterdays_game}"
    blocks = Wordle.to_slack_blocks(game_number: Wordle.yesterdays_game, scores: scores)

    team.post_in_channel(channel_id: channel_id, text: text, blocks: blocks)
  end

end
