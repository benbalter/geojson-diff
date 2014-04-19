$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..'))

ENV['RACK_ENV'] = 'test'

require 'lib/geojson_diff'
require 'test/unit'
require 'mocha/setup'
