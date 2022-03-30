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

  test "returns the correct date for a given game" do
    assert_equal Time.parse("March 30, 2022"), Wordle.game_date(game_number: 284)
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

  test "generates slack blocks for a set of scores" do
    scores = [
      { text: "Wordle 280 1/6", user: "ABCD1234", image: "https://api.slack.com/img/blocks/bkb_template_images/profile_1.png", name: "Michael Scott" },
      { text: "Wordle 280 2/6", user: "ABCD1235", image: "https://api.slack.com/img/blocks/bkb_template_images/profile_2.png", name: "Dwight Schrute" },
      { text: "Wordle 280 4/6", user: "ABCD1236", image: "https://api.slack.com/img/blocks/bkb_template_images/profile_3.png", name: "Pam Beasely" },
      { text: "Wordle 280 4/6", user: "ABCD1237", name: "Jim Halpert" }
    ]
    blocks = Wordle.to_slack_blocks(game_number: 280, scores: scores)

    assert_equal "Results for Wordle 280", blocks.find { |b| b[:type] == 'header'}.dig(:text, :text), "The header text is wrong"

    assert_equal 3, blocks.select { |b| b[:type] == 'section' }.size, "There should be 3 sections"
    assert_equal 1, blocks.select { |b| b[:type] == 'context' }[1][:elements].size, "This context should have 1 element"
    assert_equal 1, blocks.select { |b| b[:type] == 'context' }[2][:elements].size, "This context should have 1 element"
    assert_equal 2, blocks.select { |b| b[:type] == 'context' }[3][:elements].size, "This context should have 2 elements"

    assert blocks.select { |b| b[:type] == 'section' }[0][:text][:text] =~ /^\*1\/6\*/, "This section should show the 1/6 score"
    assert blocks.select { |b| b[:type] == 'section' }[1][:text][:text] =~ /^\*2\/6\*/, "This section should show the 2/6 score"
    assert blocks.select { |b| b[:type] == 'section' }[2][:text][:text] =~ /^\*4\/6\*/, "This section should show the 4/6 score"

    assert_equal "Michael Scott", blocks.select { |b| b[:type] == 'context' }[1][:elements][0][:alt_text], "This context should contain Michael Scott"
    assert_equal "Dwight Schrute", blocks.select { |b| b[:type] == 'context' }[2][:elements][0][:alt_text], "This context should contain Dwight Schrute"
    assert_equal "Pam Beasely", blocks.select { |b| b[:type] == 'context' }[3][:elements][0][:alt_text], "This context should contain Pam Beasely"
  end
end
