# GeoJSON Diff

*A Ruby library for diffing GeoJSON files*

## Requirements

GeoJSON Diff is bassed on [rgeo](https://github.com/dazuma/rgeo), [rgeo-geojson](https://github.com/dazuma/rgeo-geojson), [geos](http://trac.osgeo.org/geos/), and [ffi-geos](https://github.com/dark-panda/ffi-geos).

## Overview

GeoJSON Diff takes two GeoJSON files representing the same geometry (or geometries) at two points in time, and generates three GeoJSON files represented the added, removed, and unchanged geometries. These three geojson files can be used to generate a visual representation of the changes (proposed or realized), e.g., by coloring the added elements green and the removed elements red. See [diffable, more customizable maps](https://github.com/blog/1772-diffable-more-customizable-maps) for more information.

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


## Development

### Bootstrapping a local development environment

`script/bootstrap`

### Running tests

`script/cibuild`

### Development console

`script/console`

## License

[MIT](LICENSE.md)

## Contributing

1. Fork the project
2. Create a descriptively named feature branch
3. Make your changes
4. Submit a pull request
