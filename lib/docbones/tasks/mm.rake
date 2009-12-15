desc 'clean the output/*'

XPC ||= "xsltproc -o"
XSL = "tools/freemind2html.xsl" 
MMs = Dir.glob(File.join(Dir.pwd,"*.mm")).map do |mm|
   mm.sub Dir.pwd.to_s.strip+'/',""
end
HTMLs = MMs.map {|m| m.sub('.mm','.html').strip }
X = PROJ.output
string_param = "--stringparam freemind_src"
if MMs.empty?

else
  namespace:mm do
   desc 'rake html'
   task:html => [X]
   task:html => HTMLs
   file X do
     `mkdir output`
   end
     rule '.html' => '.mm' do |t|
       mm_name ="ht_"+t.source
       sh "#{XPC} #{t.name} #{string_param} #{mm_name} #{XSL} #{t.source}"
       `mv #{t.name} #{X}/mm_#{t.name} `
       `cp #{t.source} #{X}/#{mm_name}`      
     end
   end
end

