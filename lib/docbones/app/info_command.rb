
module Docbones
class App

class InfoCommand < Command

  def run( args )
    parse args
    msg  = "\n"

    fmt = "    %-12s => %s\n"
    msg << "Available projects skeletons are:\n"
    Dir.glob(File.join(mrbones_dir, '*')).sort.each do |fn|
      next if fn =~ %r/\.archive$/
      if test(?f, fn)
        msg << fmt % [File.basename(fn), File.read(fn).strip]
      elsif test(?e, File.join(fn,'NAME.xml.bns'))
        msg << "   " << File.basename(fn) <<"----------"<<'docbook' << "\n"
      elsif test(?e, File.join(fn,'NAME.rst.bns'))
        msg << "   " << File.basename(fn) <<"----------"<<'reST'<<"\n"
      end
    end

    @out.puts msg
    @out.puts
  end

  def parse( args )
    std_opts = standard_options

    opts = OptionParser.new
    opts.banner = 'Usage: docbones info'

    opts.separator ''
    opts.separator '  Shows information about available skeletons'

    opts.separator ''
    opts.separator '  Common Options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      @out.puts opts
      exit
    }

    # parse the command line arguments
    opts.parse! args
  end

end  # class InfoCommand
end  # class App
end  # module Docbones

# EOF
