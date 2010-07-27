require 'docbones'
require 'date'

def rst_macro_replace(file_read, file_write)
  if not File.exists? file_read
    return False
  end

  results = []

  File.open(file_read, "r") do |file|

    while line = file.gets

      # New macro format: @ENV(...)@
      if /@.+@/.match line
        newline = ""
        line.split( /(@[^@]+@)/ ).each do |part|
          if /^@.+@$/.match part
            part=part[1...-1]
            if part.start_with?("ENV(") and part.end_with?(")")
              part = ENV[part[4...-1]] ? ENV[part[4...-1]] : "@UnkownENV(%s)@" % part[4...-1]
            end
          end
          newline += part
        end
        line = newline

      # Backward compatible: macro without @
      elsif /^\.\. \|(doc_date|doc_rev)\| replace::\s*ENV\(.+\)/.match line
        newline = ""
        line.split( /(replace::\s*)(ENV\(.+\))/ ).each do |part|
          if part.start_with?( "ENV(" ) and part.end_with?( ")" )
              part = ENV[part[4...-1]] ? ENV[part[4...-1]] : "@UnkownENV(%s)@" % part[4...-1]
          end
          newline += part
        end
        line = newline
      end

      results << line

    end

  end

  File.open(file_write, "w") do |file|
    file.puts results
  end

  puts "***** #{file_write} created from #{file_read} *****"

end

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
RST = PROJ.root+"/"+PROJ.index+".rst" 
HTML = PROJ.output+"/"+PROJ.index+".html"
PDF = PROJ.output+"/"+PROJ.index+".pdf"
ODT = PROJ.output+"/"+PROJ.index+".odt"
OUTPUT = PROJ.output
images=PROJ.images
js_path = PROJ.js_path.strip.empty? ? "" : "--javascript=#{PROJ.js_path.strip}"
css_path = PROJ.css_path.strip.empty? ? "" : "--stylesheet-path=#{PROJ.css_path.strip} --link-stylesheet"
pdfstyle = PROJ.pdf_style.strip.empty? ? "" : "-s #{PROJ.pdf_style.strip}"
default_dpi = PROJ.default_dpi.nil? ? "" : "--default-dpi #{PROJ.default_dpi}"

  desc 'create RST from RST.in'
  file RST => [:RSTIN2RST]
  task :RSTIN2RST do
    if File.exists?( RST+".in" )
      rst_macro_replace( RST+".in", RST )
    end
  end

  desc 'set DOC_BACKEND environment'
  task:rst2html_env do
    ENV["DOC_BACKEND"] = "HTML"
    if not ENV["DOC_DATE"]
      ENV["DOC_DATE"] = DateTime.now.strftime('%F %T')
    end
  end

  task:rst2pdf_env do
    ENV["DOC_BACKEND"] = "PDF"
    if not ENV["DOC_DATE"]
      ENV["DOC_DATE"] = DateTime.now.strftime('%F %T')
    end
  end

  task:rst2html do
    if system('which rst2html >/dev/null 2>&1')
        if not system("python #{PATH}/contrib/docutils/hack_docutils.py --check")
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
      if not system("python #{PATH}/contrib/rst2pdf/hack_rst2pdf.py --check")
        if not system("python #{PATH}/contrib/rst2pdf/hack_rst2pdf.py -p")
            exit 1
        end
      end
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
  task:all do
    puts "Sorry, all task is disabled. You should run seperate task one by one. Such as:"
    puts "\trake html"
    puts "\trake pdf"
    puts "\trake odt"
    exit 1
  end

  desc 'rake html'
  task:html => [:rst2html,OUTPUT,HTML]
  file HTML => [:rst2html_env, RST] do
    sh "rst2html #{RST} #{css_path} #{js_path} #{HTML}"
    if !images.empty? & test(?e,images)
        sh "cp -a #{images} #{OUTPUT}"
    end
  end

  desc 'rake pdf'
  task:pdf =>  [:rst2pdf,OUTPUT,PDF]
  file PDF => [:rst2pdf_env, RST] do
    sh "rst2pdf #{pdfstyle} #{RST} #{default_dpi} -q -o #{PDF}"
  end
  desc 'rake odt'
  task:odt => [:rst2odt,OUTPUT,ODT]
  file ODT => [:rst2html_env, RST] do
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
