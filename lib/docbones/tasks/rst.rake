require 'docbones'
PATH=Docbones::PATH
PROJ.root= PROJ.root.nil? ? PROJ.root : PROJ.root.strip
PROJ.name = PROJ.name.nil? ? PROJ.name : PROJ.name.strip
PROJ.index = PROJ.index.nil? ? PROJ.index : PROJ.index.strip
PROJ.output = PROJ.output.nil? ? PROJ.output : PROJ.output.strip
PROJ.images = PROJ.images.nil? ? PROJ.images : PROJ.images.strip
desc 'clean the output'
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
js_path = PROJ.js_path.strip.empty? ? "" : "--javascript=#{PROJ.js_path.strip}"
css_path = PROJ.css_path.strip.empty? ? "" : "--stylesheet-path=#{PROJ.css_path.strip} --link-stylesheet"
pdfstyle = PROJ.pdf_style.strip.empty? ? "" : "-s #{PROJ.pdf_style.strip}"

  file RST+".in"
  file RST => RST+".in" do
    DOC_REV= ENV["DOC_REV"] ? ENV["DOC_REV"] : "%VERSION%"
    f = File.open(RST+".in")
    template = f.read
    template.gsub!(/^(\.\. \|doc_rev\| replace::).*/,"\\1 #{DOC_REV}")
    f.close
    f = File.new(RST, "w")
    f.print(template)
    f.close
    puts "#{RST} created from #{RST}.in"
  end

  task:rst2html do
    if system('which rst2html >/dev/null 2>&1')
        if not js_path.empty? and not system("python #{PATH}/contrib/docutils/hack_docutils.py -t")
            if not system("python #{PATH}/contrib/docutils/hack_docutils.py -p")
                exit 1
            end
        end
    else
        puts '*'*80
        puts 'please, sudo aptitude install python-docutils'
        puts '*'*80
        exit 1
    end
  end

  task:rst2odt do
    if system('which rst2odt >/dev/null 2>&1')
    else
      puts '*'*80
      puts 'please, sudo aptitude install python-docutils'
      puts '*'*80
      exit 1
    end
  end

  task:rst2pdf do
    if system('which rst2pdf >/dev/null 2>&1')
    else
      puts '*'*80
      puts 'please, sudo aptitude install rst2pdf'
      puts '*'*80
      exit 1
    end
  end
  file OUTPUT do
     `mkdir -p #{OUTPUT}`
  end
  
  desc 'rake all'
  task:all => [:html,:odt,:pdf]

  desc 'rake html'
  task:html => [:rst2html,OUTPUT,HTML]
  file HTML => [RST] do
    sh "rst2html #{RST} #{css_path} #{js_path} #{HTML}"
    if !images.empty? & test(?e,images)
        sh "cp -a #{images} #{OUTPUT}"
    end
  end

  desc 'rake pdf'
  task:pdf =>  [:rst2pdf,OUTPUT,PDF]
  file PDF => [RST] do
    sh "rst2pdf #{pdfstyle} #{RST} -q -o #{PDF}"
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
