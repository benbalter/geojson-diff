require File.expand_path('lib/geojson-diff/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = "geojson-diff"
  s.summary = "A Ruby library for diffing GeoJSON files"
  s.description = "GeoJSON Diff takes two GeoJSON files representing the same geometry (or geometries) at two points in time, and generates three GeoJSON files represented the added, removed, and unchanged geometries."
  s.version = GeojsonDiff::VERSION
  s.authors = ["Ben Balter"]
  s.email = "ben.balter@github.com"
  s.homepage = "https://github.com/benbalter/geojson-diff"
  s.licenses = ["MIT"]

  s.files = [
    "lib/geojson-diff.rb",
    "lib/geojson-diff/property-diff.rb",
    "lib/geojson-diff/version.rb",
    "lib/rgeo/geojson.rb"
  ]

  s.require_paths = ["lib"]
  s.add_dependency( "rgeo", '~> 0.3')
  s.add_dependency( "rgeo-geojson", '~> 0.2' )
  s.add_dependency( "ffi-geos", '~> 1.0' )
  s.add_dependency( "diffy", '~> 3.0' )

  s.add_development_dependency( "rake", '~> 10.3' )
  s.add_development_dependency( "mocha", '~> 1.0' )
  s.add_development_dependency( "bundler",'~> 1.5' )
  s.add_development_dependency( "pry", '~> 0.9' )
end
