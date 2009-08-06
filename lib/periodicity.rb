$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# require 'activesupport'
require 'periodicity/period'

module Periodicity
  VERSION = '0.1'
end