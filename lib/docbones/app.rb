
require 'fileutils'
require 'optparse'
require 'erb'

module Docbones
class App

  # Create a new instance of App, and run the +docbones+ application given
  # the command line _args_.
  #
  def self.run( args )
    self.new.run args
  end

  # Create a new main instance using _io_ for standard output and _err_ for
  # error messages.
  #
  def initialize( out = STDOUT, err = STDERR )
    @out = out
    @err = err
  end

  # Parse the desired user command and run that command object.
  #
  def run( args )
    cmd_str = args.shift
    cmd = case cmd_str
      when 'create';    CreateCommand.new(@out, @err)
      when 'freeze';    FreezeCommand.new(@out, @err)
      when 'unfreeze';  UnfreezeCommand.new(@out, @err)
      when 'info';      InfoCommand.new(@out, @err)
      when nil, '-h', '--help'
        help
      when '-v', '--version'
        @out.puts "Docbones  #{::Docbones::VERSION}"
        nil
      else
        raise "Unknown command #{cmd_str.inspect}"
      end

    cmd.run args if cmd

  rescue StandardError => err
    @err.puts "ERROR:  While executing docbones ... (#{err.class})"
    @err.puts "    #{err.to_s}"
    exit 1
  end

  # Show the toplevel Docbones help message.
  #
  def help
    @out.puts <<-MSG

  Usage:
    docbones -h/--help
    docbones -v/--version
    docbones command [options] [arguments]

  Commands:
    docbones create          create a new project from a skeleton
    docbones freeze          create a new skeleton in ~/.mrdocbones/
    docbones unfreeze        remove a skeleton from ~/.mrdocbones/
    docbones info            show information about available skeletons

  Further Help:
    Each command has a '--help' option that will provide detailed
    information for that command.

    http://www.ossxp.com

    MSG
    nil
  end

end  # class App
end  # module Docbones

Docbones.require_all_libs_relative_to(__FILE__)

# EOF
