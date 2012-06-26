#Include with ActiveRecord::Base
module Ordering
  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    # Defines a scope with the given name and ordering conditions.
    # Should work with reverse_order and ordered DISTINCT selects in PostgreSQL.
    def order_scope name, condition_array
      self.scope(name, condition_array.inject(nil) do |memo, n|
        (memo ? memo.order(n) : select(self.arel_table[Arel.star]).order(n)).select(n.gsub(/ DESC\Z/, ''))
      end)
    end
  end
end