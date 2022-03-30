class ProcessChannelWorker < ApplicationWorker
  def perform(team_id, channel_id, game_number)
    team = Team.find(team_id)
    logger.info "Processing scores for Wordle #{game_number} in channel #{channel_id} in team #{team.team_id}"
    scores = team.wordle_scores_in_channel(channel_id: channel_id, game_number: game_number)
    return if scores.blank?

    text = "Results for Wordle #{game_number}"
    blocks = Wordle.to_slack_blocks(game_number: game_number, scores: scores)

    if ENV['DEBUG'].present?
      logger.info blocks
    else
      team.post_in_channel(channel_id: channel_id, text: text, blocks: blocks)
    end
  end

end
