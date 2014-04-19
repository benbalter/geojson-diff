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
  s.add_dependency( "rgeo")
  s.add_dependency( "rgeo-geojson" )
  s.add_dependency( "ffi-geos" )
  s.add_dependency( "diffy" )

  s.add_development_dependency( "rake" )
  s.add_development_dependency( "mocha" )
  s.add_development_dependency( "bundler" )
  s.add_development_dependency( "pry" )

end
