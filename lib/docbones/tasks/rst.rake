PROJ.root= PROJ.root.nil? ? PROJ.root : PROJ.root.strip
PROJ.name = PROJ.name.nil? ? PROJ.name : PROJ.name.strip
PROJ.index = PROJ.index.nil? ? PROJ.index : PROJ.index.strip
PROJ.output = PROJ.output.nil? ? PROJ.output : PROJ.output.strip
PROJ.images = PROJ.images.nil? ? PROJ.images : PROJ.images.strip
PROJ.pdf_font = PROJ.pdf_font.nil? ? PROJ.pdf_font : PROJ.pdf_font.strip
desc 'clean the output/*'
task:clean do
  sh "rm -rf #{PROJ.output} 2>/dev/null"
end 
namespace:rst do
RST = PROJ.root+"/"+PROJ.index+".rst" 
HTML = PROJ.output+"/"+PROJ.index+".html"
PDF = PROJ.output+"/"+PROJ.index+".pdf"
ODT = PROJ.output+"/"+PROJ.index+".odt"
OUTPUT = PROJ.output
images=PROJ.images
pdf_font=PROJ.pdf_font
  task:rst2html do
    a = `which rst2html`.chomp
    if a == ''
      puts '*'*80
      puts 'please, sudo aptitude install rst2html'
      puts '*'*80
    exit 1
    end
  end

  task:rst2odt do
    a = `which rst2odt`.chomp
    if a == ''
      puts '*'*80
      puts 'please, sudo aptitude install rst2odt'
      puts '*'*80
    exit
    end
  end

  file OUTPUT do
     `mkdir -p #{OUTPUT}`
  end
  
  desc 'rake all'
  file 'all' => ['html','odt','pdf']
  
  desc 'rake html'
  task:html => [:rst2html,OUTPUT,HTML]
  file HTML => [RST] do
    sh "rst2html #{RST} > #{HTML}"
    if !images.empty? & test(?e,images)
        sh "cp -a #{images} #{OUTPUT}"
    end
  end
  path= File.join(File.expand_path(File.dirname(__FILE__)),'rst2pdf.py')
  simhei = '/etc/fop/simhei.ttf'
  desc 'rake pdf'
  task:pdf =>  [OUTPUT,PDF]
  file PDF => [RST,simhei] do
    a=`python #{path} #{RST}`
    `mv #{RST}.pdf #{PDF} 2>/dev/null`
    if !a.strip.empty?
       puts '*'*80
       puts a   
       puts '*'*80
    end
  end
  desc 'rake odt'
  task:odt => [:rst2odt,OUTPUT,ODT]
  file ODT => [RST] do
    sh "rst2odt #{RST} #{ODT}"
  end
  ossxpfond = "/opt/ossxp/fonts/truetype/"+pdf_font
  debianfond = "/usr/share/fonts/truetype/"+pdf_font
  file simhei do
    if !test(?e,'/etc/fop')
       sh "sudo mkdir -p /etc/fop"
    end
    if test(?e,ossxpfond)
       sh "sudo ln -s #{ossxpfond} #{simhei}"
    elsif test(?e,debianfond)
       sh "sudo ln -s #{debianfond} #{simhei}"
    else
       puts '*'*80
       puts "Sorry,the file #{debianfond} does not exist"
       puts '*'*80
       exit 1
    end
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
