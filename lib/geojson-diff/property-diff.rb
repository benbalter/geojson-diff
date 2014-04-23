class GeojsonDiff
  class PropertyDiff

    # Creates a new PropertyDiff instance
    #
    # before - the property element of the starting geometry (as parsed JSON)
    # after - the property element of the resulting geometry (as parsed JSON)
    #
    # returns the PropertyDiff instance
    def initialize(before,after)
      @before = before
      @after = after
      @meta = { :added => [], :removed => [], :changed => [] }
      diff
    end

    # Checks if the given key has been added to the resulting geometry
    #
    # key - string the JSON property key to check
    #
    # Returns bool true if added, otherwise false
    def added?(key)
      !@before.key?(key) && @after.key?(key)
    end

    # Returns an array of all keys added to the resulting geometry
    def added
      @meta[:added]
    end

    # Checks if the given key has been removed from the resulting geometry
    #
    # key - string the JSON property key to check
    #
    # Returns bool true if removed, otherwise false
    def removed?(key)
      @before.key?(key) && !@after.key?(key)
    end

    # Returns an array of all keys removed from the resulting geometry
    def removed
      @meta[:removed]
    end

    # Checks if the given key has been modified in the resulting geometry
    #
    # key - string the JSON property key to check
    #
    # Returns bool true if modified, otherwise false
    def changed?(key)
      !added?(key) && !removed?(key) && @before[key] != @after[key]
    end

    # Returns an array of all keys modified in the resulting geometry
    def changed
      @meta[:changed]
    end

    # Returns the JSON representation of the diffed properties, including metadata
    def to_json
      diff.to_json
    end

    def to_s
      diff.to_s
    end

    def inspect
      "#<GeojsonDiff::PropertyDiff added=#{added.to_s} removed=#{removed.to_s} changed=#{changed.to_s}>"
    end

    # Returns a hash of the diffed properties, including metadata
    def diff
      @diff ||= begin
        properties = {}
        @before.merge(@after).each { |key,value| properties.merge! diffed_property(key) }
        properties.merge({ GeojsonDiff::META_KEY => @meta })
      end
    end
    alias_method :properties, :diff

    private

    # Diffs an individual key/value pair
    # Also propagates @meta arrays
    #
    # key - the property key to diff
    #
    # Returns the resulting key/value pair, either before (removed), after (added), or diffed (changed)
    def diffed_property(key)
      if added? key
        @meta[:added].push key
        { key => @after[key] }
      elsif removed? key
        @meta[:removed].push key
        { key => @before[key] }
      elsif changed? key
        @meta[:changed].push key
        { key => diffed_value(key) }
      else # unchanged
        { key => @after[key] }
      end
    end

    # Diffs an individual changed value
    #
    # key - the property key to diff
    #
    # Returns (string) the Diffy representation of the changed property
    def diffed_value(key)
      Diffy::Diff.new(@before[key], @after[key]).to_s(:html)
    end
  end
end
