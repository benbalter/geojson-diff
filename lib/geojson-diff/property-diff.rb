class GeojsonDiff
  class PropertyDiff

    def initialize(before,after)
      @before = before
      @after = after
      @meta = { :added => [], :removed => [], :changed => [] }
    end

    def added?(key)
      !@before.key?(key) && @after.key?(key)
    end

    def removed?(key)
      @before.key?(key) && !@after.key?(key)
    end

    def changed?(key)
      !added?(key) && !removed?(key) && @before[key] != @after[key]
    end

    def diffed_property(key)
      if added? key
        @meta[:added].push key
        { key => @after[key] }
      elsif removed? key
        @meta[:removed].push key
        { key => @before[key] }
      elsif changed? key
        @meta[:changed].push key
        { key => Diffy::Diff.new(@before[key], @after[key]).to_s(:html) }
      else
        { key => @after[key] }
      end
    end

    def diff
      @properties = {}
      @before.merge(@after).each { |key,value| @properties.merge! diffed_property(key) }
      @properties.merge({ GeojsonDiff::META_KEY => @meta })
    end

    def to_json
      properties.to_json
    end

    def to_s
      properties.to_s
    end

    def properties
      @diff ||= diff
    end
  end
end
