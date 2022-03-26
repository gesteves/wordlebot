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
    scores = [
      {:text=>"Wordle 279 4/6*", :user=>"U0LS19PDZ", :image=>"https://avatars.slack-edge.com/2022-03-15/3247816561940_9a4009a3bc552011210b_512.png", :name=>"Guillermo Esteves"},
      {:text=>"Wordle 279 4/6", :user=>"U0NA8QJ3Z", :image=>"https://avatars.slack-edge.com/2022-03-15/3248153495108_87f91a5279b4f238393b_512.png", :name=>"Kate Birmingham"},
      {:text=>"Wordle 279 3/6*", :user=>"U037X50K6M6", :image=>"https://avatars.slack-edge.com/2022-03-15/3269247664096_3db2a53df116359ca510_512.jpg", :name=>"Marie Connelly"}
    ]
    stats = Wordle.stats(scores)
    assert_equal 0, stats[:one_guess]
    assert_equal 0, stats[:two_guesses]
    assert_equal 1, stats[:three_guesses]
    assert_equal 2, stats[:four_guesses]
    assert_equal 0, stats[:five_guesses]
    assert_equal 0, stats[:six_guesses]
    assert_equal 0, stats[:failures]
  end
end
