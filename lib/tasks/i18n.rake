namespace :i18n do
  desc 'Push source strings to Transifex for translation'
  task :push do
    sh('tx push -s')
  end

  desc 'Pull translated strings from Transifex'
  task :pull do
    sh('tx pull --mode=reviewed --all --minimum-perc=1')
  end

  desc 'Clean the locale directory'
  task :clean do
    sh('git clean -f locale/')
  end

  desc 'Commit translated strings to the repository'
  task :commit => %w(i18n:clean i18n:pull) do
    sh('git add locale')
    sh("git commit -m 'Updated translations (autogenerated message)'")
  end
end