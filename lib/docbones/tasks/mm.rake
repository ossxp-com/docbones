PROJ.root = PROJ.root.nil? ? PROJ.root : PROJ.root.strip
PROJ.name = PROJ.name.nil? ? PROJ.name : PROJ.name.strip
PROJ.output = PROJ.output.nil? ? PROJ.output : PROJ.output.strip
PROJ.mm = PROJ.output.nil? ? PROJ.mm : PROJ.mm.strip
XPC ||= "xsltproc -o"
XSL = "tools/freemind2html.xsl" 
MM = PROJ.mm.empty? ? '' : PROJ.mm+'.mm'
HTMLs = PROJ.output+'/mm_'+PROJ.mm+'.html'
OUTPUT = PROJ.output
string_param = "--stringparam freemind_src"
if MM.empty?

else
      desc 'rake html'
      task:html => [OUTPUT]
      task:html => HTMLs
      file OUTPUT do
         sh "mkdir #{OUTPUT}"
      end
      file HTMLs => MM do
          sh "#{XPC} #{HTMLs} #{string_param} #{MM} #{XSL} #{MM}"
          `cp #{MM} #{X}/#{MM}`      
      end
end

