class ProcessChannelWorker < ApplicationWorker
  def perform(team_id, channel_id)
    team = Team.find(team_id)
    logger.info "Processing scores for Wordle #{Wordle.yesterdays_game} in channel #{channel_id} in team #{team.team_id}"
    scores = team.wordle_scores_in_channel(channel_id: channel_id, game_number: Wordle.yesterdays_game)
    return if scores.blank?

    text = "Results for Wordle #{Wordle.yesterdays_game}"
    blocks = Wordle.to_slack_blocks(game_number: Wordle.yesterdays_game, scores: scores)

    if ENV['DEBUG'].present?
      logger.info blocks 
    else
      team.post_in_channel(channel_id: channel_id, text: text, blocks: blocks)
    end
  end

end
