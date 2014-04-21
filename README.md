# GeoJSON Diff

*A Ruby library for diffing GeoJSON files*

[![Gem Version](https://badge.fury.io/rb/geojson-diff.svg)](http://badge.fury.io/rb/geojson-diff) [![Build Status](https://travis-ci.org/benbalter/geojson-diff.svg?branch=master)](https://travis-ci.org/benbalter/geojson-diff)

## Overview

GeoJSON Diff takes two GeoJSON files representing the same geometry (or geometries) at two points in time, and generates three GeoJSON files representing the `added`, `removed`, and `unchanged` geometries.

These three GeoJSON files can be used to generate a visual representation of the changes (proposed or realized), e.g., by coloring the added elements green and the removed elements red. GeoJSON Diff is what powers [GeoJSON diffing on GitHub](https://github.com/blog/1772-diffable-more-customizable-maps).

### GeoJSON Diff in the wild

See GeoJSON diff in action! Here's [a diff](https://github.com/benbalter/congressional-districts/commit/2233c76ca5bb059582d796f053775d8859198ec5) of Illinois's famed 4th congressional district after undergoing redistricting in 2011:

[![Illinois 4th Congressional district](https://f.cloud.github.com/assets/282759/2090660/63f2e45a-8e97-11e3-9d8b-d4c8078b004e.gif)](https://github.com/benbalter/congressional-districts/commit/2233c76ca5bb059582d796f053775d8859198ec5#diff-85d2c1b78193e963475250414e57940b)

GeoJSON Diff will even diff properties within the geometry when they change:

[![Updating a property](https://f.cloud.github.com/assets/282759/2022569/dfaf96b8-884f-11e3-95ca-8f54c60a2ccf.png)](https://github.com/DU-GIS/Geojson_Data/commit/042e86e417a7fb9e43504640046339e82618e4c2#diff-0cca6b7c0e294c8d3e9d9b8090ab9e24)

## Usage

```ruby
diff = GeojsonDiff.new geojson_before, geojson_after

diff.added
# => {"type":"Feature"... (valid GeoJSON representing the added geometries)

diff.removed
# => {"type":"Feature"... (valid GeoJSON representing the removed geometries)

diff.unchanged
# => {"type":"Feature"... (valid GeoJSON representing the unchanged geometries)
```

For practical examples, take a look at the [test/fixtures directory](test/fixtures).

## Displaying the resulting GeoJSON

Every geometry within the resulting GeoJSON files will be appended with standard GeoJSON properties in the `_geojson_diff` namespace.

* `type` - this field contains either `added`, `removed`, or `unchanged` and describes the state of the geometry as it relates to the initial GeoJSON file.
* `added`, `removed`, `changed` - these fields contain an array of property keys. If a given key is in the `added` array, that property existed in the resulting geometry, but not in the initial geometry. Likewise, if a key is in `removed` array it existed in the initial geometry, but not the resulting geometry, and if the key is in the `changed` array, it existed in both the initial and resulting geometry, but was changed.
* For changed properties, the values of the `after` GeoJSON file will be marked up as a [Diffy `:html` diff](https://github.com/samg/diffy#html-output) and will represent the inline diff of the changed value.

## Installation

### Requirements

GeoJSON Diff is bassed on [rgeo](https://github.com/dazuma/rgeo), [rgeo-geojson](https://github.com/dazuma/rgeo-geojson), [geos](http://trac.osgeo.org/geos/), [ffi-geos](https://github.com/dark-panda/ffi-geos), and [diffy](https://github.com/samg/diffy).

### Installing GEOS

If you're on OS X and have Homebrew installed, you'll first want to run `brew install geos` to install the GEOS geospatial library. On other systems, consult [the GEOS installation instructions](http://trac.osgeo.org/geos/).

### Installing the Gem

Add the following to your project's Gemfile and run `bundle install`:

`gem 'geojson-diff'`

### Pro-Tip

Because the library depends on [GEOS](http://trac.osgeo.org/geos/), which can be finicky on some systems, the set-it-and-forget-it way to get everything set up is to:

1. Add `gem 'geojson-diff'` to your project's Gemfile
2. Copy the contents of [script/bootstrap](script/bootstrap)
3. `cd` to your project's root directory and paste/run the commands

This will install GEOS and configure the necessary environmental values.

## Development

### Bootstrapping a local development environment

`script/bootstrap`

### Running tests

`script/cibuild`

### Development console

`script/console`

## Troubleshooting GEOS

On some environments, prior to running your application or running `bundle install`, you'll need to run the following commands to properly configure your execution environment for Ruby to find the GEOS library:

```
export GEOS_LIBRARY_PATH=`geos-config --prefix`/lib
bundle config --local build.rgeo --with-geos-dir="$GEOS_LIBRARY_PATH"
````

## License

[MIT](LICENSE.md)

## Contributing

1. Fork the project
2. Create a descriptively named feature branch
3. Make your changes
4. Submit a pull request
