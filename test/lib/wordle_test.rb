require "test_helper"

class WordleTest < ActiveSupport::TestCase
  test "returns the correct Wordle game number for today's game" do
    travel_to Time.parse("March 25, 2022")
    assert_equal 279, Wordle.todays_game
  end

  test "returns the correct Wordle game number for yesterday's game" do
    travel_to Time.parse("March 25, 2022")
    assert_equal 278, Wordle.yesterdays_game
  end

  test "correctly detects Wordle scores for a specific game" do
    assert Wordle.regex(game_number: 278).match? "Wordle 278 1/6*"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 2/6*"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 3/6*"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 4/6*"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 5/6*"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 6/6*"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 X/6*"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 1/6"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 2/6"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 3/6"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 4/6"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 5/6"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 6/6"
    assert Wordle.regex(game_number: 278).match? "Wordle 278 X/6"
    assert_not Wordle.regex(game_number: 278).match? "Wordle 278 0/6"
    assert_not Wordle.regex(game_number: 278).match? "Wordle 278 7/6"
    assert_not Wordle.regex(game_number: 278).match? "Wordle 278 6/7"
    assert_not Wordle.regex(game_number: 278).match? "Wordle 279 1/6"
  end

  test "generates states for a set of scores" do
    scores = ["Wordle 200 1/6", "Wordle 200 2/6*", "Wordle 200 2/6", "Wordle 200 x/6"]
    stats = Wordle.stats(scores)
    assert_equal 4, stats[:total_games]
    assert_equal 1, stats[:one_guess]
    assert_equal 2, stats[:two_guesses]
    assert_equal 0, stats[:three_guesses]
    assert_equal 0, stats[:four_guesses]
    assert_equal 0, stats[:five_guesses]
    assert_equal 0, stats[:six_guesses]
    assert_equal 1, stats[:failures]
  end
end
