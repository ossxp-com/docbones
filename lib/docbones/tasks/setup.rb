
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'ostruct'

class OpenStruct; undef :gem if defined? :gem; end 

# TODO: make my own openstruct type object that includes descriptions
# TODO: use the descriptions to output help on the available bones options

PROJ = OpenStruct.new(
  :output => "output",
  :root => nil,
  :index => nil,
  :name => nil
)

# Load the other rake files in the tasks folder

class DocbonesSetup
  def setup source_suffix
     tasks_dir = File.expand_path(File.dirname(__FILE__))
     if source_suffix =~ /\.xml/
        rakefiles = Dir.glob(File.join(tasks_dir, 'docbook.rake')).sort
     elsif source_suffix =~ /\.rst/
        rakefiles = Dir.glob(File.join(tasks_dir, 'rst.rake')).sort
     else
        rakefiles = Dir.glob(File.join(tasks_dir,'*.rake')).sort
     end
     import(*rakefiles)
  end
end

# EOF
