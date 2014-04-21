require 'test_helper'

class PropertyDiffTest < Test::Unit::TestCase

  def verify_property_diff(before,after,key,type)
    diff = GeojsonDiff::PropertyDiff.new(before,after)
    assert_equal true, diff.diff.key?("_geojson_diff"), "_geojson_diff key does not exist in #{diff}"
    assert_equal true, diff.diff["_geojson_diff"].key?(type.to_sym), "_geojson_diff.#{type} does not exist in #{diff}"
    assert_equal true, diff.diff["_geojson_diff"][type.to_sym].include?(key.to_sym), "_geojson_diff.#{type} does not include #{key} in #{diff}"
    assert_equal true, diff.send("#{type}?", key.to_sym), "#{type}? returned false for #{key}"
    assert_equal true, diff.send(type).include?(key.to_sym), "#{key} does not exist in ##{type} array"
    diff
  end

  def test_added_property
    before = { foo: "bar" }
    after = { foo: "bar", some_field: "baz" }
    diff = verify_property_diff before, after, "some_field", "added"
    assert_equal({:some_field => "baz"}, diff.send(:diffed_property, :some_field))
  end

  def test_removed_property
    before = { foo: "bar", some_field: "baz" }
    after = { foo: "bar" }
    diff = verify_property_diff before, after, "some_field", "removed"
    assert_equal({:some_field => "baz"}, diff.send(:diffed_property, :some_field))
  end

  def test_changed_property
    before = { foo: "bar" }
    after = { foo: "baz" }
    expected = "<div class=\"diff\">\n  <ul>\n    <li class=\"del\"><del>ba<strong>r</strong></del></li>\n    <li class=\"ins\"><ins>ba<strong>z</strong></ins></li>\n  </ul>\n</div>\n"
    diff = verify_property_diff before, after, "foo", "changed"
    assert_equal expected, diff.properties[:foo]
    assert_equal(expected, diff.send(:diffed_value, :foo))
    assert_equal({ :foo => expected }, diff.send(:diffed_property, :foo))
  end

  def test_unchanged_property
    before = { foo: "bar" }
    after = { foo: "bar" }
    diff = GeojsonDiff::PropertyDiff.new(before,after)
    assert_equal "bar", diff.properties[:foo]
    assert_equal false, diff.properties["_geojson_diff"][:changed].include?("foo")
    assert_equal false, diff.properties["_geojson_diff"][:added].include?("foo")
    assert_equal false, diff.properties["_geojson_diff"][:removed].include?("foo")
    assert_equal({:foo => "bar"}, diff.send(:diffed_property, :foo))
  end

end
