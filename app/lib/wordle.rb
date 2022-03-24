module Wordle
  # Returns the number of today's Wordle game.
  # The first Wordle game was on June 19, 2021, so
  # the number of days between that date and now is the
  # number of today's game.
  # This completely ignores timezone fuckery, so it may not be perfect.
  # @return [Integer] The number of today's Wordle game.
  def self.todays_game
    (Time.now.to_date - Date.parse("19 Jun 2021")).to_i
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

  # Returns a hash with stats for a Wordle game.
  # @param scores [Array] An array of string with Wordle scores, like "Wordle 123 3/6*"
  # @return [Hash] A hash with stats.
  def self.stats(scores)
    return if scores.blank?
    total_games   = scores.size
    hard_games    = scores.count { |s| s =~ /\*$/ }
    one_guess     = scores.count { |s| s =~ /1\/6/ }
    two_guesses   = scores.count { |s| s =~ /2\/6/ }
    three_guesses = scores.count { |s| s =~ /3\/6/ }
    four_guesses  = scores.count { |s| s =~ /4\/6/ }
    five_guesses  = scores.count { |s| s =~ /5\/6/ }
    six_guesses   = scores.count { |s| s =~ /6\/6/ }
    failures      = scores.count { |s| s =~ /x\/6/i }

    {
      total_games:   total_games,
      hard_games:    hard_games,
      one_guess:     one_guess,
      two_guesses:   two_guesses,
      three_guesses: three_guesses,
      four_guesses:  four_guesses,
      five_guesses:  five_guesses,
      six_guesses:   six_guesses,
      failures:      failures
    }
  end
end
