PROJ.root = PROJ.root.nil? ? PROJ.root : PROJ.root.strip
PROJ.name = PROJ.name.nil? ? PROJ.name : PROJ.name.strip
PROJ.index = PROJ.index.nil? ? PROJ.index : PROJ.index.strip
PROJ.output = PROJ.output.nil? ? PROJ.output : PROJ.output.strip
images = PROJ.images.nil? ? PROJ.images : PROJ.images.strip
desc 'clean the output/*'
task:clean do
  sh "rm -rf #{PROJ.output} 2>/dev/null"
end
namespace:db do

XPC = "xsltproc -o"
HXSL = "tools/html-stylesheet.xsl"
HSXSL = "tools/chunk-stylesheet.xsl"
PXSL = "tools/fo-stylesheet.xsl"
HTML = PROJ.output+"/"+PROJ.index+".html"
HTMLS = PROJ.output+"/"+PROJ.name 
FO = PROJ.output+"/"+PROJ.index+".fo"
PDF = PROJ.output+"/"+PROJ.index+".pdf"
XML = PROJ.root+'/'+PROJ.index+'.xml'

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

  desc "index and output info"
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
     puts "html url======>#{PROJ.output}/#{PROJ.index}.html"
     puts 
     puts "htmls url ======>#{PROJ.output}/#{PROJ.name}"
     puts
     puts "pdf url ======>#{PROJ.output}/#{PROJ.index}.pdf"   
  end

  desc 'make all'
  file 'all' => [:html,:htmls,:pdf]

  task:xsltproc do
    if !test(?e,"/usr/bin/xsltproc")
       puts "uninstall xsltproc,please:"
       puts "sudo aptitude install xsltproc"
       exit 1
    end
  end
  task:fop do
    if !test(?e,"/usr/bin/fop")
       puts "uninstall fop,please:"
       puts "sudo aptitude install fop"
       exit 1
    end
  end

stringparam = "--stringparam root.filename" 
  desc 'make html'
  task:html => [:xsltproc,HTML]
  file HTML => [XML] do
    sh "xsltproc #{stringparam} #{PROJ.output}/#{PROJ.index} #{HXSL} #{XML}"
    if !images.empty? & test(?e,images)
       sh "cp -a #{images} #{PROJ.output}"
    end
  end
  desc 'make htmls'
  task:htmls => [:xsltproc,HTMLS] 
  file HTMLS => [XML] do
    sh "#{XPC} #{HTMLS}/ #{HSXSL} #{XML}"
    if !images.empty? & test(?e,images)
       sh "cp -a #{images} #{HTMLS}"
    end
  end 
  file FO =>[XML] do
    sh "#{XPC} #{FO} #{PXSL} #{XML}"
  end
  desc 'make pdf'
  task:pdf => [:fop,:xsltproc,PDF] 
  file PDF => [FO] do
    sh "fop -c /etc/fop/fop.xconf #{FO} #{PDF}"
  end
end
