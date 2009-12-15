
module Docbones
class App

class CreateCommand < Command

  def run( args )
    parse args

    fm = FileManager.new(
      :source => repository || skeleton_dir,
      :destination => output_dir,
      :stdout => @out,
      :stderr => @err,
      :verbose => verbose?
    )
    if index_name.nil?
       raise "Output directory already exists #{output_dir.inspect}" if test(?d, fm.destination)    end
    begin
      fm.copy index_name,name,source_suffix
      copy_tasks(File.join(output_dir, 'tasks')) if with_tasks?
      options[:index_name] = name if index_name.nil?
      fm.finalize index_name,name

      pwd = File.expand_path(FileUtils.pwd)
      msg = "Created '#{name}'"
      msg << " in directory '#{output_dir}'" if name != output_dir
      @out.puts msg

      if test(?f, File.join(output_dir, 'Rakefile'))
        begin
          FileUtils.cd output_dir
        ensure
          FileUtils.cd pwd
        end
      end
    rescue Exception => err
      FileUtils.rm_rf output_dir
      msg = "Could not create '#{name}'"
      msg << " in directory '#{output_dir}'" if name != output_dir
      raise msg
    end
  end

  def parse( args )
    std_opts = standard_options
    opts = OptionParser.new
    opts.banner = 'Usage: docbones create [options] <project_name>'

    opts.separator ''
    opts.on(*std_opts[:type])
    opts.on(*std_opts[:name])
    opts.on(*std_opts[:skeleton])

    opts.separator ''
    opts.separator '  Common Options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      @out.puts opts
      exit
    }

    # parse the command line arguments
    opts.parse! args
    args_names = (args.to_s.include?('/')) ? args.to_s.split('/') : []
    last_name = args_names.last
    if args_names.size >1
        if last_name =~ /\.rst/
           options[:skeleton_dir] = ::Docbones.path('data/rest')
           options[:source_suffix] = '.rst' if source_suffix.nil?
        end
        if last_name =~ /\.xml/
           options[:skeleton_dir] = ::Docbones.path('data/db')
           options[:source_suffix] = '.xml' if source_suffix.nil?
        end
        options[:index_name] = last_name.sub(/(\.rst$)|(\.xml)/,'')
        args_names.delete_at(args_names.size-1)
        options[:name] = args_names.join('/')
    else
        options[:name] = args.empty? ? nil : args.join('_')
    end
    if name.nil?
      @out.puts opts
      exit 1
    end
    options[:output_dir] = name if output_dir.nil?
  end

end  # class CreateCommand
end  # class App
end  # module Docbones

# EOF
