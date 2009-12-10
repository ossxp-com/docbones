desc 'clean the output/*'
task:clean do
  `rm -rf #{PROJ.output}/* 2>/dev/null`
  puts "rm -rf #{PROJ.output}/*"
end 
namespace:rst do
   
  task:rst2html do
    a = `which rst2html`.chomp
    if a == ''
      puts 'please, sudo aptitude install rst2html'
    exit 1
    end
  end

  task:rst2odt do
    a = `which rst2odt`.chomp
    if a == ''
      puts 'please, sudo aptitude install rst2odt'
    exit
    end
  end

  file 'output' do
     `mkdir #{PROJ.output}`
  end
  
  desc 'rake all'
  file 'all' => ['html','pdf','odt']
  
  desc 'rake html'
  task:html => [:rst2html,:output] do
    sh "rst2html #{PROJ.root}/#{PROJ.source}.rst > #{PROJ.output}/#{PROJ.source}.html"
  end
   
  path= File.join(File.expand_path(File.dirname(__FILE__)),'./rst2pdf.py')

  desc 'rake pdf'
  task:pdf =>  [:output]  do
    `#{path} #{PROJ.root}/#{PROJ.source}.rst`
    `mv #{PROJ.root}/#{PROJ.source}.rst.pdf #{PROJ.output}/#{PROJ.source}.pdf 2>/dev/null`   
  end
  
  desc 'rake odt'
  task:odt => [:rst2odt,:output] do
    sh "rst2odt #{PROJ.root}/#{PROJ.source}.rst #{PROJ.output}/#{PROJ.source}.odt"
  end


version_control_array = ['svn','hg','git']
def lastModity(split_letter,vc)
   a=`LANGUAGE=C;#{vc}`.chomp.split(split_letter)
   split_letter+a[1]
end

def last_modify version_control
  last_my = nil
  if  version_control == 'svn'
      last_my = lastModity("Path:","svn info")
  elsif version_control == 'hg'
      last_my = lastModity("changeset:","hg log .")
  elsif version_control == 'git'
      last_my = lastModity("commit","git log .")
  else
      last_my = `stat .`.strip  
  end
  last_my
end

  desc "source and output info"
  task:info => [:html,:odt,:pdf] do
     version_control = nil
     version_control_array.each do |vc|
        if !`#{vc} log 2>/dev/null`.chomp.empty?
          version_control = vc
          break
        end
     end
     puts last_modify version_control
     puts     
     puts "html url======>#{PROJ.output}/#{PROJ.source}.html"
     puts 
     puts "htmls url ======>#{PROJ.output}/#{PROJ.source}"
     puts
     puts "pdf url ======>#{PROJ.output}/#{PROJ.source}.pdf"   
  end

end

