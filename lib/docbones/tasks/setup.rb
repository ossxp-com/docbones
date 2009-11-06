
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'ostruct'
require 'find'

class OpenStruct; undef :gem if defined? :gem; end 

# TODO: make my own openstruct type object that includes descriptions
# TODO: use the descriptions to output help on the available bones options

PROJ = OpenStruct.new(
  :gem => OpenStruct.new(
    :files => nil
  ),

  # File Annotations
  :notes => OpenStruct.new(
    :exclude => %w(^tasks/setup\.rb$),
    :extensions => %w(.txt .rb .erb .rdoc) << '',
    :tags => %w(FIXME OPTIMIZE TODO)
  ),


  # Test::Unit
  :test => OpenStruct.new(
    :files => FileList['test/**/test_*.rb'],
    :file  => 'test/all.rb',
    :opts  => []
  )
)

# Load the other rake files in the tasks folder
tasks_dir = File.expand_path(File.dirname(__FILE__))
rakefiles = Dir.glob(File.join(tasks_dir, '*.rake')).sort
import(*rakefiles)

def ensure_in_path( *args )
  args.each do |path|
    path = File.expand_path(path)
    $:.unshift(path) if test(?d, path) and not $:.include?(path)
  end
end

# candidates to be in the manifest.
#
def manifest
  files = []

  Find.find '.' do |path|
    path.sub! %r/^(\.\/|\/)/o, ''
    next unless test ?f, path
    next if path =~ /(\.rb)$/
    files << path
  end
  files.sort!
end


PROJ.gem.files ||= manifest

# EOF
