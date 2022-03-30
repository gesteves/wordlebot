class ProcessChannelWorker < ApplicationWorker
  def perform(team_id, channel_id, game_number, notify_no_scores = false)
    return if team_id.blank? || channel_id.blank? || game_number.blank?
    game_number = game_number.to_i
    team = Team.find(team_id)
    logger.info "Processing scores for Wordle #{game_number} in channel #{channel_id} in team #{team.team_id}"
    scores = team.wordle_scores_in_channel(channel_id: channel_id, game_number: game_number)
    if scores.blank?
      return unless notify_no_scores
      team.post_in_channel(channel_id: channel_id, text: "Sorry, I couldn’t find any scores for Wordle #{game_number} in this channel.")
    else
      text = "Results for Wordle #{game_number}"
      blocks = Wordle.to_slack_blocks(game_number: game_number, scores: scores)
      team.post_in_channel(channel_id: channel_id, text: text, blocks: blocks)
    end
  end

end
