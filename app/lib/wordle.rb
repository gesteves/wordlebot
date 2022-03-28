module Wordle
  extend ActionView::Helpers::TextHelper

  START_DATE = Date.parse("19 Jun 2021")

  # Returns the number of today's Wordle game.
  # The first Wordle game was on June 19, 2021, so
  # the number of days between that date and now is the
  # number of today's game.
  # This completely ignores timezone fuckery, so it may not be perfect.
  # @return [Integer] The number of today's Wordle game.
  def self.todays_game
    (Time.now.to_date - START_DATE).to_i
  end

  # Returns the number of yesterday's game.
  # @return [Integer] The number of yesterdays's Wordle game.
  def self.yesterdays_game
    todays_game - 1
  end

  # Returns a regex to match Wordle results for a specific game.
  # @param game_number [Integer] The game number to match.
  # @return [Regexp] A regex to match the results of a game.
  # @see https://rubular.com/r/1MKYcWduo4STSZ
  def self.regex(game_number:)
    /wordle #{Regexp.quote(game_number.to_s)} (1|2|3|4|5|6|x)\/6(\*)?/i
  end

  # Returns a Slack block hash with the results for a game.
  # @param game_number [String] The number of the Wordle game, e.g. 268
  # @param scores [Array] An array of string with Wordle scores, like "Wordle 123 3/6*"
  # @return [Hash] A hash with Slack block data.
  def self.to_slack_blocks(game_number:, scores:)
    stats = stats(scores)
    users = users(scores)

    total_games = scores.size

    blocks = []

    blocks << {
      type: 'header',
      text: {
        type: 'plain_text',
        text: "Results for Wordle #{game_number}",
        emoji: true
      }
    }

    blocks << {
      type: "context",
      elements: [
        {
          type: "mrkdwn",
          text: "#{(START_DATE + game_number).strftime('%A, %B %-d, %Y')} – #{pluralize(total_games, 'player')}"
        }
      ]
		}

    blocks << {
      type: "divider"
    }

    blocks += result_section(title: '1/6', results: stats[:one_guess],     users: users[:one_guess],     total_games: total_games)
    blocks += result_section(title: '2/6', results: stats[:two_guesses],   users: users[:two_guesses],   total_games: total_games)
    blocks += result_section(title: '3/6', results: stats[:three_guesses], users: users[:three_guesses], total_games: total_games)
    blocks += result_section(title: '4/6', results: stats[:four_guesses],  users: users[:four_guesses],  total_games: total_games)
    blocks += result_section(title: '5/6', results: stats[:five_guesses],  users: users[:five_guesses],  total_games: total_games)
    blocks += result_section(title: '6/6', results: stats[:six_guesses],   users: users[:six_guesses],   total_games: total_games)
    blocks += result_section(title: 'X/6', results: stats[:failures],      users: users[:failures],      total_games: total_games)

    blocks << {
      type: "divider"
    }

    blocks.compact
  end

  private

  def self.result_section(title:, results:, users:, total_games:, emoji: ":large_green_square:", bg_emoji: ":white_large_square:")
    return [] if results == 0
    max_results = 10
    scaled_results = ((results.to_f * max_results)/total_games).round

    blocks = []

    blocks << {
      type: "section",
      text: {
        type: "mrkdwn",
        text: "*#{title}* – #{pluralize(results, 'player')}\n#{emoji * scaled_results}#{bg_emoji * (max_results - scaled_results)}"
      }
    }

    avatar_elements = users.select { |u| u[:name].present? && u[:image].present? }.slice(0, 10).map { |u| { type: "image", image_url: u[:image], alt_text: u[:name] } }

    if avatar_elements.present?
      remaining_avatars = users.size - avatar_elements.size
      avatar_elements << { type: "plain_text", emoji: true, text: "+ #{remaining_avatars} more" } if remaining_avatars > 0
      blocks << { type: "context", elements: avatar_elements }
    end

    blocks
  end

  # Returns a hash with stats for a Wordle game.
  # @param scores [Array] An array of hashes with Wordle scores
  # @return [Hash] A hash with stats.
  def self.stats(scores)
    return if scores.blank?

    ones   = scores.select { |s| s[:text] =~ /1\/6/  }
    twos   = scores.select { |s| s[:text] =~ /2\/6/  }
    threes = scores.select { |s| s[:text] =~ /3\/6/  }
    fours  = scores.select { |s| s[:text] =~ /4\/6/  }
    fives  = scores.select { |s| s[:text] =~ /5\/6/  }
    sixes  = scores.select { |s| s[:text] =~ /6\/6/  }
    fails  = scores.select { |s| s[:text] =~ /x\/6/i }

    {
      one_guess:     ones.size,
      two_guesses:   twos.size,
      three_guesses: threes.size,
      four_guesses:  fours.size,
      five_guesses:  fives.size,
      six_guesses:   sixes.size,
      failures:      fails.size
    }
  end

  # Returns a hash with avatars for each Wordle score.
  # @param scores [Array] An array of hashes with Wordle scores
  # @return [Hash] A hash with avatars.
  def self.users(scores)
    return if scores.blank?

    ones   = scores.select { |s| s[:text] =~ /1\/6/  }.each { |m| m.delete(:text) }
    twos   = scores.select { |s| s[:text] =~ /2\/6/  }.each { |m| m.delete(:text) }
    threes = scores.select { |s| s[:text] =~ /3\/6/  }.each { |m| m.delete(:text) }
    fours  = scores.select { |s| s[:text] =~ /4\/6/  }.each { |m| m.delete(:text) }
    fives  = scores.select { |s| s[:text] =~ /5\/6/  }.each { |m| m.delete(:text) }
    sixes  = scores.select { |s| s[:text] =~ /6\/6/  }.each { |m| m.delete(:text) }
    fails  = scores.select { |s| s[:text] =~ /x\/6/i }.each { |m| m.delete(:text) }

    {
      one_guess:       ones,
      two_guesses:     twos,
      three_guesses: threes,
      four_guesses:   fours,
      five_guesses:   fives,
      six_guesses:    sixes,
      failures:       fails
    }
  end
end
