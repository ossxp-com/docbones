
namespace:db do

XPC  = "xsltproc -o"
HXSL = "tools/html-stylesheet.xsl"
HSXSL= "tools/chunk-stylesheet.xsl"
PXSL = "tools/fo-stylesheet.xsl"

  desc 'make all'
  task:all => [:html,:htmls,:pdf]
  desc 'clean'
  task:clean do
    `rm -rf #{PROJ.pkg}`
  end
  task:xsltproc do
    if test(?d,"/urs/bin/xsltproc")
       puts "uninstall xsltproc,please:"
       puts "sudo aptitude install xsltproc"
    end
  end
  task:fop do
    if test(?d,"/urs/bin/fop")
       puts "uninstall fop,please:"
       puts "sudo aptitude install fop"
    end
  end
  desc 'make html'
  task:html => [:xsltproc] do
    sh "#{XPC} #{PROJ.pkg}/#{PROJ.xml}.html #{HXSL} #{PROJ.root}/#{PROJ.xml}.xml"
  end
  desc 'make htmls'
  task:htmls => [:xsltproc] do
    sh "#{XPC} #{PROJ.pkg}/#{PROJ.xml}/ #{HSXSL} #{PROJ.root}/#{PROJ.xml}.xml"
    `cp -a tools/images #{PROJ.pkg}/#{PROJ.xml}`
  end 
  task:fo => [:xsltproc] do
    sh "#{XPC} #{PROJ.pkg}/#{PROJ.xml}.fo #{PXSL} #{PROJ.root}/#{PROJ.xml}.xml"
  end
  desc 'make pdf'
  task:pdf => [:fo,:fop] do
    sh "fop -c /etc/fop/fop.xconf #{PROJ.pkg}/#{PROJ.xml}.fo #{PROJ.pkg}/#{PROJ.xml}.pdf"
  end
end
