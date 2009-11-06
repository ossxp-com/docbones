namespace:db do
  desc 'make all'
  task:all => [:html,:htmls,:pdf,:mm]
  desc 'make html'
  task:html do
    sh 'ls'
  end
  desc 'make htmls'
  task:htmls do
    sh 'LS'
  end
  desc 'make pdf'
  task:pdf do
    sh 'sl'
  end
  desc 'make mm'
  task:mm do
    sh 'sl'
  end
end
