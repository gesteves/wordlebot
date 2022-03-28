namespace :scores do
  desc 'Start the process of collecting and sending scores'
  task :process => [:environment] do
    puts "Collecting and sending scores for Wordle #{Wordle.yesterdays_game}"
    # Wake up the dynos
    HTTParty.get("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com")
    Team.all.each { |team| ProcessTeamWorker.perform_async(team.id) }
  end
end
