class Hash
  def deep_find key
    if key?(key)
      self[key]
    else
      values.map {|vv| vv.deep_find(key) if vv.kind_of?(Hash)}.compact.flatten
    end
  end
end

module Enumerable
  def sum_leaf_nodes
    sum = 0
    values = self.kind_of?(Hash) ? self.values : nil

    if self.kind_of?(Hash)
      each_value do |v|
        if v.kind_of? Hash
          sum += v.sum_leaf_nodes
        else
          sum += v if v.respond_to?(:+)
        end
      end
    elsif all? {|v| v.kind_of?(Hash)}
      each {|v| sum += v.sum_leaf_nodes}
    elsif all? {|v| v.respond_to?(:+)}
      sum += reduce(:+)
    end

    sum
  end

  def leaf_nodes
    nodes = []
    if self.kind_of?(Hash)
      each_value do |v|
        if v.kind_of? Hash
          nodes += v.leaf_nodes
        else
          nodes << v
        end
      end
    else
      nodes << self
    end
    nodes
  end
end