namespace :scores do
  desc 'Start the process of collecting and sending scores'
  task :process => [:environment] do
    Team.all.each do |team|
      ProcessTeamWorker.perform_async(team.id)
    end
  end
end
