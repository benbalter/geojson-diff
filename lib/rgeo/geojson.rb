# monkey patch in a native to_json method for FeatureCollections
module RGeo
  module GeoJSON
    class FeatureCollection
      def to_json
        RGeo::GeoJSON.encode(self).to_json
      end
    end
  end
end
