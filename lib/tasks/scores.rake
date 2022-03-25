namespace :scores do
  desc 'Start the process of collecting and sending scores'
  task :process => [:environment] do
    # Wake up the dynos
    HTTParty.get("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com")
    Team.all.each do |team|
      ProcessTeamWorker.perform_async(team.id)
    end
  end
end
