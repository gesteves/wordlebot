namespace :scores do
  desc 'Start the process of collecting and sending scores'
  task :process => [:environment] do
    game_number = Wordle.yesterdays_game
    puts "Collecting and sending scores for Wordle #{game_number}…"
    # Wake up the dynos
    HTTParty.get("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com")
    Team.all.each { |team| ProcessTeamWorker.perform_async(team.id, game_number) }
  end
end
