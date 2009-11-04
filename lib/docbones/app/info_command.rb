
module Docbones
class App

class InfoCommand < Command

  def run( args )
    parse args

    skeleton_dir = File.join(mrbones_dir,'book')
    skeleton_dir = ::Docbones.path('data/book') unless test(?d, skeleton_dir)

    msg  = "\n"
    msg << "The default project skeleton will be copied from:\n"
    msg << "    " << skeleton_dir << "\n\n"

    fmt = "    %-12s => %s\n"
    msg << "Available projects skeletons are:\n"
    Dir.glob(File.join(mrbones_dir, '*')).sort.each do |fn|
      next if fn =~ %r/\.archive$/

      if test(?f, fn)
        msg << fmt % [File.basename(fn), File.read(fn).strip]
      elsif test(?e, File.join(fn,'book.rb'))
        msg << "   " << File.basename(fn) <<"----------"<<'book' << "\n"
      elsif test(?e, File.join(fn,'chapter.rb'))
        msg << "   " << File.basename(fn) <<"----------"<<'chapter'<<"\n"
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
