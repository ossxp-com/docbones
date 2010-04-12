PROJ.root= PROJ.root.nil? ? PROJ.root : PROJ.root.strip
PROJ.name = PROJ.name.nil? ? PROJ.name : PROJ.name.strip
PROJ.index = PROJ.index.nil? ? PROJ.index : PROJ.index.strip
PROJ.output = PROJ.output.nil? ? PROJ.output : PROJ.output.strip
desc 'clean the output/*'
task:clean do
  sh "rm -rf #{PROJ.output}/*html 2>/dev/null"
  sh "rm -rf #{PROJ.output}/*odt 2>/dev/null"
  sh "rm -rf #{PROJ.output}/*pdf 2>/dev/null"
end 
namespace:rst do
RST = PROJ.root+"/"+PROJ.index+".rst" 
HTML = PROJ.output+"/"+PROJ.index+".html"
PDF = PROJ.output+"/"+PROJ.index+".pdf"
ODT = PROJ.output+"/"+PROJ.index+".odt"
OUTPUT = PROJ.output
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

  file OUTPUT do
     `mkdir -p #{OUTPUT}`
  end
  
  desc 'rake all'
  file 'all' => ['html','pdf','odt']
  
  desc 'rake html'
  task:html => [:rst2html,OUTPUT,HTML]
  file HTML => [RST] do
    sh "rst2html #{RST} > #{HTML}"
  end
   
  path= File.join(File.expand_path(File.dirname(__FILE__)),'./rst2pdf.py')

  desc 'rake pdf'
  task:pdf =>  [OUTPUT,PDF]
  file PDF => [RST] do
    `#{path} #{RST}`
    `mv #{RST}.pdf #{PDF} 2>/dev/null`   
  end
  
  desc 'rake odt'
  task:odt => [:rst2odt,OUTPUT,ODT]
  file ODT => [RST] do
    sh "rst2odt #{RST} #{ODT}"
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
     puts "html url======>#{HTML}"
     puts 
     puts "odt url ======>#{ODT}"
     puts
     puts "pdf url ======>#{PDF}"   
  end
end
