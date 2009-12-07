
module Docbones
class App

class Command

  attr_reader :options

  def initialize( out = STDOUT, err = STDERR )
    @out = out
    @err = err
    @options = {
      :skeleton_dir =>File.join(mrbones_dir,'db'),
      :with_tasks => false,
      :verbose => false,
      :name => nil,
      :output_dir => nil,
      :index_name => nil
    }
    @options[:skeleton_dir] = ::Docbones.path('data/rest') unless test(?d, skeleton_dir)
  end

  def run( args )
    raise NotImplementedError
  end

  # The output directory where files will be written.
  #
  def output_dir
    options[:output_dir]
  end

  # The directory where the project skeleton is located.
  #
  def skeleton_dir
    options[:skeleton_dir]
  end

  # The project name from the command line.
  #
  def name
    options[:name]
  end

  def index_name
    options[:index_name]
  end

  # A git or svn repository URL from the command line.
  #
  def repository
    return options[:repository] if options.has_key? :repository
    return IO.read(skeleton_dir).strip if skeleton_dir and test(?f, skeleton_dir)
    nil
  end

  # Returns +true+ if we are going to copy the Docbones  tasks into the
  # destination directory. Normally this will return +false+.
  #
  def with_tasks?
    options[:with_tasks]
  end

  #
  #
  def copy_tasks( to )
    fm = FileManager.new(
      :source => ::Docbones.path(%w[lib docbones tasks]),
      :destination => to,
      :stdout => @out,
      :stderr => @err,
      :verbose => verbose?
    )
    fm.archive_destination
    fm.copy
  end

  # Returns +true+ if the user has requested verbose messages.
  #
  def verbose?
    options[:verbose]
  end

  # Returns the .docbones resource directory in the user's home directory.
  #
  def mrbones_dir
    return @mrbones_dir if defined? @mrbones_dir

    path = File.join(::Docbones::HOME, '.mrdocbones')
    @mrbones_dir = File.expand_path(path)
  end

  #
  #
  def standard_options
    {
      :type => ['-t', '--type NAME', String, '',
          lambda { |value|
            if value =~ /(db)|(docbook)/
               options[:skeleton_dir] = ::Docbones.path('data/db')
            elsif value  =~ /(rst)|(rest)|(reStructuredText)|(reST)/
               options[:skeleton_dir] = ::Docbones.path('data/rest')
            else
               puts "请输入正确的格式"
            end
            typeArray = value.split('/')
            if typeArray.last =~ /\.xml$/
               options[:index_name] = typeArray.last.sub('.xml','')
            end
            if typeArray.last =~ /\.rst$/
               options[:index_name] = typeArray.last.sub('.rst','')
            end
          }],
      :name => ['-n', '--name NAME', String, '',
          lambda { |value|
            options[:index_name] = value
          }],
      :skeleton => ['-s', '--skeleton NAME', String,
          'project skeleton to use',
          lambda { |value|
            path = File.join(mrbones_dir, value)
            if test(?e, path)
              options[:skeleton_dir] = path 
            elsif test(?e, value)
              options[:skeleton_dir] = value
            else
              raise ArgumentError, "Unknown skeleton '#{value}'"
            end
          }]
    }
  end

end  # class Command
end  # class App
end  # module Docbones

# EOF
