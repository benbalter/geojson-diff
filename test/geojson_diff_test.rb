require 'test_helper'
require 'json'

class GeojsonDiffTest < Test::Unit::TestCase

  def setup
    @fixtures_dir = File.expand_path("../fixtures/", __FILE__)
    before        = "#{@fixtures_dir}/multipolygon-diff/before.geojson"
    after         = "#{@fixtures_dir}/multipolygon-diff/after.geojson"
    @diff         = GeojsonDiff.new(before,after)
    @inputs       = ["before", "after"]
    @outputs      = ["added", "removed", "unchanged"]
    @files        = @inputs.dup.concat @outputs
  end

  # Given the name of a GeoJSON fixture
  # Diffs the fixture and verifies that diff output matches the fixture output
  def verify_fixture_diff(fixture)
    if fixture == "initial-commit"
      before = nil
    else
      before = File.open("#{@fixtures_dir}/#{fixture}-diff/before.geojson").read
    end
    after = File.open("#{@fixtures_dir}/#{fixture}-diff/after.geojson").read

    diff = GeojsonDiff.new(before,after)
    @inputs.each do |input|
      assert_equal RGeo::GeoJSON::FeatureCollection, @diff.send(input).class
    end
    @outputs.each do |type|
      expected = File.open("#{@fixtures_dir}/#{fixture}-diff/#{type}.geojson").read.strip
      assert_equal expected, diff.send(type).to_json, "`#{type}.geojson` output does not match"
    end
    diff
  end

  def verify_property_diff(before,after,key,type)
    diff = GeojsonDiff::PropertyDiff.new(before,after)
    assert_equal true, diff.diff.key?("_geojson_diff"), "_geojson_diff key does not exist in #{diff}"
    assert_equal true, diff.diff["_geojson_diff"].key?(type.to_sym), "_geojson_diff.#{type} does not exist in #{diff}"
    assert_equal true, diff.diff["_geojson_diff"][type.to_sym].include?(key.to_sym), "_geojson_diff.#{type} does not include #{key} in #{diff}"
    diff
  end

  def test_handles_bad_json
    expected = RGeo::GeoJSON::FeatureCollection.new([]).to_json
    assert_nothing_raised do
      diff = verify_fixture_diff "bad-json"
      @files.each do |file|
        assert_equal expected, diff.send(file).to_json
      end
    end
  end

  def test_valid_json
    assert_nothing_raised do
      @files.each do |file|
        JSON.parse @diff.send(file).to_json
      end
    end
  end

  def test_methods
    @files.each do |file|
      assert_respond_to @diff, file
    end
  end

  def test_ensure_featurecollection
    null_island = RGeo::Geos.factory.point(0,0)
    feature = RGeo::GeoJSON::Feature.new(null_island)
    feature_collection = RGeo::GeoJSON::FeatureCollection.new([feature])
    assert_equal RGeo::GeoJSON::FeatureCollection, @diff.send("ensure_feature_collection", null_island).class
    assert_equal RGeo::GeoJSON::FeatureCollection, @diff.send("ensure_feature_collection", feature).class
    assert_equal RGeo::GeoJSON::FeatureCollection, @diff.send("ensure_feature_collection", feature_collection).class
  end

  def test_inject_render_type
    @outputs.each do |type|
      data = JSON.parse @diff.send(type).to_json
      data["features"].each do |feature|
        assert_equal type, feature["properties"]["_geojson_diff"]["type"]
      end
    end
  end

  def test_added_property
    before = { foo: "bar" }
    after = { foo: "bar", some_field: "baz" }
    verify_property_diff before, after, "some_field", "added"
  end

  def test_removed_property
    before = { foo: "bar", some_field: "baz" }
    after = { foo: "bar" }
    verify_property_diff before, after, "some_field", "removed"
  end

  def test_changed_property
    before = { foo: "bar" }
    after = { foo: "baz" }
    diff = verify_property_diff before, after, "foo", "changed"
    assert_equal "<div class=\"diff\">\n  <ul>\n    <li class=\"del\"><del>ba<strong>r</strong></del></li>\n    <li class=\"ins\"><ins>ba<strong>z</strong></ins></li>\n  </ul>\n</div>\n", diff.properties[:foo]
  end

  def test_unchanged_property
    before = { foo: "bar" }
    after = { foo: "bar" }
    diff = GeojsonDiff::PropertyDiff.new(before,after)
    assert_equal "bar", diff.properties[:foo]
    assert_equal false, diff.properties["_geojson_diff"][:changed].include?("foo")
    assert_equal false, diff.properties["_geojson_diff"][:added].include?("foo")
    assert_equal false, diff.properties["_geojson_diff"][:removed].include?("foo")
  end

  # Fixture tests in alpha order, because OCD
  # Should cover the entire GeoJSON spec

  def test_feature_diff
    verify_fixture_diff "feature"
  end

  def test_geometrycollection_diff
    verify_fixture_diff "geometrycollection"
  end

  def test_initial_commit_diff
    verify_fixture_diff "initial-commit"
  end

  def test_line_feature_collection_diff
    verify_fixture_diff "line-feature-collection"
  end

  def test_linestring_diff
    verify_fixture_diff "linestring"
  end

  def test_multilinestring_diff
    verify_fixture_diff "multilinestring"
  end

  def test_multipoint_diff
    verify_fixture_diff "multipoint"
  end

  def test_multipolygon_diff
    verify_fixture_diff "multipolygon"
  end

  def test_point_diff
    verify_fixture_diff "point"
  end

  def test_point_feature_collection_diff
    verify_fixture_diff "point-feature-collection"
  end

  def test_polygon_diff
    verify_fixture_diff "polygon"
  end

  def test_polygon_feature_collection_diff
    verify_fixture_diff "polygon-feature-collection"
  end

  def test_property_diff
    verify_fixture_diff "property"
  end

  def test_remove_feature_diff
    verify_fixture_diff "remove-feature"
  end
end
