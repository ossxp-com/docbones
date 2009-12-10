
desc 'clean the output/*'
task:clean do
  `rm -rf #{PROJ.output}/* 2>/dev/null`
  puts "rm -rf #{PROJ.output}/*"
end
namespace:db do

XPC  = "xsltproc -o"
HXSL = "tools/html-stylesheet.xsl"
HSXSL= "tools/chunk-stylesheet.xsl"
PXSL = "tools/fo-stylesheet.xsl"

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
  task:info => [:html,:htmls,:pdf] do
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

  desc 'make all'
  file 'all' => [:html,:htmls,:pdf]

  task:xsltproc do
    if test(?d,"/usr/bin/xsltproc")
       puts "uninstall xsltproc,please:"
       puts "sudo aptitude install xsltproc"
       exit 1
    end
  end
  task:fop do
    if test(?d,"/usr/bin/fop")
       puts "uninstall fop,please:"
       puts "sudo aptitude install fop"
       exit 1
    end
  end

  desc 'make html'
  task:html => [:xsltproc] do
    sh "#{XPC} #{PROJ.output}/#{PROJ.source}.html #{HXSL} #{PROJ.root}/#{PROJ.source}.xml"
  end
  desc 'make htmls'
  task:htmls => [:xsltproc] do
    sh "#{XPC} #{PROJ.output}/#{PROJ.source}/ #{HSXSL} #{PROJ.root}/#{PROJ.source}.xml"
    `cp -a tools/images #{PROJ.output}/#{PROJ.source}`
  end 
  task:fo => [:xsltproc] do
    sh "#{XPC} #{PROJ.output}/#{PROJ.source}.fo #{PXSL} #{PROJ.root}/#{PROJ.source}.xml"
  end
  desc 'make pdf'
  task:pdf => [:fo,:fop] do
    sh "fop -c /etc/fop/fop.xconf #{PROJ.output}/#{PROJ.source}.fo #{PROJ.output}/#{PROJ.source}.pdf"
  end
end
