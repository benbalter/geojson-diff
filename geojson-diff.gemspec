Gem::Specification.new do |s|
  s.name = "geojson-diff"
  s.summary = ""
  s.description = ""
  s.version = "0.0.1"
  s.authors = ["Ben Balter"]
  s.email = "ben.balter@github.com"
  s.homepage = "https://github.com/benbalter/geojson-diff"
  s.licenses = ["MIT"]

  s.files = [
    "lib/geojson_diff.rb",
    "lib/geojson_diff/property_diff.rb",
    "lib/rgeo/geojson.rb"
  ]
  s.require_paths = ["lib"]
  s.add_dependency( "rgeo", '~> 0.3.20')
  s.add_dependency( "rgeo-geojson", '~> 0.2.3' )
  s.add_dependency( "ffi-geos", '~> 0.5.0' )
  s.add_dependency( "diffy", '~> 3.0.4' )

  s.add_development_dependency( "rake", '~> 10.3.1' )
  s.add_development_dependency( "mocha", '~> 1.0.0' )
  s.add_development_dependency( "bundler",'~> 1.5.3' )
  s.add_development_dependency( "pry", '~> 0.9.12.6' )

end
