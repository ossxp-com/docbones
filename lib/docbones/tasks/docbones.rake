namespace:db do
  xsltproc = "xsltproc -o"
  htmlxsl = "tools/html-stylesheet.xsl"
  htmlsxsl = "tools/chunk-stylesheet.xsl"
  pdfxsl = "tools/fo-stylesheet.xsl"
  desc 'make all'
  task:all => [:html,:htmls,:pdf]
  desc 'clean'
  task:clean do
    `rm -rf #{PROJ.pkg}`
  end
  desc 'make html'
  task:html do
    sh "#{xsltproc} #{PROJ.pkg}/#{PROJ.xml}.html #{htmlxsl} #{PROJ.root}/#{PROJ.xml}.xml"
  end
  desc 'make htmls'
  task:htmls do
    sh "#{xsltproc} #{PROJ.pkg}/#{PROJ.xml}/ #{htmlsxsl} #{PROJ.root}/#{PROJ.xml}.xml"
  end 
  task:fo do
    sh "#{xsltproc} #{PROJ.pkg}/#{PROJ.xml}.fo #{pdfxsl} #{PROJ.root}/#{PROJ.xml}.xml"
  end
  desc 'make pdf'
  task:pdf => [:fo] do
    sh "fop -c /etc/fop/fop.xconf #{PROJ.pkg}/#{PROJ.xml}.fo #{PROJ.pkg}/#{PROJ.xml}.pdf"
  end
  desc 'make mm'
  task:mm do
    sh 'sl'
  end
end
