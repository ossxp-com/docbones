
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'ostruct'

class OpenStruct; undef :gem if defined? :gem; end 

# TODO: make my own openstruct type object that includes descriptions
# TODO: use the descriptions to output help on the available bones options

PROJ = OpenStruct.new(
  :pkg => "pkg",
  :root => nil,
  :xml => nil
)

# Load the other rake files in the tasks folder
tasks_dir = File.expand_path(File.dirname(__FILE__))
rakefiles = Dir.glob(File.join(tasks_dir, '*.rake')).sort
import(*rakefiles)

# EOF
