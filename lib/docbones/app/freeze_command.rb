
module Docbones
class App

class FreezeCommand < Command

  def run( args )
    parse args

    fm = FileManager.new(
      :source => skeleton_dir,
      :destination => output_dir,
      :stdout => @out,
      :stderr => @err,
      :verbose => verbose?
    )

    fm.archive_destination
    return freeze_to_repository if repository

    fm.copy index_name,name,source_suffix
    copy_tasks(File.join(output_dir, 'tasks')) if with_tasks?

    @out.puts "Project skeleton #{name.inspect} " <<
              "has been frozen to Docbones #{::Docbones::VERSION}"
  end

  def parse( args )
    std_opts = standard_options
    
    opts = OptionParser.new
    opts.banner = 'Usage: docbones freeze [options] [skeleton_name]'

    opts.separator ''
    opts.on(*std_opts[:type])

    opts.separator ''
    opts.separator '  Common Options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      @out.puts opts
      exit
    }

    # parse the command line argument
    opts.parse! args
    options[:name] =args.empty? ? nil : args.join('_')
    options[:source_suffix] = nil
    options[:index_name] = nil
    options[:output_dir] = File.join(mrbones_dir, name)
  end

  # Freeze the project skeleton to the git or svn repository that the user
  # passed in on the command line. This essentially creates an alias to the
  # reposiory using the name passed in on the command line.
  #
  def freeze_to_repository
    FileUtils.mkdir_p(File.dirname(output_dir))
    File.open(output_dir, 'w') {|fd| fd.puts repository}
    @out.puts "Project skeleton #{name.inspect} " <<
              "has been frozen to #{repository.inspect}"
  end


end  # class FreezeCommand
end  # class App
end  # module Docbones

# EOF
