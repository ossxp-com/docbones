desc 'clean the output/*'
task:clean do
  `rm -rf #{PROJ.output}/* 2>/dev/null`
  puts "rm -rf #{PROJ.output}/*"
end
namespace:mm do
XPC = "xsltproc -o"
XSL = "freemind2html.xsl" 
MM = PROJ.root+'/'+PROJ.index+'.mm'
HTML = PROJ.output+'/'+PROJ.index+'.html'
X = PROJ.output+'/x'
  desc 'rake html'
  task:html => [HTML]
  file HTML => [MM] do
     sh "#{XPC} #{HTML} #{XSL} #{MM}"
     `cp #{MM} #{PROJ.output}/xs.mm`
  end 
end

