require 'rgeo'
require 'rgeo/geo_json'
require 'diffy'
require_relative 'rgeo/geojson'
require_relative 'geojson-diff/property-diff'
require_relative 'geojson-diff/version'

ENV["GEOS_LIBRARY_PATH"] ||= File.expand_path("lib", `geos-config --prefix`.strip)

class GeojsonDiff

  KEY = '_geojson_diff'

  def initialize(before, after)
    @before = ensure_feature_collection(RGeo::GeoJSON.decode(before, :json_parser => :json))
    @after = ensure_feature_collection(RGeo::GeoJSON.decode(after, :json_parser => :json))
  end

  attr_accessor :before, :after

  def added
    diff(@after,@before,"added")
  end

  def removed
    diff(@before,@after,"removed")
  end

  def unchanged
    diff(@before,@after,"unchanged")
  end

  private

  # Given a geometry, ensures that it is represented as a feature collection
  # This way diff logic can remain consistent between geometry types
  # Rather than creating diff logic for each type
  def ensure_feature_collection(geometry)
    return geometry if geometry.class == RGeo::GeoJSON::FeatureCollection
    return RGeo::GeoJSON::FeatureCollection.new([]) if geometry.nil?
    geometry = RGeo::GeoJSON::Feature.new(geometry) unless geometry.class == RGeo::GeoJSON::Feature
    RGeo::GeoJSON::FeatureCollection.new([geometry])
  end

  # Find index of indentical feature within a feature collection based on geometry
  #
  # from_feature - the needle feature
  # to - the haystack featurecollection
  #
  # returns (int) the index of the identical feature, or nil
  def match(before_feature,after_feature_collection)
    after_feature_collection.find_index do |after_feature|
      after_feature.geometry.rep_equals?(before_feature.geometry) ||
      after_feature.geometry.equals?(before_feature.geometry)
    end
  end

  # Given a feature (before and after), diffs the geometry and properties
  #
  # before_feature - Feature before the change
  # after_feature  - Feature after the change
  # type           - requested diff component, either added, removed, or unchanged
  #
  # Returns a feature representing the requested diff component
  def diff_feature(before_feature, after_feature, type="difference")
    geometry = diff_geometry(before_feature, after_feature, type)
    return nil if geometry.nil? || geometry.is_empty?
    properties = { KEY => {} }
    properties.merge! diff_properties(before_feature, after_feature, type)
    properties[KEY].merge!({type: type})
    RGeo::GeoJSON::Feature.new(geometry,nil,properties)
  end

  # Diff the geometry of a given feature
  #
  # before_feature - Feature before the change
  # after_feature  - Feature after the change
  # type           - requested diff component, either added, removed, or unchanged
  #
  # Returns the resulting feature geometry
  def diff_geometry(before_feature, after_feature, type)
    if type == "unchanged"
      command = "intersection"
    else
      command = "difference"
    end

    if after_feature.nil? && type == "unchanged"
      nil # doesn't exist in other so can't intersect
    elsif after_feature.nil? #added or removed
      before_feature.geometry # pass through
    else # true diff
      before_feature.geometry.send(command, after_feature.geometry)
    end
  end

  # Diff the properties of a given feature
  #
  # before_feature - Feature before the change
  # after_feature  - Feature after the change
  # type           - requested diff component, either added, removed, or unchanged
  #
  # Returns a JSON representation of the feature's diff'd properties
  def diff_properties(before_feature, after_feature, type)
    if after_feature.nil? && type == "unchanged"
      {}
    elsif type == "added" || type == "removed"
      before_feature.properties
    else
      PropertyDiff.new(before_feature.properties, after_feature.properties).properties
    end
  end

  # Generate a feature collection representing the requested diff
  #
  # before - starting decoded geojson
  # after- end decoded geojson
  # type - type of diff to perform, noted in each feature's properties
  #
  # For diffs, think of this as what's in #{before} that's not in #{after}
  # For intersections, it's what's in both #{before} and {after}
  #
  # returns a feature collection of the diff
  def diff(before, after, type="difference")
    features = []
    matched = []

    # Don't mangle the true before and after instance variables
    before_features = before.instance_variable_get("@features").clone
    after_features = after.instance_variable_get("@features").clone

    # Loop through once diffing the properties of any directly-matched geometries
    # This helps eliminates edge cases where adding/removing a single element could
    # break the entire diff, sans an LCS approach.
    before_features.each_with_index do |feature, index|
      next unless match_index = match(feature,after_features)

      # direct match for a feature, on an unchanged diff, just diff properties
      if type == "unchanged"
        diffed_feature = diff_feature(feature, after_features[match_index], type)
        features.push diffed_feature unless diffed_feature.nil?
      end

      # If they've matched, we know they can't be added or removed
      after_features.delete_at(match_index)
      matched.push feature
    end

    # You can't delete elements from an array while iterating over them
    # So wait until we've matched everything, and delete those that have been matched
    matched.each do |feature|
      before_features.delete(feature)
    end

    # Loop through what's left, and perform a straight index->index geometry diff
    before_features.each_with_index do |feature,index|
      diffed_feature = diff_feature(feature, after_features[index], type)
      features.push diffed_feature unless diffed_feature.nil?
    end
    RGeo::GeoJSON::FeatureCollection.new(features)
  end
end
