require 'test_helper'

class RgeoGeojsonTest < Test::Unit::TestCase

  def test_rgeo_geojson_to_json
    null_island = RGeo::Geos.factory.point(0,0)
    feature = RGeo::GeoJSON::Feature.new(null_island)
    feature_collection = RGeo::GeoJSON::FeatureCollection.new([feature])
    expected = "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[0.0,0.0]},\"properties\":{}}]}"
    assert_equal expected, feature_collection.to_json
    assert_equal JSON.parse(expected), JSON.parse(feature_collection.to_json)
  end

end
