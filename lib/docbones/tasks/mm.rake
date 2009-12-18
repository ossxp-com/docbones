desc 'clean the output/*'

XPC ||= "xsltproc -o"
XSL = "tools/freemind2html.xsl" 
MM = PROJ.mm.empty? ? '' : PROJ.mm+'.mm'
HTMLs = PROJ.output+'/mm_'+PROJ.mm+'.html'
X = PROJ.output
string_param = "--stringparam freemind_src"
if MM.empty?

else
  namespace:mm do
      desc 'rake html'
      task:html => [X]
      task:html => HTMLs
      file X do
         `mkdir output`
      end
      file HTMLs => MM do
          sh "#{XPC} #{HTMLs} #{string_param} #{MM} #{XSL} #{MM}"
          `cp #{MM} #{X}/#{MM}`      
      end
  end
end

